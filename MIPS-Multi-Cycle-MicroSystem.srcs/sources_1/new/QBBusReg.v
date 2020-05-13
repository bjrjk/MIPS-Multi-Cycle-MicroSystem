//通用模块——32位数据寄存器

`include "defines.v"

module QBBusReg(
    input clk,
    input [`QBBus] in,
    output reg[`QBBus] out
    );

    always@ (posedge clk) begin
        out<=in;
    end

endmodule
