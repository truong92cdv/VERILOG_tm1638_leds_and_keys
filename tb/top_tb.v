`timescale 1ns / 1ns

module top_tb();

    reg     clk;
    wire    tm_cs;
    wire    tm_clk;
    wire    tm_dio;

    top u_top (
        .clk(clk),
        .tm_cs(tm_cs),
        .tm_clk(tm_clk),
        .tm_dio(tm_dio)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

endmodule
