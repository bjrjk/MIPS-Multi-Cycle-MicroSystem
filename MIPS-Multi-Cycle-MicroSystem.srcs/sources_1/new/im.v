//指令存储单元 —— 指令存储器 Instruction Memory

`include "defines.v"

module im_1k(
    input [11:0] addr,
    output [`QBBus] dout,
    input clk,en
    );

    reg [`BBus] im[1023:0];
    reg [9:0] index;

    always@ (posedge clk) begin
        if(en)index<=addr[9:0];
    end

    //Word文档中示例表明IM是大端序
    assign dout={im[index],im[index+1],im[index+2],im[index+3]};

    initial $readmemh("code.txt",im);
    
endmodule
