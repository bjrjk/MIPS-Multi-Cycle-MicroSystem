`timescale 1ps / 1ps

`include "../../sources_1/new/defines.v"

module SIM();

    reg clk=1,rst=1;
    wire OutDev_WrEn;
    wire [`QBBus] OutDev_Data;
    reg [`QBBus] InDev_Data=0;
    
    /*SoC insSoC(
    .clk(clk),
    .rst(rst),
    .OutDev_WrEn(OutDev_WrEn),
    .OutDev_Data(OutDev_Data),
    .InDev_Data(InDev_Data)
    );*/

    main insMain(
    .clk(clk),
    .rst(rst)
    
    );

    initial forever #1 clk=~clk;
    initial #4 rst=0;
    initial #2500 InDev_Data=32'h80000000;
    initial #50000000 $stop;


endmodule
