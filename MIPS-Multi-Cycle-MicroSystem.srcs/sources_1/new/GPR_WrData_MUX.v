//读寄存器单元 —— WrBack信号多路选择器 WrBackCtl_MUX

`include "defines.v"

module GPR_WrData_MUX(
    input [1:0] WrBackCtl,
    input [`QBBus] ALU,MEM,PC,CP0,
    output reg [`QBBus] out
    );

    always@ (*) begin
        case(WrBackCtl)
            `WRBACKSIG_ALU:out=ALU;
            `WRBACKSIG_MEM:out=MEM;
            `WRBACKSIG_PC:out=PC;
            `WRBACKSIG_CP0:out=CP0;
            default:out=ALU;
        endcase
    end

endmodule
