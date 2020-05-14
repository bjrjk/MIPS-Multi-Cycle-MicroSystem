//MIPS CPU 主模块

`include "defines.v"

module mips(
    input clk,rst,
    output MIPS_WrEn,
    output [`QBBus] MIPS_Addr,
    input [`QBBus] Bridge_RD,
    output [`QBBus] MIPS_DataOut,
    input [5:0] Bridge_HWInt
    );

    //PC
    wire [`QBBus] PC_addr, NAFL_nextAddr;
    wire Controller_PCEn;
    PC insPC(
    .clk(clk),
    .rst(rst),
    .en(Controller_PCEn),
    .nextAddr(NAFL_nextAddr),
    .addr(PC_addr)
    );

    //NAFL
    wire ALU_zero;
    wire [2:0] Controller_NAFLCtl;
    wire [`QBBus] Decoder_DecInstBus;
    wire [`DBBus] Decoder_imm;
    wire [25:0] Decoder_tgtAddr;
    wire [`QBBus] GPR_RdData1;
    wire [`QBBus] CP0_EPCOut;
    NAFL insNAFL(
    .addr(PC_addr),
    .nextAddr(NAFL_nextAddr),
    .beqZero(ALU_zero),
    .beqShift(Decoder_imm),
    .jPadding(Decoder_tgtAddr),
    .jrAddr(GPR_RdData1),
    .NAFLCtl(Controller_NAFLCtl),
    .EPC(CP0_EPCOut)
    );

    //IM
    wire [`QBBus] IM_Inst;
    wire Controller_IMEn;
    im_8k insIM(
    .clk(clk),
    .en(Controller_IMEn),
    .addr(PC_addr),
    .dout(IM_Inst)
    );

    //Decoder
    wire [4:0] Decoder_rs,Decoder_rt,Decoder_rd,Decoder_shamt;
    Decoder insDecoder(
    .Inst(IM_Inst),
    .DecInstBus(Decoder_DecInstBus),
    .rs(Decoder_rs),
    .rt(Decoder_rt),
    .rd(Decoder_rd),
    .shamt(Decoder_shamt),
    .imm(Decoder_imm),
    .tgtAddr(Decoder_tgtAddr)
    );

    //Controller
    wire Controller_RegWrEn,Controller_RegOFWrEn,Controller_MemWrEn;
    wire [3:0] Controller_ALUCtl;
    wire [1:0] Controller_RegWrDstCtl,Controller_WrBackCtl;
    wire Controller_ALUSrcCtl, Controller_ExtCtl, Controller_DataSizeCtl;
    wire Controller_CP0WrEn,Controller_EPCWrEn,Controller_EXLSet,Controller_EXLClr;
    wire CP0_interrupt;
    Controller insController( 
    .clk(clk),
    .rst(rst),
    .DecInstBus(Decoder_DecInstBus),
    .PCEn(Controller_PCEn),
    .IMEn(Controller_IMEn),
    .RegWrEn(Controller_RegWrEn),
    .RegOFWrEn(Controller_RegOFWrEn),
    .MemWrEn(Controller_MemWrEn),
    .ALUCtl(Controller_ALUCtl),
    .RegWrDstCtl(Controller_RegWrDstCtl),
    .WrBackCtl(Controller_WrBackCtl),
    .ALUSrcCtl(Controller_ALUSrcCtl), 
    .ExtCtl(Controller_ExtCtl),
    .DataSizeCtl(Controller_DataSizeCtl),
    .NAFLCtl(Controller_NAFLCtl),
    .CP0WrEn(Controller_CP0WrEn),
    .EPCWrEn(Controller_EPCWrEn),
    .EXLSet(Controller_EXLSet),
    .EXLClr(Controller_EXLClr),
    .interrupt(CP0_interrupt)
    );

    //协处理器CP0
    wire [`QBBus] GPR_RdData2;
    wire [`QBBus] CP0_DataOut;
    wire [`QBBus] PCDelayOut_out;
    CP0 insCP0(
    .clk(clk),
    .rst(rst),
    .WrEn(Controller_CP0WrEn),
    .addr(Decoder_rd),
    .DataIn(GPR_RdData2),
    .DataOut(CP0_DataOut),
    .EPCWrEn(Controller_EPCWrEn),
    .EPCIn(PCDelayOut_out), //EPC入总线，已更改，待仿真验证
    .EPCOut(CP0_EPCOut), //EPC出总线
    .HWInt(Bridge_HWInt),
    .EXLSet(Controller_EXLSet),
    .EXLClr(Controller_EXLClr), //置1 SR的EXL，清0 SR的EXL
    .interrupt(CP0_interrupt) //CPU中断信号
    );

    //GPR_WrAddr_MUX
    wire [4:0] GPR_WrAddr_MUX_out;
    GPR_WrAddr_MUX insGPR_WrAddr_MUX(
    .RegWrDstCtl(Controller_RegWrDstCtl),
    .rt(Decoder_rt),
    .rd(Decoder_rd),
    .out(GPR_WrAddr_MUX_out)
    );

    //多周期CPU——处理PC延迟回写寄存器——JAL和中断使用
    QBBusReg insPCDelayOut(
    .clk(clk),
    .in(PC_addr),
    .out(PCDelayOut_out)
    );

    //微系统——处理MFC0延迟回写寄存器
    wire [`QBBus] MFC0Out_out;
    QBBusReg insMFC0Out(
    .clk(clk),
    .in(CP0_DataOut),
    .out(MFC0Out_out)
    );

    //GPR_WrData_MUX
    wire [`QBBus] GPR_WrData_MUX_out;
    wire [`QBBus] ALUOut_out,DMReg_out;
    GPR_WrData_MUX insGPR_WrData_MUX(
    .WrBackCtl(Controller_WrBackCtl),
    .ALU(ALUOut_out),
    .MEM(DMReg_out),
    .PC(PCDelayOut_out),
    .CP0(MFC0Out_out),
    .out(GPR_WrData_MUX_out)
    );

    //GPR
    wire ALU_OF;
    GPR insGPR(
    .clk(clk),
    .WrEn(Controller_RegWrEn),
    .OFWrEn(Controller_RegOFWrEn),
    .OFFlag(ALU_OF),
    .RdAddr1(Decoder_rs),
    .RdAddr2(Decoder_rt),
    .WrAddr(GPR_WrAddr_MUX_out),
    .WrData(GPR_WrData_MUX_out),
    .RdData1(GPR_RdData1),
    .RdData2(GPR_RdData2)
    );

    //Ext
    wire [`QBBus] Ext_ExtImm;
    Ext insExt(
    .ExtCtl(Controller_ExtCtl),
    .imm(Decoder_imm),
    .ExtImm(Ext_ExtImm)
    );

    //ALUSrc_MUX
    wire [`QBBus] ALUSrc_MUX_out;
    ALUSrc_MUX insALUSrc_MUX(
    .ALUSrcCtl(Controller_ALUSrcCtl),
    .GPRData(GPR_RdData2),
    .ExtData(Ext_ExtImm),
    .out(ALUSrc_MUX_out)
    );

    //Multi-Cycle Path Register A
    wire [`QBBus] A_out;
    QBBusReg insA(
    .clk(clk),
    .in(GPR_RdData1),
    .out(A_out)
    );

    //Multi-Cycle Path Register B
    wire [`QBBus] B_out;
    QBBusReg insB(
    .clk(clk),
    .in(ALUSrc_MUX_out),
    .out(B_out)
    );

    //ALU
    wire [`QBBus] ALU_C;
    ALU insALU(
    .ALUCtl(Controller_ALUCtl),
    .A(A_out),
    .B(B_out),
    .C(ALU_C),
    .OF(ALU_OF),
    .zero(ALU_zero)
    );

    //Multi-Cycle Path Register ALUOut
    QBBusReg insALUOut(
    .clk(clk),
    .in(ALU_C),
    .out(ALUOut_out)
    );

    //DM
    wire [`QBBus] DM_dout;
    dm_12k insDM(
    .addr(ALUOut_out),
    .din(GPR_RdData2),
    .we(Controller_MemWrEn),
    .clk(clk),
    .dout(DM_dout),
    .DataSizeCtl(Controller_DataSizeCtl),
    .MIPS_WrEn(MIPS_WrEn),   //**注意检查从DM到系统桥再到各外设应该读没有时钟延迟，写只有一个：和读普通内存相同**
    .MIPS_Addr(MIPS_Addr),
    .Bridge_RD(Bridge_RD),
    .MIPS_DataOut(MIPS_DataOut)
    );

    //Multi-Cycle Path Register DMReg
    QBBusReg DMReg(
    .clk(clk),
    .in(DM_dout),
    .out(DMReg_out)
    );

endmodule
