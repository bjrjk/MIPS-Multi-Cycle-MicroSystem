//SoC主模块

`include "defines.v"

module SoC(
    input clk,rst,
    output OutDev_WrEn,
    output [`QBBus] OutDev_Data,
    input [`QBBus] InDev_Data
    );

    wire MIPS_WrEn;
    wire [`QBBus] MIPS_Addr,Bridge_RD,MIPS_DataOut;
    wire [5:0] Bridge_HWInt;

    //MIPS CPU
    mips insMIPs(
    .clk(clk),
    .rst(rst),
    .MIPS_WrEn(MIPS_WrEn),
    .MIPS_Addr(MIPS_Addr),
    .Bridge_RD(Bridge_RD),
    .MIPS_DataOut(MIPS_DataOut),
    .Bridge_HWInt(Bridge_HWInt)
    );

    //系统桥
    wire Bridge_DEV1_WrEn;
    wire [3:0] Bridge_DEV_Addr;
    wire [`QBBus] Bridge_DEV_WD; //写给定时器、输出设备的输出数据；输入设备不留输出端口
    wire [`QBBus] TimeCounter_DataOut; //从定时器和输入设备的输入数据；输出设备不留输入端口
    wire TimeCounter_interrupt; //定时器中断输入
    Bridge insBridge(
    .clk(clk),
    .WrEn(MIPS_WrEn),
    .Addr(MIPS_Addr),
    .WD(MIPS_DataOut),
    .RD(Bridge_RD),
    .HWInt(Bridge_HWInt), //中断

    //定时器DEV1，输入设备DEV2，输出设备DEV3
    .DEV1_WrEn(Bridge_DEV1_WrEn),
    .DEV3_WrEn(OutDev_WrEn),
    .DEV_Addr(Bridge_DEV_Addr), //只写定时器的地址
    .DEV_WD(Bridge_DEV_WD), //写给定时器、输出设备的输出数据；输入设备不留输出端口
    .DEV1_RD(TimeCounter_DataOut),
    .DEV2_RD(InDev_Data), //从定时器和输入设备的输入数据；输出设备不留输入端口
    .DEV1_interrupt(TimeCounter_interrupt) //定时器中断输入
    );

    assign OutDev_Data= Bridge_DEV_WD;

    //定时器
    timeCounter insTimeCounter(
    .clk(clk),
    .rst(rst),
    .WrEn(Bridge_DEV1_WrEn),
    .addr(Bridge_DEV_Addr),
    .DataIn(Bridge_DEV_WD),
    .DataOut(TimeCounter_DataOut),
    .interrupt(TimeCounter_interrupt)
    );

endmodule
