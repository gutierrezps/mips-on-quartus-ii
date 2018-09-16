-- Multicycle MIPS Processor - Datapath
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity datapath is
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
end datapath;

architecture struct of datapath is
    
    component reg_width
        generic (g_WIDTH : integer := 32);
        port (
            i_clk : in  std_logic;
            i_rst : in  std_logic;
            i_en  : in  std_logic;
            i_d   : in  std_logic_vector(g_WIDTH-1 downto 0);
            o_q   : out std_logic_vector(g_WIDTH-1 downto 0)
        );
    end component;

    component mux2_width
        generic (g_WIDTH : integer := 32);
        port (
            i_data0 : in  std_logic_vector(g_WIDTH-1 downto 0);
            i_data1 : in  std_logic_vector(g_WIDTH-1 downto 0);
            i_sel   : in  std_logic;
            o_data  : out std_logic_vector(g_WIDTH-1 downto 0)
        );
    end component;

    component regfile_width
        generic (g_WIDTH : integer := 32);
        port (
            i_clk, i_we3    : in  std_logic;
            i_a1, i_a2, i_a3: in  std_logic_vector(4 downto 0);
            i_wd3           : in  std_logic_vector(g_WIDTH-1 downto 0);
            o_rd1, o_rd2    : out std_logic_vector(g_WIDTH-1 downto 0)
        );
    end component;

    component signext_width
        generic (
            g_INPUT_WIDTH   : integer := 16;
            g_OUTPUT_WIDTH  : integer := 32
        );
        port (
            i_a: in  std_logic_vector(g_INPUT_WIDTH-1 downto 0);
            o_y: out std_logic_vector(g_OUTPUT_WIDTH-1 downto 0)
        );
    end component;

    component sl2_width
        generic (g_WIDTH : integer := 32);
        port (
            i_a: in  std_logic_vector(g_WIDTH-1 downto 0);
            o_y: out std_logic_vector(g_WIDTH-1 downto 0)
        );
    end component;

    component mux4_width
        generic (g_WIDTH : integer := 32);
        port (
            i_data0,
            i_data1,
            i_data2,
            i_data3 : in  std_logic_vector(g_WIDTH-1 downto 0);
            i_sel   : in  std_logic_vector(1 downto 0);
            o_data  : out std_logic_vector(g_WIDTH-1 downto 0)
        );
    end component;

    component alu_width
        generic (g_WIDTH : integer := 32);
        port (
            i_a, i_b: in  std_logic_vector(g_WIDTH-1 downto 0);
            i_ctrl  : in  std_logic_vector( 2 downto 0);
            o_res   : out std_logic_vector(g_WIDTH-1 downto 0);
            o_zero  : out std_logic
        );
    end component;

    signal w_instr, w_data          : std_logic_vector(31 downto 0);
    signal w_regfileA3              : std_logic_vector( 4 downto 0);
    signal w_regfileWD3             : std_logic_vector(31 downto 0);
    signal w_regfileD1, w_regfileD2 : std_logic_vector(31 downto 0);
    signal w_regA, w_regB           : std_logic_vector(31 downto 0);
    signal w_signImm, w_signImmSL2  : std_logic_vector(31 downto 0);
    signal w_srcA, w_srcB           : std_logic_vector(31 downto 0);
    signal w_aluResult              : std_logic_vector(31 downto 0);
    signal w_aluOut, w_pcJump       : std_logic_vector(31 downto 0);
    signal w_pcNext, w_pc           : std_logic_vector(31 downto 0);
    signal w_pcEn, w_aluZero        : std_logic;

begin -- architecture struct of datapath

    instrReg: reg_width port map (
        i_clk   => i_clk,
        i_rst   => i_rst,
        i_en    => i_irWrite,
        i_d     => i_readData,
        o_q     => w_instr
    );

    dataReg: reg_width port map (
        i_clk   => i_clk,
        i_rst   => i_rst,
        i_en    => '1',
        i_d     => i_readData,
        o_q     => w_data
    );

    o_opcode <= w_instr(31 downto 26);
    o_funct  <= w_instr( 5 downto 0);

    regA3Mux: mux2_width
        generic map (g_WIDTH => 5)
        port map (
            i_data0 => w_instr(20 downto 16),
            i_data1 => w_instr(15 downto 11),
            i_sel   => i_regDst,
            o_data  => w_regfileA3
        );

    regWD3Mux: mux2_width port map (
        i_data0 => w_aluOut,
        i_data1 => w_data,
        i_sel   => i_memToReg,
        o_data  => w_regfileWD3
    );

    regFile: regfile_width port map (
        i_clk   => i_clk,
        i_a1    => w_instr(25 downto 21),
        i_a2    => w_instr(20 downto 16),
        i_a3    => w_regfileA3,
        i_we3   => i_regWrite,
        i_wd3   => w_regfileWD3,
        o_rd1   => w_regfileD1,
        o_rd2   => w_regfileD2
    );

    regA: reg_width port map (
        i_clk   => i_clk,
        i_rst   => i_rst,
        i_en    => '1',
        i_d     => w_regfileD1,
        o_q     => w_regA
    );

    regB: reg_width port map (
        i_clk   => i_clk,
        i_rst   => i_rst,
        i_en    => '1',
        i_d     => w_regfileD2,
        o_q     => w_regB
    );

    o_writeData <= w_regB;

    signExt: signext_width port map (
        i_a => w_instr(15 downto 0),
        o_y => w_signImm
    );

    immShift2: sl2_width port map (
        i_a => w_signImm,
        o_y => w_signImmSL2
    );

    srcAMux: mux2_width port map (
        i_data0 => w_pc,
        i_data1 => w_regA,
        i_sel   => i_aluSrcA,
        o_data  => w_srcA
    );

    srcBMux: mux4_width port map (
        i_data0 => w_regB,
        i_data1 => X"00000004",
        i_data2 => w_signImm,
        i_data3 => w_signImmSL2,
        i_sel   => i_aluSrcB,
        o_data  => w_srcB
    );

    alu: alu_width port map (
        i_a    => w_srcA,
        i_b    => w_srcB,
        i_ctrl => i_aluControl,
        o_res  => w_aluResult,
        o_zero => w_aluZero
    );

    aluReg: reg_width port map (
        i_clk   => i_clk,
        i_rst   => i_rst,
        i_en    => '1',
        i_d     => w_aluResult,
        o_q     => w_aluOut
    );

    pcShift2: sl2_width
        generic map (g_WIDTH => 28)
        port map (
            i_a => "00" & w_instr(25 downto 0),
            o_y => w_pcJump(27 downto 0)
        );

    w_pcJump(31 downto 28) <= w_pc(31 downto 28);

    pcMux: mux4_width port map (
        i_data0 => w_aluResult,
        i_data1 => w_aluOut,
        i_data2 => w_pcJump,
        i_data3 => X"00000000",
        i_sel   => i_pcSrc,
        o_data  => w_pcNext
    );

    w_pcEn <= i_pcWrite or (i_branch and w_aluZero);

    pcReg: reg_width port map (
        i_clk   => i_clk,
        i_rst   => i_rst,
        i_en    => w_pcEn,
        i_d     => w_pcNext,
        o_q     => w_pc
    );

    memAdrMux: mux2_width port map (
        i_data0 => w_pc,
        i_data1 => w_aluOut,
        i_sel   => i_iOrD,
        o_data  => o_memAddr
    );

end architecture struct;
