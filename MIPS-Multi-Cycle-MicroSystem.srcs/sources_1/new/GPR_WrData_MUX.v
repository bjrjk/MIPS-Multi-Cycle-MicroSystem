//读寄存器单元 —— WrBack信号多路选择器 WrBackCtl_MUX

`include "defines.v"

module GPR_WrData_MUX(
    input [1:0] WrBackCtl,
    input [`QBBus] ALU,MEM,PC,
    output reg [`QBBus] out
    );

    always@ (*) begin
        case(WrBackCtl)
            `WRBACKSIG_ALU:out=ALU;
            `WRBACKSIG_MEM:out=MEM;
            `WRBACKSIG_PC:out=PC;
            default:out=ALU;
        endcase
    end

endmodule
