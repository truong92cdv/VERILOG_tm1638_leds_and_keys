module clk_divider #(
    parameter   clk_in  = 100_000_000,              // Input clock 100 MHz = 10 ns
    parameter   clk_out = 1                         // Output clock 1 Hz = 1 s
)(
    input       clk,
    output      clk_1Hz                                
);
    reg         clk_1Hz_r  = 0;
    integer     count       = 0;
    integer     half_cycle  = clk_in / clk_out / 2 - 1;
    
    always @(posedge clk) begin
        if (count == half_cycle) begin
            clk_1Hz_r <= ~clk_1Hz_r;
            count <= 0;
        end else
            count <= count + 1;
    end

    assign clk_1Hz = clk_1Hz_r;
    
endmodule
