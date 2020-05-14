//全部宏定义头文件

`include "defs/MIPSLite1.v"
`include "defs/MIPSLite2.v"
`include "defs/MIPSLite3.v"

`define t 1'b1
`define f 1'b0

`define QBBus 31:0 // Quad Byte Bus
`define DBBus 15:0 // Double Byte Bus
`define BBus 7:0 // Byte Bus 

//ALU控制信号宏定义
`define ALUSIG_ADD 0
`define ALUSIG_SUB 1
`define ALUSIG_OR 2
`define ALUSIG_LUI 3
`define ALUSIG_SLT 4

//译码器至控制器指令信号线对应指令下标宏定义
`define CTLSIG_NOP 0
`define CTLSIG_ADDU 1
`define CTLSIG_SUBU 2
`define CTLSIG_ORI 3
`define CTLSIG_LW 4
`define CTLSIG_SW 5
`define CTLSIG_BEQ 6
`define CTLSIG_LUI 7
`define CTLSIG_J 8
`define CTLSIG_ADDI 9
`define CTLSIG_ADDIU 10
`define CTLSIG_SLT 11
`define CTLSIG_JAL 12
`define CTLSIG_JR 13
`define CTLSIG_LB 14
`define CTLSIG_SB 15
`define CTLSIG_ERET 16
`define CTLSIG_MFC0 17
`define CTLSIG_MTC0 18

//寄存器写目的控制信号宏定义
`define REGWRDSTSIG_RT 0
`define REGWRDSTSIG_RD 1
`define REGWRDSTSIG_GPR_RA 2

//位拓展器控制信号宏定义
`define EXTSIG_ZERO 0
`define EXTSIG_SIGN 1

//回写控制信号宏定义
`define WRBACKSIG_ALU 0
`define WRBACKSIG_MEM 1
`define WRBACKSIG_PC 2
`define WRBACKSIG_CP0 3

//ALU数据源控制信号宏定义
`define ALUSRCSIG_GPR 0
`define ALUSRCSIG_EXT 1

//数据大小控制信号宏定义
`define DATASIZESIG_W 0
`define DATASIZESIG_B 1

//多周期CPU控制器阶段宏定义
`define STAGE_IF 0
`define STAGE_DCDRF 1
`define STAGE_EXE 2
`define STAGE_MEM 3
`define STAGE_WB 4
`define STAGE_INT 5

//多周期CPU下地址逻辑控制信号宏定义
`define NAFLSIG_PCNext 0
`define NAFLSIG_BEQ 1
`define NAFLSIG_J 2
`define NAFLSIG_JAL 3
`define NAFLSIG_JR 4
`define NAFLSIG_INT 5
`define NAFLSIG_EPC 6