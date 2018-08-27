-- Processador MIPS Multiciclo
-- 
-- Datapath
--
-- Autor: Gabriel Gutierrez P. Soares
-- Data : 03 de agosto de 2018
--
-- Minicurso FPGA
-- Professores: Marcos Meira, Joao Vitor
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity datapath is
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

    component dpt_regfile
    port (
        CLK, WE3    : in  STD_LOGIC;
        A1, A2, A3  : in  STD_LOGIC_VECTOR(4 downto 0);
        WD3         : in  STD_LOGIC_VECTOR(31 downto 0);
        RD1, RD2    : out STD_LOGIC_VECTOR(31 downto 0)
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

    component dpt_alu
    port (
        A, B    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Ctrl    : IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
        Res     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Zero    : OUT STD_LOGIC
    );
    end component;

    signal Instr, Data      : STD_LOGIC_VECTOR(31 downto 0);
    signal RegA3            : STD_LOGIC_VECTOR( 4 downto 0);
    signal RegWD3           : STD_LOGIC_VECTOR(31 downto 0);
    signal RegA, RegB       : STD_LOGIC_VECTOR(31 downto 0);
    signal SignImm          : STD_LOGIC_VECTOR(31 downto 0);
    signal SignImmSL2       : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcA, SrcB       : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult        : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUOut, PCJump   : STD_LOGIC_VECTOR(31 downto 0);
    signal PCNext, PC       : STD_LOGIC_VECTOR(31 downto 0);
    signal PCEn, ALUZero    : STD_LOGIC;

begin -- architecture struct of datapath

    instrReg: reg_width port map (
        i_clk   => CLK,
        i_rst   => RST,
        i_en    => IRWrite,
        i_d     => ReadData,
        o_q     => Instr
    );

    dataReg: reg_width port map (
        i_clk   => CLK,
        i_rst   => RST,
        i_en    => '1',
        i_d     => ReadData,
        o_q     => Data
    );

    Opcode <= Instr(31 downto 26);
    Funct  <= Instr( 5 downto 0);

    regA3Mux: mux2_width
    generic map (g_WIDTH => 5)
    port map (
        i_data0 => Instr(20 downto 16),
        i_data1 => Instr(15 downto 11),
        i_sel   => RegDst,
        o_data  => RegA3
    );

    regWD3Mux: mux2_width
    port map (
        i_data0 => ALUOut,
        i_data1 => Data,
        i_sel   => MemToReg,
        o_data  => RegWD3
    );

    regFile: dpt_regfile port map (
        CLK => CLK,
        A1  => Instr(25 downto 21),
        A2  => Instr(20 downto 16),
        A3  => RegA3,
        WE3 => RegWrite,
        WD3 => RegWD3,
        RD1 => RegA,
        RD2 => RegB
    );

    WriteData <= RegB;

    signExt: dpt_signext port map (
        Instr(15 downto 0), SignImm
    );

    immShift2: dpt_sl2 port map (
        SignImm, SignImmSL2
    );

    srcAMux: mux2_width
    port map (
        i_data0 => PC,
        i_data1 => RegA,
        i_sel   => ALUSrcA,
        o_data  => SrcA
    );

    srcBMux: mux4_width port map (
        i_data0 => RegB,
        i_data1 => X"00000004",
        i_data2 => SignImm,
        i_data3 => SignImmSL2,
        i_sel   => ALUSrcB,
        o_data  => SrcB
    );

    alu: dpt_alu port map (
        A    => SrcA,
        B    => SrcB,
        Ctrl => ALUControl,
        Res  => ALUResult,
        Zero => ALUZero
    );

    aluReg: reg_width port map (
        i_clk   => CLK,
        i_rst   => RST,
        i_en    => '1',
        i_d     => ALUResult,
        o_q     => ALUOut
    );

    pcShift2: dpt_pcsl2 port map (
        Instr(25 downto 0), PCJump(27 downto 0)
    );

    PCJump(31 downto 28) <= PC(31 downto 28);

    pcMux: mux4_width port map (
        i_data0 => ALUResult,
        i_data1 => ALUOut,
        i_data2 => PCJump,
        i_data3 => X"00000000",
        i_sel   => PCSrc,
        o_data  => PCNext
    );

    PCEn <= PCWrite or (Branch and ALUZero);

    pcReg: reg_width port map (
        i_clk   => CLK,
        i_rst   => RST,
        i_en    => PCEn,
        i_d     => PCNext,
        o_q     => PC
    );

    memAdrMux: mux2_width
    port map (
        i_data0 => PC,
        i_data1 => ALUOut,
        i_sel   => IorD,
        o_data  => MemAddr
    );

end architecture struct;
