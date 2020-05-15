module btnSigFilter(
    input clk,btnIn,
    output reg btnOut=1'b1
    );

    reg[31:0] cnts=32'd0;

    frequencyDivider #(
        .P ( 32'd100_000 ) //50Hz
        )
    insFrequencyDivider (
        .clk_in                  ( clk    ),
        .clk_out                 ( clk_out   )
    );

    always@ (posedge clk) begin
        if(!btnIn) begin
            cnts<=cnts+1;
            btnOut<=(cnts<=1);
        end else begin
            cnts<=0;
            btnOut<=1'b1;
        end
    end

endmodule
