`timescale 1ps / 1ps

module SIM();

    reg clk=1,rst=1;

    mips insMIPS(
    .clk(clk),
    .rst(rst)
    );

    initial forever #1 clk=~clk;
    initial #4 rst=0;
    initial #3000 $stop;

endmodule
