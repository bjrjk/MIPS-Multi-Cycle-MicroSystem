module multiLED(
    input [4:0] NumA,NumB,NumC,NumD,NumE,NumF,NumG,NumH,
    input clk_in,rst,
    output [7:0] LED,LED2,
    output reg [7:0] Select=8'b01111111
    );
	 
	reg [4:0] Num=4'b0000;
	reg [2:0] LED_ID=0;
	wire clk_out;
    assign LED2=LED;
	
	frequencyDivider #(
        .P ( 32'd50_000 )
        )
    insFrequencyDivider (
        .clk_in                  ( clk_in    ),
        .clk_out                 ( clk_out   )
    );

	singleLED insSingleLED(
	.data(Num),
	.LEDout(LED)
	);
	
	always@ (posedge clk_out or posedge rst) begin
        if(rst) begin
            Select<=8'b01111111;
            Num<=4'b0000;
            LED_ID<=3'd0;
        end else begin
            Select<={Select[6:0],Select[7]};
            case(LED_ID)
                3'd0:Num<=NumA;
                3'd1:Num<=NumB;
                3'd2:Num<=NumC;
                3'd3:Num<=NumD;
                3'd4:Num<=NumE;
                3'd5:Num<=NumF;
                3'd6:Num<=NumG;
                3'd7:Num<=NumH;
            endcase
            LED_ID<=LED_ID+3'd1;
        end
	end
endmodule

