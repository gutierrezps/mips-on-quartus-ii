-- Processador MIPS Multiciclo
-- 
-- Unidade de Controle
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

entity control_unit is
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
	 State		: out STD_LOGIC_VECTOR(3 downto 0)
);
end control_unit;

architecture multicycle of control_unit is

    component ctrl_fsm
    port (
        CLK			: in STD_LOGIC;
        RST		: in STD_LOGIC;

        Opcode		: in STD_LOGIC_VECTOR(5 downto 0);

        IorD		: out STD_LOGIC;
        IRWrite		: out STD_LOGIC;
        RegDst		: out STD_LOGIC;
        MemtoReg	: out STD_LOGIC;
        RegWrite	: out STD_LOGIC;
        ALUSrcA		: out STD_LOGIC;
        ALUSrcB		: out STD_LOGIC_VECTOR(1 downto 0);
        ALUOp		: out STD_LOGIC_VECTOR(1 downto 0);

        PCSrc		: out STD_LOGIC_VECTOR(1 downto 0);
        PCWrite		: out STD_LOGIC;
        Branch		: out STD_LOGIC;
        
        MemWrite	: out STD_LOGIC;

        State		: out STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;

    component ctrl_aludec
    port ( 
        Funct		: in  STD_LOGIC_VECTOR(5 downto 0);
        ALUOp		: in  STD_LOGIC_VECTOR(1 downto 0);
        ALUControl	: out STD_LOGIC_VECTOR(2 downto 0)
    );
    end component;

    signal ALUOp	: STD_LOGIC_VECTOR(1 downto 0);
    signal PCWrite	: STD_LOGIC;
    signal Branch	: STD_LOGIC;

begin
    fsm: ctrl_fsm port map (
        CLK, RST, Opcode, IorD, IRWrite, RegDst,
        MemtoReg, RegWrite, ALUSrcA, ALUSrcB, ALUOp,
        PCSrc, PCWrite, Branch, MemWrite, State
    );

    aludec: ctrl_aludec port map (
        Funct, ALUOp, ALUControl
    );

    PCEn <= PCWrite or (Branch and ALUZero);
end multicycle;