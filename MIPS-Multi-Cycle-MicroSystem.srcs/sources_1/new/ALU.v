//指令执行单元 —— 算术逻辑单元 Arithmetic and Logic Unit

`include "defines.v"

module ALU(
    input [3:0] ALUCtl,
    input [`QBBus] A,B,
    output reg [`QBBus] C,
    output OF,
    output wire zero
    );

    assign OF= (A[31]==B[31])&&(C[31]!=A[31]);
    assign zero= (C==0);

    always@ (*) begin
        case(ALUCtl)
            `ALUSIG_ADD:C=A+B;
            `ALUSIG_SUB:C=A-B;
            `ALUSIG_OR:C=A|B;
            `ALUSIG_LUI:C={B[15:0],16'd0};
            `ALUSIG_SLT:C=A<B;
            default:C=A+B;
        endcase
    end

endmodule
