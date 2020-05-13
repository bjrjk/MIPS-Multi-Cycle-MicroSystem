`timescale 1ps / 1ps

`include "../../sources_1/new/defines.v"

module timeCounterSIM(

    );


    reg clk=1,rst=1,WrEn=0;
    reg [3:0] addr=0;
    reg [`QBBus] DataIn;
    wire [`QBBus] DataOut;
    wire interrupt;

    timeCounter insTimeCounter(
    .clk(clk),
    .rst(rst),
    .WrEn(WrEn),
    .addr(addr),
    .DataIn(DataIn),
    .DataOut(DataOut),
    .interrupt(interrupt)
    );

    initial forever #1 clk=~clk;
    initial #100 $stop;

    initial begin
        #2
        rst=0;
        WrEn=1;
        addr=4'b0100;
        DataIn=32'd4;
        #2
        WrEn=1;
        addr=4'b0000;
        DataIn=4'b1001;
        #2
        WrEn=0;
        #10
        WrEn=1;
        addr=4'b0000;
        DataIn=4'b0000;
        #2
        WrEn=1;
        addr=4'b0100;
        DataIn=32'd4;
        #2
        WrEn=1;
        addr=4'b0000;
        DataIn=4'b1001;
        #2
        WrEn=0;
    end

endmodule
