module DSP(A,B,C,D,CARRYIN,M,P,CARRYOUT,CARRYOUTF,CLK,OPMODE,
CEA,CEB,CEC,CED,CECARRYIN,CEM,CEP,CEOPMODE,
RSTA,RSTB,RSTC,RSTD,RSTCARRYIN,RSTM,RSTP,RSTOPMODE,
BCOUT,PCIN,PCOUT);

// PORT describtion
input[17:0] A, B, D;
input[47:0] C,PCIN;
input[7:0] OPMODE;
input CARRYIN,CLK,CEA,CEB,CEC,CECARRYIN,CED,CEM,CEP,CEOPMODE;
input RSTA,RSTB,RSTC,RSTD,RSTCARRYIN,RSTM,RSTP,RSTOPMODE;
output wire[35:0] M;
output wire[47:0] P,PCOUT;
output wire[17:0] BCOUT;
output CARRYOUT,CARRYOUTF;

// parameter declaration 
parameter A0REG=0;	//NUMBER OF PIPELINED REGISTERS
parameter A1REG=1; 
parameter B0REG=0;
parameter B1REG=1;
parameter CREG=1;
parameter DREG=1;
parameter MREG=1;
parameter PREG=1;
parameter CARRYINREG=1;
parameter CARRYOUTREG=1;
parameter OPMODEREG=1;
parameter CARRYINSEL="OPMODE5"; //3 possibilities( "OPMODE5","CARRYIN", other values set the mux output to zero)
parameter B_INPUT="DIRECT"; // 3 possibilities ( "DIRECT", "CASCADE", other values set the mux output to zero)
parameter RSTTYPE="ASYNC"; // 2 possibilities ("SYNC", "ASYNC")

// wire and reg defintions
wire[7:0] OPMODE_REG;
wire[17:0] D_REG;
reg[17:0] B0_IN;
wire[17:0] B0_REG;
reg[17:0] PRE_RESULT;
wire[17:0] B1_IN;
wire[17:0] B1_REG;
wire[17:0] A0_REG;
wire[17:0] A1_REG;
wire[35:0] Product_Result;
wire[35:0] M_REG;
reg[47:0] X_OUT;
reg[47:0] Z_OUT;
wire[48:0] Post_Result;
wire[47:0] C_REG;
reg Carry_IN; //result of carry cascade mux
wire CIN; 
wire Carry_Out_In;

// reg_mux_block module instantion
reg_mux #(.WIDTH(18), .PIPELINE(DREG), .RESET_TYPE(RSTTYPE)) DREG_INST(.in(D), .out(D_REG), .clk(CLK), .ce(CED), .rst(RSTD));
reg_mux #(.WIDTH(18), .PIPELINE(B0REG), .RESET_TYPE(RSTTYPE)) B0REG_INST(.in(B0_IN), .out(B0_REG), .clk(CLK), .ce(CEB), .rst(RSTB));
reg_mux #(.WIDTH(18), .PIPELINE(B1REG), .RESET_TYPE(RSTTYPE)) B1REG_INST(.in(B1_IN), .out(B1_REG), .clk(CLK), .ce(CEB), .rst(RSTB));
reg_mux #(.WIDTH(18), .PIPELINE(A0REG), .RESET_TYPE(RSTTYPE)) A0REG_INST(.in(A), .out(A0_REG), .clk(CLK), .ce(CEA), .rst(RSTA));
reg_mux #(.WIDTH(18), .PIPELINE(A1REG), .RESET_TYPE(RSTTYPE)) A1REG_INST(.in(A0_REG), .out(A1_REG), .clk(CLK), .ce(CEA), .rst(RSTA));
reg_mux #(.WIDTH(48), .PIPELINE(CREG), .RESET_TYPE(RSTTYPE)) CREG_INST(.in(C), .out(C_REG), .clk(CLK), .ce(CEC), .rst(RSTC));


reg_mux #(.WIDTH(36), .PIPELINE(MREG), .RESET_TYPE(RSTTYPE)) MREG_INST(.in(Product_Result), .out(M_REG), .clk(CLK), .ce(CEM), .rst(RSTM));
reg_mux #(.WIDTH(1), .PIPELINE(CARRYINREG), .RESET_TYPE(RSTTYPE)) CYIREG_INST(.in(Carry_IN), .out(CIN), .clk(CLK), .ce(CECARRYIN), .rst(RSTCARRYIN));
reg_mux #(.WIDTH(8), .PIPELINE(OPMODEREG), .RESET_TYPE(RSTTYPE)) OPMODEREG_INST(.in(OPMODE), .out(OPMODE_REG), .clk(CLK), .ce(CEOPMODE), .rst(RSTOPMODE));


reg_mux #(.WIDTH(1), .PIPELINE(CARRYOUTREG), .RESET_TYPE(RSTTYPE)) CYOREG_INST(.in(Carry_Out_In), .out(CARRYOUT), .clk(CLK), .ce(CECARRYIN), .rst(RSTCARRYIN));
reg_mux #(.WIDTH(48), .PIPELINE(PREG), .RESET_TYPE(RSTTYPE)) PREG_INST(.in(Post_Result), .out(P), .clk(CLK), .ce(CEP), .rst(RSTP));

// dsp logic behaviour

// Port B selection
always @(*) begin
	case(B_INPUT)
		"DIRECT": B0_IN=B;
		"CASCADE": B0_IN=BCOUT;
		default: B0_IN=0;
	endcase
end
//Pre adder behaviour
always @(*) begin
	if(OPMODE_REG[6])
		PRE_RESULT= D_REG - B0_REG;	
	else
		PRE_RESULT= D_REG + B0_REG;
end

// B1_IN Signal Assignment
assign B1_IN=(OPMODE_REG[4])? PRE_RESULT: B0_REG;

//Multiplier Assignment
assign Product_Result=B1_REG * A1_REG;
assign M=M_REG;

//Carry_In Behaviour
always @(*) begin
	case(CARRYINSEL)
		"CARRYIN": Carry_IN=CARRYIN;
		"OPMODE5": Carry_IN=OPMODE_REG[5];
		default: Carry_IN=0;
	endcase
end

//Multiplexer Z Behaviour
always @(*) begin
	case({ OPMODE_REG[3], OPMODE_REG[2]})
		0: Z_OUT=0;
		1: Z_OUT=PCIN;
		2: Z_OUT=P;
		3: Z_OUT=C_REG;
	endcase
end

//Multiplexer X Behaviour
always @(*) begin
	case( {OPMODE_REG[1], OPMODE_REG[0]})
		0: X_OUT=0;
		1: X_OUT={ {13{M_REG[35]}} , M_REG[34:0] }; //sign extension
 		2: X_OUT=P;
		3: X_OUT={D_REG[11:0], A1_REG, B1_REG};    
	endcase
end

//Post-Adder/Subtractor assingment 
assign Post_Result= ( OPMODE_REG[7] )? (Z_OUT-(X_OUT+CIN)) : (Z_OUT+X_OUT+CIN) ;

// Carry_Out_In assignment
assign Carry_Out_In=Post_Result[48];

//Duplicated and cascaded signals assignment
assign BCOUT= B1_REG;
assign CARRYOUTF= CARRYOUT;
assign PCOUT=P;

endmodule