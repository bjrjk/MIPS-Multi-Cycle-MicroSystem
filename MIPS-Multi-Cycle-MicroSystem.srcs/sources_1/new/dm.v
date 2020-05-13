`include "defines.v"

module dm_1k(
    input [11:0] addr,
    input [`QBBus] din,
    input we,
    input clk,
    output [`QBBus] dout,
    input wire DataSizeCtl
    );

    reg [`BBus] dm[1023:0];
    wire [9:0] index;

    assign index=addr[9:0];
    //Dout为小端序
    assign dout= (DataSizeCtl==`DATASIZESIG_B) ? {{24{dm[index][7]}},dm[index]} :
                 {dm[index+3],dm[index+2],dm[index+1],dm[index]} ;

    always@ (posedge clk) begin
        if(we) begin
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
