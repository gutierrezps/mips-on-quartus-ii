-- Multicycle MIPS / Control Unit
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
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
end control_unit;

architecture multicycle of control_unit is

    component ctrl_fsm
        port (
            i_clk       : in std_logic;
            i_rst       : in std_logic;
            i_opcode    : in std_logic_vector(5 downto 0);
            o_iOrD      : out std_logic;
            o_irWrite   : out std_logic;
            o_regDst    : out std_logic;
            o_memToReg  : out std_logic;
            o_regWrite  : out std_logic;
            o_aluSrcA   : out std_logic;
            o_aluSrcB   : out std_logic_vector(1 downto 0);
            o_aluOp     : out std_logic_vector(1 downto 0);
            o_pcSrc     : out std_logic_vector(1 downto 0);
            o_pcWrite   : out std_logic;
            o_branch    : out std_logic;
            o_memWrite  : out std_logic;
            o_state     : out std_logic_vector(3 downto 0)
        );
    end component;

    component ctrl_aludec
        port( 
            i_funct     : in  std_logic_vector(5 downto 0);
            i_aluOp     : in  std_logic_vector(1 downto 0);
            o_aluControl: out std_logic_vector(2 downto 0)
        );
    end component;

    signal w_aluOp  : std_logic_vector(1 downto 0);

begin
    fsm: ctrl_fsm port map (
        i_clk       => i_clk,
        i_rst       => i_rst,
        i_opcode    => i_opcode,
        o_iOrD      => o_iOrD,
        o_irWrite   => o_irWrite,
        o_regDst    => o_regDst,
        o_memToReg  => o_memToReg,
        o_regWrite  => o_regWrite,
        o_aluSrcA   => o_aluSrcA,
        o_aluSrcB   => o_aluSrcB,
        o_aluOp     => w_aluOp,
        o_pcSrc     => o_pcSrc,
        o_pcWrite   => o_pcWrite,
        o_branch    => o_branch,
        o_memWrite  => o_memWrite,
        o_state     => o_state
    );

    aludec: ctrl_aludec port map (
        i_funct         => i_funct,
        i_aluOp         => w_aluOp,
        o_aluControl    => o_aluControl
    );
end multicycle;