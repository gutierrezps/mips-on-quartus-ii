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
            i_clk         : in  std_logic;
            i_rst         : in  std_logic;
            i_readData    : in  std_logic_vector(31 downto 0);
            o_writeData   : out std_logic_vector(31 downto 0);
            o_memAddr     : out std_logic_vector(31 downto 0);
            o_opcode      : out std_logic_vector( 5 downto 0);
            o_funct       : out std_logic_vector( 5 downto 0);
            i_iOrD        : in  std_logic;
            i_irWrite     : in  std_logic;
            i_regDst      : in  std_logic;
            i_memToReg    : in  std_logic;
            i_regWrite    : in  std_logic;
            i_aluSrcA     : in  std_logic;
            i_aluSrcB     : in  std_logic_vector(1 downto 0);
            i_aluControl  : in  std_logic_vector(2 downto 0);
            i_pcSrc       : in  std_logic_vector(1 downto 0);
            i_branch      : in  std_logic;
            i_pcWrite     : in  std_logic
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
    
    signal CLK_n        : STD_LOGIC;

begin
    CLK_n <= NOT CLK;
    
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
        i_clk         => CLK_n,
        i_rst         => RST,
        i_readData    => ReadData,
        o_writeData   => WriteData,
        o_memAddr     => MemAddr,
        o_opcode      => Opcode,
        o_funct       => Funct,
        i_iOrD        => IorD,
        i_irWrite     => IRWrite,
        i_regDst      => RegDst,
        i_memToReg    => MemToReg,
        i_regWrite    => RegWrite,
        i_aluSrcA     => ALUSrcA,
        i_aluSrcB     => ALUSrcB,
        i_aluControl  => ALUControl,
        i_pcSrc       => PCSrc,
        i_branch      => Branch,
        i_pcWrite     => PCWrite
    );
end multicycle;