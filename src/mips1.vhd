-- Multicycle MIPS Processor - struct #1
-- With memory buses, Opcode, ALU result and FSM state exposed
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity mips1 is
    port (
        i_clk           : in  std_logic;
        i_rst           : in  std_logic;
        o_memReadData   : out std_logic_vector(31 downto 0);
        o_memWriteData  : out std_logic_vector(31 downto 0);
        o_memAddr       : out std_logic_vector(31 downto 0);
        o_memWrite      : out std_logic;
        o_dptOpcode     : out std_logic_vector( 5 downto 0);
        o_dptALUResult  : out std_logic_vector(31 downto 0);
        o_ctrlState     : out std_logic_vector( 3 downto 0)
    );
end mips1;

architecture struct of mips1 is

    component control_unit
        port (
            i_clk           : in  std_logic;
            i_rst           : in  std_logic;
            o_memWrite      : out std_logic;
            i_opcode        : in  std_logic_vector(5 downto 0);
            i_funct         : in  std_logic_vector(5 downto 0);
            o_iOrD          : out std_logic;
            o_irWrite       : out std_logic;
            o_regDst        : out std_logic;
            o_memToReg      : out std_logic;
            o_regWrite      : out std_logic;
            o_aluSrcA       : out std_logic;
            o_aluSrcB       : out std_logic_vector(1 downto 0);
            o_aluControl    : out std_logic_vector(2 downto 0);
            o_pcSrc         : out std_logic_vector(1 downto 0);
            o_branch        : out std_logic;
            o_pcWrite       : out std_logic;
            o_state         : out std_logic_vector(3 downto 0)
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
            i_pcWrite     : in  std_logic;
            o_aluResult   : out std_logic_vector(31 downto 0)
        );
    end component;

    component mips_mem
        port (
            i_clk         : in  std_logic;
            i_addr        : in  std_logic_vector(31 downto 0);
            i_writeEnable : in  std_logic;
            i_writeData   : in  std_logic_vector(31 downto 0);
            o_readData    : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Memory
    signal w_readData   : std_logic_vector(31 downto 0);
    signal w_writeData  : std_logic_vector(31 downto 0);
    signal w_memAddr    : std_logic_vector(31 downto 0);
    signal w_memWrite   : std_logic;

    -- Datapath/Control Unit
    signal w_opcode     : std_logic_vector( 5 downto 0);
    signal w_funct      : std_logic_vector( 5 downto 0);
    signal w_iOrD       : std_logic;
    signal w_irWrite    : std_logic;
    signal w_regDst     : std_logic;
    signal w_memToReg   : std_logic;
    signal w_regWrite   : std_logic;
    signal w_aluSrcA    : std_logic;
    signal w_aluSrcB    : std_logic_vector(1 downto 0);
    signal w_aluControl : std_logic_vector(2 downto 0);
    signal w_branch     : std_logic;
    signal w_pcWrite    : std_logic;
    signal w_pcSrc      : std_logic_vector(1 downto 0);

    signal w_nClk       : std_logic;

begin
    w_nClk <= not i_clk;
    
    ctrl: control_unit port map (
        i_clk           => i_clk,
        i_rst           => i_rst,
        i_opcode        => w_opcode,
        i_funct         => w_funct,
        o_iOrD          => w_iOrD,
        o_irWrite       => w_irWrite,
        o_regDst        => w_regDst,
        o_memToReg      => w_memToReg,
        o_regWrite      => w_regWrite,
        o_aluSrcA       => w_aluSrcA,
        o_aluSrcB       => w_aluSrcB,
        o_aluControl    => w_aluControl,
        o_branch        => w_branch,
        o_pcWrite       => w_pcWrite,
        o_pcSrc         => w_pcSrc,
        o_memWrite      => w_memWrite,
        o_state         => o_ctrlState
    );
    
    dpt: datapath port map (
        i_clk           => w_nClk,
        i_rst           => i_rst,
        i_readData      => w_readData,
        o_writeData     => w_writeData,
        o_memAddr       => w_memAddr,
        o_opcode        => w_opcode,
        o_funct         => w_funct,
        i_iOrD          => w_iOrD,
        i_irWrite       => w_irWrite,
        i_regDst        => w_regDst,
        i_memToReg      => w_memToReg,
        i_regWrite      => w_regWrite,
        i_aluSrcA       => w_aluSrcA,
        i_aluSrcB       => w_aluSrcB,
        i_aluControl    => w_aluControl,
        i_pcSrc         => w_pcSrc,
        i_branch        => w_branch,
        i_pcWrite       => w_pcWrite,
        o_aluResult     => o_dptALUResult
    );

    mem: mips_mem port map (
        i_clk           => w_nClk,
        i_addr          => w_memAddr,
        i_writeEnable   => w_memWrite,
        i_writeData     => w_writeData,
        o_readData      => w_readData
    );

    o_memReadData   <= w_readData;
    o_memWriteData  <= w_writeData;
    o_memAddr       <= w_memAddr;
    o_memWrite      <= w_memWrite;
    o_dptOpcode     <= w_opcode;
    
end struct;