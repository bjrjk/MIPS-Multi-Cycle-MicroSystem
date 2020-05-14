//外设 —— 系统桥 Bridge

`include "defines.v"

module Bridge(
    input clk,WrEn,
    input [`QBBus] Addr,WD, //与CPU相连的总线
    output [`QBBus] RD,
    output [5:0] HWInt, //中断

    //定时器DEV1，输入设备DEV2，输出设备DEV3
    output DEV1_WrEn,DEV3_WrEn,
    output [3:0] DEV_Addr, //只写定时器的地址
    output [`QBBus] DEV_WD, //写给定时器、输出设备的输出数据；输入设备不留输出端口
    input [`QBBus] DEV1_RD,DEV2_RD, //从定时器和输入设备的输入数据；输出设备不留输入端口
    input DEV1_interrupt //定时器中断输入
    );

    wire DEV1_RdEn,DEV2_RdEn;
    assign DEV1_RdEn= Addr[31:4]==28'h0000_7F0;
    assign DEV2_RdEn= Addr[31:4]==28'h0000_7F1;

    assign DEV1_WrEn= WrEn && Addr[31:4]==28'h0000_7F0;
    assign DEV3_WrEn= WrEn && Addr[31:4]==28'h0000_7F2;
    assign DEV_Addr=Addr[3:0];
    assign DEV_WD=WD;

    assign RD= DEV1_RdEn ? DEV1_RD :
                DEV2_RdEn ? DEV2_RD :
                32'heeeeeeee;

    assign HWInt[0]=DEV1_interrupt;
    assign HWInt[5:1]=5'b00000;

endmodule
