module digits(
    input               clk,
    input               rst,  
    output reg [3:0]    second_0,
    output reg [3:0]    second_1,
    output reg [3:0]    minute_0,
    output reg [3:0]    minute_1,
    output reg [3:0]    hour_0,
    output reg [3:0]    hour_1
);

    // second_0 reg control
    always @(posedge clk)
        if (rst)
            second_0 <= 0;
        else begin
            if (second_0 == 9)
                second_0 <= 0;
            else
                second_0 <= second_0 + 1;
        end

    // second_1 reg control
    always @(posedge clk)
        if (rst)
            second_1 <= 0;
        else if (second_0 == 9) begin
            if (second_1 == 5)
                second_1 <= 0;
            else
                second_1 <= second_1 + 1;
        end

    // minute_0 reg control
    always @(posedge clk)
        if (rst)
            minute_0 <= 0;
        else if (second_1 == 5 && second_0 == 9) begin
            if (minute_0 == 9)
                minute_0 <= 0;
            else
                minute_0 <= minute_0 + 1;
        end

    // minute_1 reg control
    always @(posedge clk)
        if (rst)
            minute_1 <= 0;
        else if (minute_0 == 9 && second_1 == 5 && second_0 == 9) begin
            if (minute_1 == 5)
                minute_1 <= 0;
            else
                minute_1 <= minute_1 + 1;
        end
    
    // hour_0 reg control
    always @(posedge clk)
        if (rst)
            hour_0 <= 0;
        else if (minute_1 == 5 && minute_0 == 9 && second_1 == 5 && second_0 == 9) begin
            if (hour_0 == 9)
                hour_0 <= 0;
            else
                hour_0 <= hour_0 + 1;
        end
    
    // hour_1 reg control
    always @(posedge clk)
        if (rst)
            hour_1 <= 0;
        else if (hour_0 == 9 && minute_1 == 5 && minute_0 == 9 && second_1 == 5 && second_0 == 9) begin
            if (hour_1 == 5)
                hour_1 <= 0;
            else
                hour_1 <= hour_1 + 1;
        end

endmodule
