-- Processador MIPS Multiciclo
-- 
-- MIPS Test
--
-- Autor: Gabriel Gutierrez P. Soares
-- Data : 09 de agosto de 2018
--
-- Minicurso FPGA
-- Professores: Marcos Meira, Victor
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mips_test is
port (
    CLK         : in  STD_LOGIC;
    RST         : in  STD_LOGIC;
    DispState   : out STD_LOGIC_VECTOR(0 to 6);
    DispCount   : out STD_LOGIC_VECTOR(0 to 6);
    State       : out STD_LOGIC_VECTOR(3 downto 0);
    Count       : out STD_LOGIC_VECTOR(3 downto 0);
    ReadData_out, WriteData_out, MemAddr_out    : out STD_LOGIC_VECTOR(31 downto 0);
    MemWrite_out: out STD_LOGIC
);
end mips_test;

architecture test of mips_test is

    signal ReadData     : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteData    : STD_LOGIC_VECTOR(31 downto 0);
    signal MemAddr      : STD_LOGIC_VECTOR(31 downto 0);
    signal MemWrite     : STD_LOGIC;
    signal CtrlState    : STD_LOGIC_VECTOR(3 downto 0);
    signal CLK_n        : STD_LOGIC;

    component mips
    port (
        CLK         : in  STD_LOGIC;
        RST         : in  STD_LOGIC;
        ReadData    : in  STD_LOGIC_VECTOR(31 downto 0);
        WriteData   : out STD_LOGIC_VECTOR(31 downto 0);
        MemAddr     : out STD_LOGIC_VECTOR(31 downto 0);
        MemWrite    : out STD_LOGIC;
        CtrlState   : out STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;
    
    component bcd2hex
    port(
        bcd: in  std_logic_vector (3 downto 0);
        hex: out std_logic_vector (0 to 6)
    );
    end component;
    
    component mips_mem
    port(
        CLK         : in  STD_LOGIC;
        Addr        : in  STD_LOGIC_VECTOR(31 downto 0);
        WE          : in  STD_LOGIC;
        WriteData   : in  STD_LOGIC_VECTOR(31 downto 0);
        ReadData    : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;
    
begin
    CLK_n <= NOT CLK;
    
    mipsBlock: mips port map (
        CLK         => CLK,
        RST         => RST,
        ReadData    => ReadData,
        WriteData   => WriteData,
        MemAddr     => MemAddr,
        MemWrite    => MemWrite,
        CtrlState   => CtrlState
    );
    
    memBlock: mips_mem port map (
        CLK         => CLK_n,
        Addr        => MemAddr,
        WE          => MemWrite,
        WriteData   => WriteData,
        ReadData    => ReadData
    );
    
    State <= CtrlState;
    ReadData_out <= ReadData;
    WriteData_out <= WriteData;
    MemAddr_out <= MemAddr;
    MemWrite_out <= MemWrite;
    
end test;