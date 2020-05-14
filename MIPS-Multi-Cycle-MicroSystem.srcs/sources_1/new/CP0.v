//协处理器CP0 —— Co-Processor 0

`include "defines.v"
`define CP0_SR 12
`define CP0_CAUSE 13
`define CP0_EPC 14
`define CP0_PRID 15


module CP0(
    input clk,rst,WrEn,
    input [4:0] addr,
    input [`QBBus] DataIn,
    output reg [`QBBus] DataOut,

    input EPCWrEn,
    input [`QBBus] EPCIn, //EPC入总线
    output [`QBBus] EPCOut, //EPC出总线

    input [5:0] HWInt,
    input EXLSet,EXLClr, //置1 SR的EXL，清0 SR的EXL
    output interrupt //CPU中断信号
    );

    reg [5:0] IM=6'b000000;
    reg EXL=0,IE=0;
    wire [`QBBus] SR; //SR寄存器数据线
    reg [`QBBus] EPC; //EPC寄存器，不允许软件写
    wire [`QBBus] Cause; //Cause寄存器，不允许软件写
    wire [`QBBus] PrID; //PrID寄存器，不允许写

    assign SR={16'd0,IM,8'd0,EXL,IE};
    assign Cause={16'd0,HWInt,10'd0};
    assign PrID=32'h18041403; //CPU标识号

    assign EPCOut=EPC;
    assign interrupt= (|(HWInt & IM)) & IE & !EXL ;

    always@ (*) begin //寄存器数据输出
        case(addr)
            `CP0_SR:DataOut=SR;
            `CP0_CAUSE:DataOut=Cause;
            `CP0_EPC:DataOut=EPC;
            `CP0_PRID:DataOut=PrID;
            default:DataOut=32'd0;
        endcase
    end

    //软件写寄存器SR（IM和IE），其他寄存器软件不可写
    always@ (posedge clk or posedge rst) begin 
        if(rst) begin
            IM<=6'b000000; //屏蔽所有硬件中断
            IE<=0; //全局中断失能
        end else if(WrEn) begin
            if(addr==`CP0_SR) begin
                IM<=DataIn[15:10];
                IE<=DataIn[0];
            end
        end
    end

    //硬件写寄存器SR（EXL）
    always@ (posedge clk or posedge rst) begin 
        if(rst) begin
            EXL<=0; //默认允许中断
        end else if(EXLSet) begin
            EXL<=1; //禁止中断嵌套
        end else if(EXLClr) begin
            EXL<=0; //恢复允许中断
        end
    end

    //硬件写寄存器EPC
    always@ (posedge clk or posedge rst) begin 
        if(rst) begin
            EPC<=0;
        end else if(EPCWrEn) begin
            EPC<=EPCIn;
        end
    end

endmodule
