-- Processador MIPS Multiciclo
-- 
-- Datapath
--
-- Autor	: Gabriel Gutierrez P. Soares
-- Data	: 03 de agosto de 2018
--
-- Minicurso FPGA
-- Professores: Marcos Meira, Joao Vitor
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity datapath is
port (
	CLK		: in  STD_LOGIC;
	RST 		: in  STD_LOGIC;
	ReadData : in  STD_LOGIC_VECTOR(31 downto 0);
	WriteData: out STD_LOGIC_VECTOR(31 downto 0);
	MemAddr 	: out STD_LOGIC_VECTOR(31 downto 0);
	Opcode	: out STD_LOGIC_VECTOR( 5 downto 0);
	Funct		: out STD_LOGIC_VECTOR( 5 downto 0);
	PCEn		: in  STD_LOGIC;
	IorD		: in  STD_LOGIC;
	IRWrite	: in  STD_LOGIC;
	RegDst	: in  STD_LOGIC;
	MemToReg	: in  STD_LOGIC;
	RegWrite	: in  STD_LOGIC;
	ALUSrcA	: in  STD_LOGIC;
	ALUSrcB	: in  STD_LOGIC_VECTOR(1 downto 0);
	ALUControl:in  STD_LOGIC_VECTOR(2 downto 0);
	ALUZero	: out STD_LOGIC;
	PCSrc		: in  STD_LOGIC_VECTOR(1 downto 0)
);
end datapath;

architecture multicycle of datapath is
	component dpt_reg
	port (
		CLK: in  STD_LOGIC;
		RST: in  STD_LOGIC;
		EN	: in  STD_LOGIC;
		D	: in  STD_LOGIC_VECTOR(31 downto 0);
		Q	: out STD_LOGIC_VECTOR(31 downto 0)
	);
	end component;
	
	component dpt_mux2_5b
	port (
		D0, D1: in  STD_LOGIC_VECTOR(4 downto 0);
		sel	: in  STD_LOGIC;
		Y		: out STD_LOGIC_VECTOR(4 downto 0)
	);
	end component;
	
	component dpt_mux2
	port (
		D0, D1: in  STD_LOGIC_VECTOR(31 downto 0);
		Sel	: in  STD_LOGIC;
		Y		: out STD_LOGIC_VECTOR(31 downto 0)
	);
	end component;
	
	component dpt_regfile
	port (
		CLK, WE3		: in  STD_LOGIC;
		A1, A2, A3	: in  STD_LOGIC_VECTOR(4 downto 0);
		WD3			: in  STD_LOGIC_VECTOR(31 downto 0);
		RD1, RD2		: out STD_LOGIC_VECTOR(31 downto 0)
	);
	end component;
	
	component dpt_signext
	port (
		A: in  STD_LOGIC_VECTOR(15 DOWNTO 0);
		Y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	end component;

	component dpt_sl2
	port (
		A: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	end component;
	
	component dpt_pcsl2
	port (
		A: in  STD_LOGIC_VECTOR(25 DOWNTO 0);
		Y: out STD_LOGIC_VECTOR(27 DOWNTO 0)
	);
	end component;
	
	component dpt_mux4
	port (
		D0, D1: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
		D2, D3: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Sel	: in  STD_LOGIC_VECTOR( 1 DOWNTO 0);
		Y		: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	end component;
	
	component dpt_alu
	port (
		A, B	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Ctrl	: IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
		Res	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Zero	: OUT STD_LOGIC
	);
	end component;
	
	signal Instr, Data 	: STD_LOGIC_VECTOR(31 downto 0);
	signal RegA3 			: STD_LOGIC_VECTOR( 4 downto 0);
	signal RegWD3			: STD_LOGIC_VECTOR(31 downto 0);
	signal RegD1, RegD2	: STD_LOGIC_VECTOR(31 downto 0);
	signal RegA, RegB		: STD_LOGIC_VECTOR(31 downto 0);
	signal Imm, ImmSL2	: STD_LOGIC_VECTOR(31 downto 0);
	signal SrcA, SrcB		: STD_LOGIC_VECTOR(31 downto 0);
	signal ALUResult		: STD_LOGIC_VECTOR(31 downto 0);
	signal ALUOut, PCJump: STD_LOGIC_VECTOR(31 downto 0);
	signal PCNext, PC		: STD_LOGIC_VECTOR(31 downto 0);
	
begin
	
	instrReg: dpt_reg port map (
		CLK, RST, IRWrite, ReadData, Instr
	);
	
	dataReg: dpt_reg port map (
		CLK, RST, '1', ReadData, Data
	);
	
	Opcode <= Instr(31 downto 26);
	Funct  <= Instr( 5 downto 0);
	
	regA3Mux: dpt_mux2_5b port map (
		Instr(20 downto 16), Instr(15 downto 11), RegDst, RegA3
	);
	
	regWD3Mux: dpt_mux2 port map (
		ALUOut, Data, MemToReg, RegWD3
	);
	
	regFile: dpt_regfile port map (
		CLK, RegWrite,
		Instr(25 downto 21), Instr(20 downto 16), RegA3, -- A1, A2, A3
		RegWD3, RegD1, RegD2
	);
	
	rd1Reg: dpt_reg port map (
		CLK, RST, '1', RegD1, RegA
	);
	
	rd2Reg: dpt_reg port map (
		CLK, RST, '1', RegD2, RegB
	);
	
	WriteData <= RegB;
	
	signExt: dpt_signext port map (
		Instr(15 downto 0), Imm
	);
	
	immShift2: dpt_sl2 port map (
		Imm, ImmSL2
	);
	
	srcAMux: dpt_mux2 port map (
		PC, RegA, ALUSrcA, SrcA
	);
	
	srcBMux: dpt_mux4 port map (
		RegB, X"00000004", Imm, ImmSL2,
		ALUSrcB, SrcB
	);
	
	alu: dpt_alu port map (
		SrcA, SrcB, ALUControl, ALUResult, ALUZero
	);
	
	aluReg: dpt_reg port map (
		CLK, RST, '1', ALUResult, ALUOut
	);
	
	pcShift2: dpt_pcsl2 port map (
		Instr(25 downto 0), PCJump(27 downto 0)
	);
	
	PCJump(31 downto 28) <= PC(31 downto 28);
	
	pcMux: dpt_mux4 port map (
		ALUResult, ALUOut, PCJump, X"00000000",
		PCSrc, PCNext
	);
	
	pcReg: dpt_reg port map (
		CLK, RST, PCEn, PCNext, PC
	);
	
	memAdrMux: dpt_mux2 port map (
		PC, ALUOut, IorD, MemAddr
	);
	
	
end multicycle;