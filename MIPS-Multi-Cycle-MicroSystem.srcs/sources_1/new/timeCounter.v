//外设 —— 定时器 TimeCounter

`include "defines.v"

module timeCounter(
    input clk,rst,WrEn,
    input [3:0] addr,
    input [`QBBus] DataIn,
    output reg [`QBBus] DataOut,
    output wire interrupt
    );

    reg [`QBBus] CTRL=0,PRESET=0,COUNT=0;
    wire interruptWire,COUNTReload;
    assign interrupt= CTRL[3] && CTRL[2:1]==2'b00 && interruptWire;
    assign interruptWire= COUNT==0 ;
    assign COUNTReload= WrEn && addr[3:2]==2'b01;


    always@ (*) begin  //数据输出
        case(addr[3:2])
            2'b00:DataOut=CTRL;
            2'b01:DataOut=PRESET;
            2'b10:DataOut=COUNT;
            default:DataOut=32'heeeeeeee;
        endcase
    end

    always@ (posedge clk or posedge rst) begin //数据输入
        if(rst) begin
            CTRL<=0;
            PRESET<=0;
        end else if(WrEn) begin
            if(addr[3:2]==2'b00)CTRL[3:0]<=DataIn[3:0];
            else if(addr[3:2]==2'b01)PRESET<=DataIn;
        end
    end

    always@ (posedge clk or posedge rst) begin //计时功能，本课设使用模式0
        if(rst) COUNT<=0;
        else if(!CTRL[0] && COUNT==0 && WrEn) begin //只有停止状态下才允许重新加载计数器
            COUNT<=DataIn;
        end else if(CTRL[0]) begin
            if(COUNT==0) begin
                if(CTRL[2:1]==2'b01)COUNT<=PRESET;
            end else COUNT<=COUNT-1;
        end
    end


endmodule
