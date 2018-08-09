-- Processador MIPS Multiciclo
-- 
-- Bloco do processador
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

entity mips is
port (
    CLK         : in  STD_LOGIC;
    RST         : in  STD_LOGIC;
    ReadData    : in  STD_LOGIC_VECTOR(31 downto 0);
    WriteData   : out STD_LOGIC_VECTOR(31 downto 0);
    MemAddr     : out STD_LOGIC_VECTOR(31 downto 0);
    MemWrite    : out STD_LOGIC;
    CtrlState   : out STD_LOGIC_VECTOR(3 downto 0)
);
end mips;

architecture multicycle of mips is

    component control_unit
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
    end component;
    
    component datapath
    port (
        CLK         : in  STD_LOGIC;
        RST         : in  STD_LOGIC;
        ReadData    : in  STD_LOGIC_VECTOR(31 downto 0);
        WriteData   : out STD_LOGIC_VECTOR(31 downto 0);
        MemAddr     : out STD_LOGIC_VECTOR(31 downto 0);
        Opcode      : out STD_LOGIC_VECTOR( 5 downto 0);
        Funct       : out STD_LOGIC_VECTOR( 5 downto 0);
        IorD        : in  STD_LOGIC;
        IRWrite     : in  STD_LOGIC;
        RegDst      : in  STD_LOGIC;
        MemToReg    : in  STD_LOGIC;
        RegWrite    : in  STD_LOGIC;
        ALUSrcA     : in  STD_LOGIC;
        ALUSrcB     : in  STD_LOGIC_VECTOR(1 downto 0);
        ALUControl  : in  STD_LOGIC_VECTOR(2 downto 0);
        PCSrc       : in  STD_LOGIC_VECTOR(1 downto 0);
        Branch      : in  STD_LOGIC;
        PCWrite     : in  STD_LOGIC
    );
    end component;
    
    signal Opcode       : STD_LOGIC_VECTOR(5 downto 0);
    signal Funct        : STD_LOGIC_VECTOR(5 downto 0);
    signal IorD         : STD_LOGIC;
    signal IRWrite      : STD_LOGIC;
    signal RegDst       : STD_LOGIC;
    signal MemToReg     : STD_LOGIC;
    signal RegWrite     : STD_LOGIC;
    signal ALUSrcA      : STD_LOGIC;
    signal ALUSrcB      : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUControl   : STD_LOGIC_VECTOR(2 downto 0);
    signal ALUZero      : STD_LOGIC;
    signal PCSrc        : STD_LOGIC_VECTOR(1 downto 0);
    signal Branch       : STD_LOGIC;
    signal PCWrite      : STD_LOGIC;

begin
    ctrl: control_unit port map (
        CLK         => CLK,
        RST         => RST,
        MemWrite    => MemWrite,
        Opcode      => Opcode,
        Funct       => Funct,
        IorD        => IorD,
        IRWrite     => IRWrite,
        RegDst      => RegDst,
        MemToReg    => MemToReg,
        RegWrite    => RegWrite,
        ALUSrcA     => ALUSrcA,
        ALUSrcB     => ALUSrcB,
        ALUControl  => ALUControl,
        PCSrc       => PCSrc,
        Branch      => Branch,
        PCWrite     => PCWrite,
        State       => CtrlState
    );
    
    dpt: datapath port map (
        CLK         => CLK,
        RST         => RST,
        ReadData    => ReadData,
        WriteData   => WriteData,
        MemAddr     => MemAddr,
        Opcode      => Opcode,
        Funct       => Funct,
        IorD        => IorD,
        IRWrite     => IRWrite,
        RegDst      => RegDst,
        MemToReg    => MemToReg,
        RegWrite    => RegWrite,
        ALUSrcA     => ALUSrcA,
        ALUSrcB     => ALUSrcB,
        ALUControl  => ALUControl,
        PCSrc       => PCSrc,
        Branch      => Branch,
        PCWrite     => PCWrite
    );
end multicycle;