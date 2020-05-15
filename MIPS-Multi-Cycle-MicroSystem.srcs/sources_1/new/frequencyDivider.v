module frequencyDivider(
        input clk_in,
        output reg clk_out=1'b1
    );
	parameter P=32'd50_000;  //默认为1KHz
	reg [31:0]cnt=32'd0;
	always@ (posedge clk_in) begin
		if(cnt==P>>1) begin
			clk_out<=~clk_out;
			cnt<='b0;
		end else cnt<=cnt+'b1;
	end
endmodule