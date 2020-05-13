//指令形成单元 —— 程序计数器 Program Counter

`include "defines.v"

module PC(
    input clk,rst,en,
    input [`QBBus] nextAddr,
    output reg [`QBBus] addr=32'h0000_3000
    );

    always@ (posedge clk or posedge rst) begin
        if(rst)addr<=32'h0000_3000; //异步复位到0x00003000
        else if(en)addr<=nextAddr;
    end

endmodule
