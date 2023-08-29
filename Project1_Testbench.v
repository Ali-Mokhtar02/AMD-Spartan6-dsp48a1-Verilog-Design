module Project1_tb();
reg RSTA,RSTB,RSTC,RSTD,RSTCARRYIN,RSTM,RSTP,RSTOPMODE;
reg CLK,CEA,CEB,CEC,CECARRYIN,CED,CEM,CEP,CEOPMODE,CARRYIN;
reg[17:0] A, B, D;
reg[47:0] C,PCIN;
reg[7:0] OPMODE;
wire[35:0] M;
wire[17:0] BCOUT;
wire CARRYOUT,CARRYOUTF;
wire[47:0] P,PCOUT;
DSP tb ( 
A,B,C,D,CARRYIN,M,P,CARRYOUT,CARRYOUTF,CLK,OPMODE,
CEA,CEB,CEC,CED,CECARRYIN,CEM,CEP,CEOPMODE,
RSTA,RSTB,RSTC,RSTD,RSTCARRYIN,RSTM,RSTP,RSTOPMODE,
BCOUT,PCIN,PCOUT
);

initial begin
	CLK=1;
	forever
		#5 CLK=~CLK;
end
initial begin
	//Test REST Function
	RSTA=1; RSTB=1; RSTC=1; RSTD=1; RSTCARRYIN=1; RSTM=1; RSTP=1; RSTOPMODE=1;
	A=$random; B=$random; C=$random; D=$random; PCIN=$random; OPMODE=$random;
	CARRYIN=$random; CEA=$random; CEB=$random; CEC=$random; CECARRYIN=$random;
	CED=$random; CEM=$random; CEP=$random; CEOPMODE=$random;
	repeat(5)
		@(negedge CLK);
	//Test DSP Operation With Clock Enables High
	RSTA=0; RSTB=0; RSTC=0; RSTD=0; RSTCARRYIN=0; RSTM=0; RSTP=0; RSTOPMODE=0;
	 CEA=1; CEB=1; CEC=1; CECARRYIN=1;
		CED=1; CEM=1; CEP=1; CEOPMODE=1;
	repeat(100) begin
		A=$random; B=$random; C=$random; D=$random; PCIN=$random; OPMODE=$random;
		CARRYIN=$random;
		@(negedge CLK);
	end
	// Test DSP Opereation With Clock Enables Randomized
	repeat(100) begin
		CEA=$random; CEB=$random; CEC=$random; CECARRYIN=$random;
		CED=$random; CEM=$random; CEP=$random; CEOPMODE=$random;
		A=$random; B=$random; C=$random; D=$random; PCIN=$random; OPMODE=$random;
		CARRYIN=$random;
		@(negedge CLK);
	end
	$stop;
end
endmodule
