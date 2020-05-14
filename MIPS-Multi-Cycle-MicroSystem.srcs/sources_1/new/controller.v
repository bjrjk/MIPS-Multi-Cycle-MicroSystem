//指令译码单元 —— 控制器 Controller

`include "defines.v"

module Controller(
    input clk,rst,
    input [`QBBus] DecInstBus,
    output wire PCEn,IMEn,RegWrEn,RegOFWrEn,MemWrEn, //PC写使能，IM取新指令使能，寄存器写使能，寄存器溢出写使能，内存写使能
    output reg [3:0] ALUCtl, //ALU控制信号
    output reg [1:0] RegWrDstCtl,WrBackCtl, //寄存器写目标控制信号，回写控制信号
    output reg ALUSrcCtl, ExtCtl, DataSizeCtl, //ALU数据源控制信号，位拓展器控制信号，数据大小控制信号
    output reg [2:0] NAFLCtl=`NAFLSIG_PCNext, //NAFL下地址逻辑控制信号
    output reg CP0WrEn=0,EPCWrEn=0,EXLSet=0,EXLClr=0,
    input interrupt //中断
    );

    /*
        此处控制器的设计思想是，所有的**控制信号**(以Ctl结尾)，在整个指令执行过程中不会变。可延用单周期CPU设计。
        只有**使能信号**(以En结尾)在整个指令执行过程中根据阶段的不同会发生改变。此处是状态机需要考虑的问题。
        根据阶段的不同，设定不同的**阶段与**寄存器。处于什么阶段，对应的**阶段与**寄存器为1，其他**阶段与**寄存器为0。
        将其与原指令所对应应有的使能信号相与输出。同时单独使用一个always块根据指令类型不同进行状态转移。
    */
    reg [4:0] stage=`STAGE_IF;
    reg PCEnReg=1,IMEnReg=1,RegWrEnReg,RegOFWrEnReg,MemWrEnReg;
    wire StageIF,StageDCDRF,StageEXE,StageMEM,StageWB;

    assign StageIF= (stage==`STAGE_IF);
    assign StageDCDRF= (stage==`STAGE_DCDRF);
    assign StageEXE= (stage==`STAGE_EXE);
    assign StageMEM= (stage==`STAGE_MEM);
    assign StageWB= (stage==`STAGE_WB);
    assign StageINT= (stage==`STAGE_INT);

    //但凡是转移指令，必须抢先一步在执行EXE阶段就打开PC使能，否则下一条指令取指时会取到PC+4，而非转移的指令
    wire INST_JUMP;
    assign INST_JUMP=  DecInstBus[`CTLSIG_J] || DecInstBus[`CTLSIG_JAL] || DecInstBus[`CTLSIG_JR] || DecInstBus[`CTLSIG_BEQ];
    assign PCEn= StageIF && PCEnReg || //取指阶段PC+4
                StageEXE && INST_JUMP || //跳转指令的执行阶段
                StageDCDRF && DecInstBus[`CTLSIG_ERET] || //中断返回的译码阶段
                StageINT && interrupt //中断阶段且有中断
    ;
    assign IMEn= StageIF && IMEnReg ;
    assign MemWrEn= StageMEM && MemWrEnReg;
    assign RegWrEn= StageWB && RegWrEnReg;
    assign RegOFWrEn= StageWB && RegOFWrEnReg;


    always@ (*) begin //控制信号的组合逻辑电路
        ALUCtl=`ALUSIG_ADD;
        RegWrDstCtl=`REGWRDSTSIG_RT;
        WrBackCtl=`WRBACKSIG_ALU;
        ALUSrcCtl=`ALUSRCSIG_EXT;
        ExtCtl=`EXTSIG_SIGN;
        DataSizeCtl=`DATASIZESIG_W;
        NAFLCtl=`NAFLSIG_PCNext;
        CP0WrEn=`f;
        EXLClr=`f;
        if(DecInstBus[`CTLSIG_ADDU]) begin
            RegWrDstCtl=`REGWRDSTSIG_RD;
            ALUSrcCtl=`ALUSRCSIG_GPR;
        end else if(DecInstBus[`CTLSIG_SUBU]) begin
            ALUCtl=`ALUSIG_SUB;
            RegWrDstCtl=`REGWRDSTSIG_RD;
            ALUSrcCtl=`ALUSRCSIG_GPR;
        end else if(DecInstBus[`CTLSIG_ORI]) begin
            ALUCtl=`ALUSIG_OR;
            ExtCtl=`EXTSIG_ZERO;
        end else if(DecInstBus[`CTLSIG_LW]) begin
            WrBackCtl=`WRBACKSIG_MEM;
        end else if(DecInstBus[`CTLSIG_SW]) begin

        end else if(DecInstBus[`CTLSIG_BEQ]) begin
            ALUCtl=`ALUSIG_SUB;
            ALUSrcCtl=`ALUSRCSIG_GPR;
            NAFLCtl=`NAFLSIG_BEQ;
        end else if(DecInstBus[`CTLSIG_LUI]) begin
            ALUCtl=`ALUSIG_LUI;
        end else if(DecInstBus[`CTLSIG_J]) begin
            NAFLCtl=`NAFLSIG_J;
        end else if(DecInstBus[`CTLSIG_ADDI]) begin

        end else if(DecInstBus[`CTLSIG_ADDIU]) begin

        end else if(DecInstBus[`CTLSIG_SLT]) begin
            ALUCtl=`ALUSIG_SLT;
            RegWrDstCtl=`REGWRDSTSIG_RD;
            ALUSrcCtl=`ALUSRCSIG_GPR;
        end else if(DecInstBus[`CTLSIG_JAL]) begin
            RegWrDstCtl=`REGWRDSTSIG_GPR_RA;
            WrBackCtl=`WRBACKSIG_PC;
            NAFLCtl=`NAFLSIG_JAL;
        end else if(DecInstBus[`CTLSIG_JR]) begin
            NAFLCtl=`NAFLSIG_JR;
        end else if(DecInstBus[`CTLSIG_LB]) begin
            WrBackCtl=`WRBACKSIG_MEM;
            DataSizeCtl=`DATASIZESIG_B;
        end else if(DecInstBus[`CTLSIG_SB]) begin
            DataSizeCtl=`DATASIZESIG_B;
        end else if(DecInstBus[`CTLSIG_MFC0]) begin
            WrBackCtl=`WRBACKSIG_CP0;
        end else if(DecInstBus[`CTLSIG_MTC0]) begin
            CP0WrEn=`t;
        end else if(DecInstBus[`CTLSIG_ERET]) begin
            NAFLCtl=`NAFLSIG_EPC;
            EXLClr=`t;
        end else begin // DecInstBus[`CTLSIG_NOP] or Unexcepted Situations

        end

        if(StageIF)NAFLCtl=`NAFLSIG_PCNext; //原则：保证取指阶段下地址逻辑始终指向PC+4
        if(StageINT && interrupt)NAFLCtl=`NAFLSIG_INT;
    end

    always@ (*) begin //使能信号的组合逻辑电路
        PCEnReg=`t;
        IMEnReg=`t;
        RegWrEnReg=`t;
        RegOFWrEnReg=`f;
        MemWrEnReg=`f;
        if(DecInstBus[`CTLSIG_ADDU]) begin

        end else if(DecInstBus[`CTLSIG_SUBU]) begin

        end else if(DecInstBus[`CTLSIG_ORI]) begin

        end else if(DecInstBus[`CTLSIG_LW]) begin

        end else if(DecInstBus[`CTLSIG_SW]) begin
            RegWrEnReg=`f;
            MemWrEnReg=`t;
        end else if(DecInstBus[`CTLSIG_BEQ]) begin
            RegWrEnReg=`f;
        end else if(DecInstBus[`CTLSIG_LUI]) begin

        end else if(DecInstBus[`CTLSIG_J]) begin
            RegWrEnReg=`f;
        end else if(DecInstBus[`CTLSIG_ADDI]) begin
            RegOFWrEnReg=`t;
        end else if(DecInstBus[`CTLSIG_ADDIU]) begin

        end else if(DecInstBus[`CTLSIG_SLT]) begin

        end else if(DecInstBus[`CTLSIG_JAL]) begin

        end else if(DecInstBus[`CTLSIG_JR]) begin
            RegWrEnReg=`f;
        end else if(DecInstBus[`CTLSIG_LB]) begin

        end else if(DecInstBus[`CTLSIG_SB]) begin
            RegWrEnReg=`f;
            MemWrEnReg=`t;
        end else if(DecInstBus[`CTLSIG_MFC0]) begin

        end else if(DecInstBus[`CTLSIG_MTC0]) begin
            RegWrEnReg=`f;
        end else if(DecInstBus[`CTLSIG_ERET]) begin
            RegWrEnReg=`f;
        end else begin // DecInstBus[`CTLSIG_NOP] or Unexcepted Situations
            RegWrEnReg=`f;
        end
    end

    always@ (posedge clk or posedge rst) begin //状态转移时序逻辑
        if(rst)stage<=`STAGE_IF;
        else begin
            case(stage)
                `STAGE_IF: begin
                        EPCWrEn<=0;
                        EXLSet<=0;
                        stage<=`STAGE_DCDRF;
                    end
                `STAGE_DCDRF:
                    //直接跳转到中断
                    if(
                        DecInstBus[`CTLSIG_NOP] || DecInstBus[`CTLSIG_ERET] || DecInstBus[`CTLSIG_MTC0]
                    )
                        stage<=`STAGE_INT;
                    else if(
                        DecInstBus[`CTLSIG_MFC0]
                    )
                        stage<=`STAGE_WB;
                    //剩下的都跳转到执行
                    else 
                        stage<=`STAGE_EXE;
                `STAGE_EXE:
                    //跳转至访存阶段的指令
                    if(
                        DecInstBus[`CTLSIG_LW] || DecInstBus[`CTLSIG_SW] || DecInstBus[`CTLSIG_LB] ||
                        DecInstBus[`CTLSIG_SB]
                    )
                        stage<=`STAGE_MEM;
                    //跳转至回写阶段的指令
                    else if(
                        DecInstBus[`CTLSIG_ADDU] || DecInstBus[`CTLSIG_SUBU] || DecInstBus[`CTLSIG_ORI] ||
                        DecInstBus[`CTLSIG_LUI] || DecInstBus[`CTLSIG_ADDI] || DecInstBus[`CTLSIG_ADDIU] ||
                        DecInstBus[`CTLSIG_SLT] || DecInstBus[`CTLSIG_JAL]
                    )
                        stage<=`STAGE_WB;
                    //剩下的不论是正常不正常的指令全部跳转去中断
                    else
                        stage<=`STAGE_INT;
                `STAGE_MEM:
                    //跳转至回写阶段的指令
                    if(DecInstBus[`CTLSIG_LW] || DecInstBus[`CTLSIG_LB])
                        stage<=`STAGE_WB;
                    //剩下的跳转到中断
                    else 
                        stage<=`STAGE_INT;
                `STAGE_WB:stage<=`STAGE_INT;
                `STAGE_INT: begin
                        if(interrupt) begin
                            EPCWrEn<=1;
                            EXLSet<=1;
                        end
                        stage<=`STAGE_IF;
                    end
                default:stage<=`STAGE_IF;
            endcase
        end
    end

endmodule
