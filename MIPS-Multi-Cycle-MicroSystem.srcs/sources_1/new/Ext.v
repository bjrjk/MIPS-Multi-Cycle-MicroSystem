//指令执行单元 —— 位拓展器 Bit Extender

`include "defines.v"

module Ext(
    input ExtCtl,
    input [`DBBus] imm,
    output reg [`QBBus] ExtImm
    );

    always@ (*) begin
        case(ExtCtl)
            `EXTSIG_ZERO:ExtImm={16'd0,imm};
            `EXTSIG_SIGN:ExtImm={{16{imm[15]}},imm};
            default:ExtImm={16'd0,imm};
        endcase
    end

endmodule
