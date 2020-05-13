//主模块

`include "defines.v"

module mips(
    input clk,rst
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
    NAFL insNAFL(
    .addr(PC_addr),
    .nextAddr(NAFL_nextAddr),
    .beqZero(ALU_zero),
    .beqShift(Decoder_imm),
    .jPadding(Decoder_tgtAddr),
    .jrAddr(GPR_RdData1),
    .NAFLCtl(Controller_NAFLCtl)
    );
    
    //IM
    wire [`QBBus] IM_Inst;
    wire Controller_IMEn;
    im_1k insIM(
    .clk(clk),
    .en(Controller_IMEn),
    .addr(PC_addr[11:0]),
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
    .NAFLCtl(Controller_NAFLCtl)
    );

    //GPR_WrAddr_MUX
    wire [4:0] GPR_WrAddr_MUX_out;
    GPR_WrAddr_MUX insGPR_WrAddr_MUX(
    .RegWrDstCtl(Controller_RegWrDstCtl),
    .rt(Decoder_rt),
    .rd(Decoder_rd),
    .out(GPR_WrAddr_MUX_out)
    );

    //多周期CPU——处理JAL抢先回写寄存器
    wire [`QBBus] JALOut_out;
    QBBusReg insJALOut(
    .clk(clk),
    .in(PC_addr),
    .out(JALOut_out)
    );

    //GPR_WrData_MUX
    wire [`QBBus] GPR_WrData_MUX_out;
    wire [`QBBus] ALUOut_out,DMReg_out;
    GPR_WrData_MUX insGPR_WrData_MUX(
    .WrBackCtl(Controller_WrBackCtl),
    .ALU(ALUOut_out),
    .MEM(DMReg_out),
    .PC(JALOut_out),
    .out(GPR_WrData_MUX_out)
    );

    //GPR
    wire [`QBBus] GPR_RdData2;
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
    dm_1k insDM(
    .addr(ALUOut_out[11:0]),
    .din(GPR_RdData2),
    .we(Controller_MemWrEn),
    .clk(clk),
    .dout(DM_dout),
    .DataSizeCtl(Controller_DataSizeCtl)
    );

    //Multi-Cycle Path Register DMReg
    QBBusReg DMReg(
    .clk(clk),
    .in(DM_dout),
    .out(DMReg_out)
    );

endmodule
