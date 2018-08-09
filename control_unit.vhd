-- Processador MIPS Multiciclo
-- 
-- Unidade de Controle
--
-- Autor: Gabriel Gutierrez P. Soares
-- Data : 03 de agosto de 2018
--
-- Minicurso FPGA
-- Professores: Marcos Meira, Victor
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity control_unit is
port (
    CLK         : in  STD_LOGIC;
    RST         : in  STD_LOGIC;
    MemWrite    : out STD_LOGIC;
    Opcode      : in  STD_LOGIC_VECTOR(5 downto 0);
    Funct       : in  STD_LOGIC_VECTOR(5 downto 0);
    IorD        : out STD_LOGIC;
    IRWrite     : out STD_LOGIC;
    RegDst      : out STD_LOGIC;
    MemToReg    : out STD_LOGIC;
    RegWrite    : out STD_LOGIC;
    ALUSrcA     : out STD_LOGIC;
    ALUSrcB     : out STD_LOGIC_VECTOR(1 downto 0);
    ALUControl  : out STD_LOGIC_VECTOR(2 downto 0);
    PCSrc       : out STD_LOGIC_VECTOR(1 downto 0);
    Branch      : out STD_LOGIC;
    PCWrite     : out STD_LOGIC;
    State       : out STD_LOGIC_VECTOR(3 downto 0)
);
end control_unit;

architecture multicycle of control_unit is

    component ctrl_fsm
    port (
        CLK     : in  STD_LOGIC;
        RST     : in  STD_LOGIC;
        Opcode  : in  STD_LOGIC_VECTOR(5 downto 0);
        IorD    : out STD_LOGIC;
        IRWrite : out STD_LOGIC;
        RegDst  : out STD_LOGIC;
        MemtoReg: out STD_LOGIC;
        RegWrite: out STD_LOGIC;
        ALUSrcA : out STD_LOGIC;
        ALUSrcB : out STD_LOGIC_VECTOR(1 downto 0);
        ALUOp   : out STD_LOGIC_VECTOR(1 downto 0);
        PCSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        PCWrite : out STD_LOGIC;
        Branch  : out STD_LOGIC;
        MemWrite: out STD_LOGIC;
        State   : out STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;

    component ctrl_aludec
    port ( 
        Funct       : in  STD_LOGIC_VECTOR(5 downto 0);
        ALUOp       : in  STD_LOGIC_VECTOR(1 downto 0);
        ALUControl  : out STD_LOGIC_VECTOR(2 downto 0)
    );
    end component;

    signal ALUOp    : STD_LOGIC_VECTOR(1 downto 0);

begin
    fsm: ctrl_fsm port map (
        CLK         => CLK,
        RST         => RST,
        Opcode      => Opcode,
        IorD        => IorD,
        IRWrite     => IRWrite,
        RegDst      => RegDst,
        MemtoReg    => MemtoReg,
        RegWrite    => RegWrite,
        ALUSrcA     => ALUSrcA,
        ALUSrcB     => ALUSrcB,
        ALUOp       => ALUOp,
        PCSrc       => PCSrc,
        PCWrite     => PCWrite,
        Branch      => Branch,
        MemWrite    => MemWrite,
        State       => State
    );

    aludec: ctrl_aludec port map (
        Funct       => Funct,
        ALUOp       => ALUOp,
        ALUControl  => ALUControl
    );
end multicycle;