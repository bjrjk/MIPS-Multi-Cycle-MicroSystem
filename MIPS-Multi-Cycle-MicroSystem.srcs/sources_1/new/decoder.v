//指令译码单元 —— 译码器 Decoder

`include "defines.v"

module Decoder(
    input [`QBBus] Inst,
    output wire [`QBBus] DecInstBus,
    output wire [4:0] rs,rt,rd,shamt,
    output wire [`DBBus] imm,
    output wire [25:0] tgtAddr
    );

    wire [5:0] opcode,funct;
    reg [5:0] DecInstIndex;
    assign opcode=Inst[31:26];
    assign funct=Inst[5:0];
    assign rs=Inst[25:21];
    assign rt=Inst[20:16];
    assign rd=Inst[15:11];
    assign shamt=Inst[10:6];
    assign imm=Inst[15:0];
    assign tgtAddr=Inst[25:0];
    assign DecInstBus=32'd1<<DecInstIndex;

    always@ (*) begin
        case(opcode)
            `OPCODE_SPECIAL: begin
                case(funct)
                    `FUNCT_ADDU: DecInstIndex=(shamt==0)?(`CTLSIG_ADDU):(`CTLSIG_NOP);
                    `FUNCT_SUBU: DecInstIndex=(shamt==0)?(`CTLSIG_SUBU):(`CTLSIG_NOP);
                    `FUNCT_SLT: DecInstIndex=(shamt==0)?(`CTLSIG_SLT):(`CTLSIG_NOP);
                    `FUNCT_JR: DecInstIndex=(rt==0&&rd==0)?(`CTLSIG_JR):(`CTLSIG_NOP);
                    default: DecInstIndex=`CTLSIG_NOP;
                endcase
            end
            `OPCODE_ORI: DecInstIndex=`CTLSIG_ORI;
            `OPCODE_LW: DecInstIndex=`CTLSIG_LW;
            `OPCODE_SW: DecInstIndex=`CTLSIG_SW;
            `OPCODE_BEQ: DecInstIndex=`CTLSIG_BEQ;
            `OPCODE_LUI: DecInstIndex=(rs==0)?(`CTLSIG_LUI):(`CTLSIG_NOP);
            `OPCODE_J: DecInstIndex=`CTLSIG_J;
            `OPCODE_ADDI: DecInstIndex=`CTLSIG_ADDI;
            `OPCODE_ADDIU: DecInstIndex=`CTLSIG_ADDIU;
            `OPCODE_JAL: DecInstIndex=`CTLSIG_JAL;
            `OPCODE_LB: DecInstIndex=`CTLSIG_LB;
            `OPCODE_SB: DecInstIndex=`CTLSIG_SB;
            default: DecInstIndex=`CTLSIG_NOP;
        endcase
    end

endmodule
