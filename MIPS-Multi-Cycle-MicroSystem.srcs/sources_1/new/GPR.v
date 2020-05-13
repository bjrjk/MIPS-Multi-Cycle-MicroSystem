//读寄存器单元 —— 通用寄存器组 General Purpose Register

`include "defines.v"

module GPR(
    input clk,WrEn,OFWrEn,OFFlag,
    input [4:0] RdAddr1,RdAddr2,WrAddr,
    input [`QBBus] WrData,
    output reg [`QBBus] RdData1,RdData2
    );

    reg [`QBBus] regArr [`QBBus];

    initial regArr[0]=0;

    always @(*) begin
        if(RdAddr1!=0)RdData1=regArr[RdAddr1];
        else RdData1=0;
        if(RdAddr2!=0)RdData2=regArr[RdAddr2];
        else RdData2=0;
    end

    always @(posedge clk) begin
        if(WrEn&&WrAddr!=0)regArr[WrAddr]<=WrData;
        if(OFWrEn)regArr[30][0]<=OFFlag;
    end

endmodule
