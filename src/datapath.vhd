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

architecture multicycle of datapath is
    component dpt_reg
    port (
        CLK : in  STD_LOGIC;
        RST : in  STD_LOGIC;
        EN  : in  STD_LOGIC;
        D   : in  STD_LOGIC_VECTOR(31 downto 0);
        Q   : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component dpt_mux2_5b
    port (
        D0, D1  : in  STD_LOGIC_VECTOR(4 downto 0);
        sel     : in  STD_LOGIC;
        Y       : out STD_LOGIC_VECTOR(4 downto 0)
    );
    end component;

    component dpt_mux2
    port (
        D0, D1  : in  STD_LOGIC_VECTOR(31 downto 0);
        Sel     : in  STD_LOGIC;
        Y       : out STD_LOGIC_VECTOR(31 downto 0)
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

    component dpt_mux4
    port (
        D0, D1  : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
        D2, D3  : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Sel     : in  STD_LOGIC_VECTOR( 1 DOWNTO 0);
        Y       : out STD_LOGIC_VECTOR(31 DOWNTO 0)
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

begin

    instrReg: dpt_reg port map (
        CLK => CLK,
        RST => RST,
        EN  => IRWrite,
        D   => ReadData,
        Q   => Instr
    );

    dataReg: dpt_reg port map (
        CLK => CLK,
        RST => RST,
        EN  => '1',
        D   => ReadData,
        Q   => Data
    );

    Opcode <= Instr(31 downto 26);
    Funct  <= Instr( 5 downto 0);

    regA3Mux: dpt_mux2_5b port map (
        D0  => Instr(20 downto 16),
        D1  => Instr(15 downto 11),
        Sel => RegDst,
        Y   => RegA3
    );

    regWD3Mux: dpt_mux2 port map (
        D0  => ALUOut,
        D1  => Data,
        Sel => MemToReg,
        Y   => RegWD3
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

    srcAMux: dpt_mux2 port map (
        D0  => PC,
        D1  => RegA,
        Sel => ALUSrcA,
        Y   => SrcA
    );

    srcBMux: dpt_mux4 port map (
        D0  => RegB,
        D1  => X"00000004",
        D2  => SignImm,
        D3  => SignImmSL2,
        Sel => ALUSrcB,
        Y   => SrcB
    );

    alu: dpt_alu port map (
        A    => SrcA,
        B    => SrcB,
        Ctrl => ALUControl,
        Res  => ALUResult,
        Zero => ALUZero
    );

    aluReg: dpt_reg port map (
        CLK => CLK,
        RST => RST,
        EN  => '1',
        D   => ALUResult,
        Q   => ALUOut
    );

    pcShift2: dpt_pcsl2 port map (
        Instr(25 downto 0), PCJump(27 downto 0)
    );

    PCJump(31 downto 28) <= PC(31 downto 28);

    pcMux: dpt_mux4 port map (
        D0  => ALUResult,
        D1  => ALUOut,
        D2  => PCJump,
        D3  => X"00000000",
        Sel => PCSrc,
        Y   => PCNext
    );

    PCEn <= PCWrite or (Branch and ALUZero);

    pcReg: dpt_reg port map (
        CLK => CLK,
        RST => RST,
        EN  => PCEn,
        D   => PCNext,
        Q   => PC
    );

    memAdrMux: dpt_mux2 port map (
        D0  => PC,
        D1  => ALUOut,
        Sel => IorD,
        Y   => MemAddr
    );

end multicycle;