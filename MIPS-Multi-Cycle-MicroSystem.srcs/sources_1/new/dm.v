// 系统内存

`include "defines.v"

module dm_12k(
    input [`QBBus] addr,
    input [`QBBus] din,
    input we,
    input clk,
    output [`QBBus] dout,
    input wire DataSizeCtl,

    //与系统桥相连的线，除中断外全部整合到DM
    output MIPS_WrEn, 
    output [`QBBus] MIPS_Addr,
    input [`QBBus] Bridge_RD,
    output [`QBBus] MIPS_DataOut
    );


    wire InnerMemWrEn,IsBridgeAddr;
    assign IsBridgeAddr= (addr[31:8]==24'h0000_7F);
    assign MIPS_Addr=addr; //访问外设地址直接输出
    assign MIPS_DataOut=din; //外设写数据直接输出，对外设只实现LW/SW，不实现LB/SB
    assign MIPS_WrEn= we && IsBridgeAddr; //地址前缀为外设地址且有写使能时才向系统桥发使能
    assign InnerMemWrEn= we && !IsBridgeAddr; //内部内存写使能

    reg [`BBus] dm[1023:0]; //12287，1024方便调试
    wire [15:0] index;

    integer i;

    initial begin 
        for(i=0;i<1024;i=i+1)dm[i]=0;
    end

    assign index=addr[15:0];
    //Dout为小端序
    assign dout= (!IsBridgeAddr && DataSizeCtl==`DATASIZESIG_B) ? {{24{dm[index][7]}},dm[index]} :
                 (!IsBridgeAddr) ? {dm[index+3],dm[index+2],dm[index+1],dm[index]} :
                 IsBridgeAddr ? Bridge_RD :
                 32'heeeeeeee
                 ;

    always@ (posedge clk) begin
        if(InnerMemWrEn) begin //不是向外设发送数据就是向内存发送
            if(DataSizeCtl==`DATASIZESIG_B) begin
                dm[index]<=din[7:0];
            end else begin
                dm[index]<=din[7:0];
                dm[index+1]<=din[15:8];
                dm[index+2]<=din[23:16];
                dm[index+3]<=din[31:24];
            end
        end
    end

endmodule
