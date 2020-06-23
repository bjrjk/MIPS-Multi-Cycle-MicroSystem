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
            `ALUSIG_SLT:C= (A[31]==0&&B[31]==0) ? (A<B) : //都为正数，直接比
                            (A[31]==0&&B[31]==1) ? 0 : //A正B负，A肯定大于B
                            (A[31]==1&&B[31]==0) ? 1 : //A负B正，A肯定小于B
                            //(A[31]==1&&B[31]==1)，都为负数，化成绝对值后再比绝对值大的
                            ((~A)+1) > ((~B)+1)
                ;
            default:C=A+B;
        endcase
    end

endmodule
