//指令形成单元 —— 下地址形成逻辑 Next Address Formulation Logic

`include "defines.v"

module NAFL(
    input [`QBBus] addr,
    output reg [`QBBus] nextAddr,
    input [2:0] NAFLCtl,
    input beqZero,
    input [`DBBus] beqShift, // beq指令，16比特左移两位后变18比特再符号拓展加到PC
    input [25:0] jPadding, // j和jal指令，26比特左移两位后变28比特置PC低位
    input [`QBBus] jrAddr, // jr指令从$ra直接读入的32位地址
    output [`QBBus] nextInstAddr
    );

    assign nextInstAddr = addr+4;

    /*
        在取指阶段，产生的下地址统一为PC+4。
        在执行阶段，会产生跳转指令。此时PC的值已由PC变为PC+4，所以只需做增补量。
        这点与单周期CPU非常不同，需要特别注意！
    */

    always@ (*) begin
        if(NAFLCtl==`NAFLSIG_BEQ&&beqZero)nextAddr=addr+{{14{beqShift[15]}},beqShift,2'b00};
        else if(NAFLCtl==`NAFLSIG_BEQ)nextAddr=addr;
        else if(NAFLCtl==`NAFLSIG_J||NAFLCtl==`NAFLSIG_JAL)nextAddr={addr[31:28],jPadding,2'b00};
        else if(NAFLCtl==`NAFLSIG_JR)nextAddr=jrAddr;
        else nextAddr=nextInstAddr;
    end

endmodule
