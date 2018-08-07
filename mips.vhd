-- Processador MIPS Multiciclo
-- 
-- Bloco do processador
--
-- Autor	: Gabriel Gutierrez P. Soares
-- Data	: 03 de agosto de 2018
--
-- Minicurso FPGA
-- Professores: Marcos Meira, Victor
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mips is
port (
    CLK			: in  STD_LOGIC;
    RST 			: in  STD_LOGIC;
    ReadData 	: in  STD_LOGIC_VECTOR(31 downto 0);
    WriteData	: out STD_LOGIC_VECTOR(31 downto 0);
    MemAddr 	: out STD_LOGIC_VECTOR(31 downto 0);
    MemWrite	: out STD_LOGIC;
	 CtrlState	: out STD_LOGIC_VECTOR(3 downto 0)
);
end mips;

architecture multicycle of mips is

    component control_unit
    port (
        CLK			: in  STD_LOGIC;
        RST 		: in  STD_LOGIC;
        MemWrite	: out STD_LOGIC;
        Opcode		: in  STD_LOGIC_VECTOR(5 downto 0);
        Funct		: in  STD_LOGIC_VECTOR(5 downto 0);
        PCEn		: out STD_LOGIC;
        IorD		: out STD_LOGIC;
        IRWrite		: out STD_LOGIC;
        RegDst		: out STD_LOGIC;
        MemToReg	: out STD_LOGIC;
        RegWrite	: out STD_LOGIC;
        ALUSrcA		: out STD_LOGIC;
        ALUSrcB		: out STD_LOGIC_VECTOR(1 downto 0);
        ALUControl	: out STD_LOGIC_VECTOR(2 downto 0);
        ALUZero		: in  STD_LOGIC;
        PCSrc		: out STD_LOGIC_VECTOR(1 downto 0);
		  State 		: out STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;
    
    component datapath
    port (
        CLK			: in  STD_LOGIC;
        RST 		: in  STD_LOGIC;
        ReadData 	: in  STD_LOGIC_VECTOR(31 downto 0);
        WriteData	: out STD_LOGIC_VECTOR(31 downto 0);
        MemAddr 	: out STD_LOGIC_VECTOR(31 downto 0);
        Opcode		: out STD_LOGIC_VECTOR(5 downto 0);
        Funct		: out STD_LOGIC_VECTOR(5 downto 0);
        PCEn		: in  STD_LOGIC;
        IorD		: in  STD_LOGIC;
        IRWrite		: in  STD_LOGIC;
        RegDst		: in  STD_LOGIC;
        MemToReg	: in  STD_LOGIC;
        RegWrite	: in  STD_LOGIC;
        ALUSrcA		: in  STD_LOGIC;
        ALUSrcB		: in  STD_LOGIC_VECTOR(1 downto 0);
        ALUControl	: in  STD_LOGIC_VECTOR(2 downto 0);
        ALUZero		: out STD_LOGIC;
        PCSrc		: in  STD_LOGIC_VECTOR(1 downto 0)
    );
    end component;
    
    signal Opcode		: STD_LOGIC_VECTOR(5 downto 0);
    signal Funct		: STD_LOGIC_VECTOR(5 downto 0);
    signal PCEn			: STD_LOGIC;
    signal IorD			: STD_LOGIC;
    signal IRWrite		: STD_LOGIC;
    signal RegDst		: STD_LOGIC;
    signal MemToReg		: STD_LOGIC;
    signal RegWrite		: STD_LOGIC;
    signal ALUSrcA		: STD_LOGIC;
    signal ALUSrcB		: STD_LOGIC_VECTOR(1 downto 0);
    signal ALUControl	: STD_LOGIC_VECTOR(2 downto 0);
    signal ALUZero		: STD_LOGIC;
    signal PCSrc		: STD_LOGIC_VECTOR(1 downto 0);

begin
    ctrl: control_unit port map (
        CLK, RST, MemWrite, Opcode, Funct,
        PCEn, IorD, IRWrite, RegDst, MemToReg,
        RegWrite, ALUSrcA, ALUSrcB, ALUControl,
        ALUZero, PCSrc, CtrlState
    );
    
    dpt: datapath port map (
        CLK, RST, ReadData, WriteData, MemAddr,
        Opcode, Funct, PCEn, IorD, IRWrite, RegDst,
        MemToReg, RegWrite, ALUSrcA, ALUSrcB, ALUControl,
        ALUZero, PCSrc
    );
end multicycle;