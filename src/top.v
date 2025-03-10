module top(
    input clk,

    output reg tm_cs,
    output tm_clk,
    inout  tm_dio
    );

    localparam 
        HIGH    = 1'b1,
        LOW     = 1'b0;

    localparam [7:0]
        C_READ  = 8'b01000010,
        C_WRITE = 8'b01000000,
        C_DISP  = 8'b10001111,
        C_ADDR  = 8'b11000000;

    reg rst = HIGH;

    reg [5:0] instruction_step;
    reg [7:0] keys;

    reg [7:0] larson;
    reg larson_dir;
    integer counter;

    // set up tristate IO pin for display
    //   tm_dio     is physical pin
    //   dio_in     for reading from display
    //   dio_out    for sending to display
    //   tm_rw      selects input or output
    reg tm_rw;
    wire dio_in, dio_out;

    assign tm_dio = tm_rw ? dio_out : 1'bz;
    assign dio_in = tm_dio;

    // setup tm1638 module with it's tristate IO
    //   tm_in      is read from module
    //   tm_out     is written to module
    //   tm_latch   triggers the module to read/write display
    //   tm_rw      selects read or write mode to display
    //   busy       indicates when module is busy
    //                (another latch will interrupt)
    //   tm_clk     is the data clk
    //   dio_in     for reading from display
    //   dio_out    for sending to display
    //
    //   tm_data    the tristate io pin to module

    reg tm_latch;
    wire busy;
    wire [7:0] tm_data, tm_in;
    reg [7:0] tm_out;
    wire clk_1Hz;

    assign tm_in = tm_data;
    assign tm_data = tm_rw ? tm_out : 8'hZZ;

    tm1638 u_tm1638 (
        .clk(clk),
        .rst(rst),
        .data_latch(tm_latch),
        .data(tm_data),
        .rw(tm_rw),
        .busy(busy),
        .sclk(tm_clk),
        .dio_in(dio_in),
        .dio_out(dio_out)
    );

    clk_divider #(
        .clk_in(100_000_000),
        .clk_out(1)
    ) u_clk_divider (
        .clk(clk),
        .clk_1Hz(clk_1Hz)
    );

    wire [3:0] second_0, second_1, minute_0, minute_1, hour_0, hour_1;

    digits u_digits (
        .clk(clk_1Hz),
        .rst(),
        .second_0(second_0),
        .second_1(second_1),
        .minute_0(minute_0),
        .minute_1(minute_1),
        .hour_0(hour_0),
        .hour_1(hour_1)
    );

    wire [7:0] S_1, S_2, S_3, S_4, S_5, S_6, S_7, S_8;

    assign S_3 = 8'b01000000;
    assign S_6 = 8'b01000000;

    bcd_to_led7seg dig8 (
        .bcd(second_0),
        .led7seg(S_8)
    );

    bcd_to_led7seg dig7 (
        .bcd(second_1),
        .led7seg(S_7)
    );

    bcd_to_led7seg dig5 (
        .bcd(minute_0),
        .led7seg(S_5)
    );

    bcd_to_led7seg dig4 (
        .bcd(minute_1),
        .led7seg(S_4)
    );

    bcd_to_led7seg dig2 (
        .bcd(hour_0),
        .led7seg(S_2)
    );

    bcd_to_led7seg dig1 (
        .bcd(hour_1),
        .led7seg(S_1)
    );

    // handles displaying 1-8 on a display location
    // and animating the decimal point
    task display_digit;
        input [2:0] key;
        input [7:0] segs;

        begin
            tm_latch <= HIGH;

            if (keys[key])
                tm_out <= 8'b00000000;  // display off
            else
                tm_out <= segs;         // display number
        end
    endtask

    // handles animating the LEDs 1-8
    task display_led;
        input [2:0] dot;

        begin
            tm_latch <= HIGH;
            tm_out <= {7'b0, larson[dot]};
        end
    endtask

    always @(posedge clk) begin
        if (rst) begin
            instruction_step <= 6'b0;
            tm_cs <= HIGH;
            tm_rw <= HIGH;
            rst <= LOW;

            counter <= 0;
            keys <= 8'b0;
            larson_dir <= 0;
            larson <= 8'b00010000;

        end else begin
            if (&counter[24:0]) begin       // T = 2^25 * 10 ns = 0.33 s
                larson_dir <= larson[6] ? 0 : larson[1] ? 1 : larson_dir;

                if (larson_dir)
                    larson <= {larson[6:0], larson[7]};
                else
                    larson <= {larson[0], larson[7:1]};
            end

            if (&counter[5:0] && ~busy) begin
                case (instruction_step)
                    // *** KEYS ***
                    1:  {tm_cs, tm_rw}     <= {LOW, HIGH};
                    2:  {tm_latch, tm_out} <= {HIGH, C_READ}; // read mode
                    3:  {tm_latch, tm_rw}  <= {HIGH, LOW};

                    //  read back keys S1 - S8
                    4:  {keys[7], keys[3]} <= {tm_in[0], tm_in[4]};
                    5:  {tm_latch}         <= {HIGH};
                    6:  {keys[6], keys[2]} <= {tm_in[0], tm_in[4]};
                    7:  {tm_latch}         <= {HIGH};
                    8:  {keys[5], keys[1]} <= {tm_in[0], tm_in[4]};
                    9:  {tm_latch}         <= {HIGH};
                    10: {keys[4], keys[0]} <= {tm_in[0], tm_in[4]};
                    11: {tm_cs}            <= {HIGH};

                    // *** DISPLAY ***
                    12: {tm_cs, tm_rw}     <= {LOW, HIGH};
                    13: {tm_latch, tm_out} <= {HIGH, C_WRITE}; // write mode
                    14: {tm_cs}            <= {HIGH};

                    15: {tm_cs, tm_rw}     <= {LOW, HIGH};
                    16: {tm_latch, tm_out} <= {HIGH, C_ADDR}; // set addr 0 pos

                    17: display_digit(3'd7, S_1); // Digit 1
                    18: display_led(3'd0);        // LED 1

                    19: display_digit(3'd6, S_2); // Digit 2
                    20: display_led(3'd1);        // LED 2

                    21: display_digit(3'd5, S_3); // Digit 3
                    22: display_led(3'd2);        // LED 3

                    23: display_digit(3'd4, S_4); // Digit 4
                    24: display_led(3'd3);        // LED 4

                    25: display_digit(3'd3, S_5); // Digit 5
                    26: display_led(3'd4);        // LED 5

                    27: display_digit(3'd2, S_6); // Digit 6
                    28: display_led(3'd5);        // LED 6

                    29: display_digit(3'd1, S_7); // Digit 7
                    30: display_led(3'd6);        // LED 7

                    31: display_digit(3'd0, S_8); // Digit 8
                    32: display_led(3'd7);        // LED 8

                    33: {tm_cs}            <= {HIGH};

                    34: {tm_cs, tm_rw}     <= {LOW, HIGH};
                    35: {tm_latch, tm_out} <= {HIGH, C_DISP}; // display on, full bright
                    36: {tm_cs, instruction_step} <= {HIGH, 6'b0};

                endcase

                instruction_step <= instruction_step + 1;

            end else if (busy) begin
                // pull latch low next clock cycle after module has been
                // latched
                tm_latch <= LOW;
            end

            counter <= counter + 1;
        end
    end
endmodule