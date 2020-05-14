//指令存储单元 —— 指令存储器 Instruction Memory

`include "defines.v"

module im_8k(
    input [`QBBus] addr,
    output [`QBBus] dout,
    input clk,en
    );

    reg [`BBus] im[8191:0];
    reg [15:0] index;

    always@ (posedge clk) begin
        if(en)index<=addr[15:0]-16'h3000;
    end

    //Word文档中示例表明IM是大端序
    assign dout={im[index],im[index+1],im[index+2],im[index+3]};

    initial $readmemh("text.txt",im);
    initial $readmemh("ktext.exception.txt",im,16'h1180);
    
endmodule
