// reg_mux #(.WIDTH(), .PIPELINE(), .RESET_TYPE()) INSTANCE_NAME(.in(), .out(), .clk(), .ce(), .rst())
module reg_mux(in,out,clk,ce,rst);
parameter WIDTH=18;
parameter PIPELINE=0; 
parameter RESET_TYPE="SYNC"; //or ASYNC
input[WIDTH-1:0] in;
input clk,ce,rst;
output reg[WIDTH-1:0] out;
generate
	if(PIPELINE && RESET_TYPE=="SYNC") begin
		always @(posedge clk) begin
			if(rst) begin
				out<=0;
			end
			else if(ce) begin
				out<=in;
			end
		end
	end
endgenerate
generate
	if(PIPELINE && RESET_TYPE=="ASYNC") begin
		always @(posedge clk or posedge rst) begin
			if (rst) begin
				out<=0;
			end
			else if (ce) begin
				out<=in;
			end
		end
	end
endgenerate
generate
	if(PIPELINE==0) begin
		always @(*) begin
			out=in;
		end
	end
endgenerate
endmodule