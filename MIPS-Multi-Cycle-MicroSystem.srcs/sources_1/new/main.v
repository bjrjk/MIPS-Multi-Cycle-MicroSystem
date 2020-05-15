`include "defines.v"

module main(
    input clk,rst,btn,
    output [7:0] LED,LED2,
    output [7:0] Select
    );

    wire OutDev_WrEn;
    wire [`QBBus] OutDev_Data;
    reg [`QBBus] outputData=0;
    reg [`QBBus] inputData=0;


    frequencyDivider #(
        .P ( 32'd50 ) //1Mhz
        )
    insFrequencyDivider (
        .clk_in                  ( clk    ),
        .clk_out                 ( clk_out   )
    );

    SoC insSoC(
    .clk(clk_out),
    .rst(~rst),
    .OutDev_WrEn(OutDev_WrEn),
    .OutDev_Data(OutDev_Data),
    .InDev_Data(inputData)
    );

    always@ (posedge clk_out) begin
        if(OutDev_WrEn)outputData<=OutDev_Data;
    end

    always@ (*) begin
        if(btn)inputData<=32'h00000000;
        else inputData<=32'h10000000;
    end


    multiLED u_multiLED(
        .clk_in(clk),
        .LED(LED),
        .LED2(LED2),
        .Select(Select),
        .NumA({1'b0,outputData[31:28]}),
        .NumB({1'b0,outputData[27:24]}),
        .NumC({1'b0,outputData[23:20]}),
        .NumD({1'b0,outputData[19:16]}),
        .NumE({1'b0,outputData[15:12]}),
        .NumF({1'b0,outputData[11:8]}),
        .NumG({1'b0,outputData[7:4]}),
        .NumH({1'b0,outputData[3:0]})
    );

endmodule
