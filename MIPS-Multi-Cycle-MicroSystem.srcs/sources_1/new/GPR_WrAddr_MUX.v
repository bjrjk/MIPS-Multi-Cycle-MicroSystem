//读寄存器单元 —— RegWrDst信号多路选择器 RegWrDstCtl_MUX

`include "defines.v"

module GPR_WrAddr_MUX(
    input [1:0] RegWrDstCtl,
    input [4:0] rt,rd,
    output reg [4:0] out
    );

    always@ (*) begin
        case(RegWrDstCtl)
            `REGWRDSTSIG_RT:out=rt;
            `REGWRDSTSIG_RD:out=rd;
            `REGWRDSTSIG_GPR_RA:out=5'd31;
            default:out=rt;
        endcase
    end

endmodule
