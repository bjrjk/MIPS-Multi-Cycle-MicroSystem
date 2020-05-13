//指令执行单元 —— ALUSrc信号多路选择器 ALUSrcCtl_MUX

`include "defines.v"

module ALUSrc_MUX(
    input ALUSrcCtl,
    input [`QBBus] GPRData,ExtData,
    output reg [`QBBus] out
    );

    always@ (*) begin
        case(ALUSrcCtl)
            `ALUSRCSIG_GPR:out=GPRData;
            `ALUSRCSIG_EXT:out=ExtData;
            default:out=GPRData;
        endcase
    end

endmodule
