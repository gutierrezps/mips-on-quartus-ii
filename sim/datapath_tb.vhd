-- Multicycle MIPS Datapath testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_tb is
end;

architecture bench of datapath_tb is
    constant c_CLOCK_PERIOD : time := 10 ns;
    constant c_WIDTH: integer := 32;

    -- propagation delay, used when there's a memory access (read or write)
    constant c_PROP_DELAY   : time :=  1 ns;
    
    signal r_stop_clock: boolean;

    signal i_clk         : std_logic;
    signal i_rst         : std_logic;
    signal i_readData    : std_logic_vector(31 downto 0);
    signal o_writeData   : std_logic_vector(31 downto 0);
    signal o_memAddr     : std_logic_vector(31 downto 0);
    signal o_opcode      : std_logic_vector( 5 downto 0);
    signal o_funct       : std_logic_vector( 5 downto 0);
    signal i_iOrD        : std_logic;
    signal i_irWrite     : std_logic;
    signal i_regDst      : std_logic;
    signal i_memToReg    : std_logic;
    signal i_regWrite    : std_logic;
    signal i_aluSrcA     : std_logic;
    signal i_aluSrcB     : std_logic_vector(1 downto 0);
    signal i_aluControl  : std_logic_vector(2 downto 0);
    signal i_pcSrc       : std_logic_vector(1 downto 0);
    signal i_branch      : std_logic;
    signal i_pcWrite     : std_logic;
    signal o_aluResult      : std_logic_vector(31 downto 0);

begin

    dut: entity work.datapath
        port map (
            i_clk         => i_clk,
            i_rst         => i_rst,
            i_readData    => i_readData,
            o_writeData   => o_writeData,
            o_memAddr     => o_memAddr,
            o_opcode      => o_opcode,
            o_funct       => o_funct,
            i_iOrD        => i_iOrD,
            i_irWrite     => i_irWrite,
            i_regDst      => i_regDst,
            i_memToReg    => i_memToReg,
            i_regWrite    => i_regWrite,
            i_aluSrcA     => i_aluSrcA,
            i_aluSrcB     => i_aluSrcB,
            i_aluControl  => i_aluControl,
            i_pcSrc       => i_pcSrc,
            i_branch      => i_branch,
            i_pcWrite     => i_pcWrite,
            o_aluResult     => o_aluResult
        );

    stimulus: process
    begin
        -- Signals initialization
        i_irWrite   <= '0';   -- disable write signals
        i_regWrite  <= '0';
        i_branch    <= '0';
        i_pcWrite   <= '0';

        -- Reset
        i_rst <= '1';
        wait for c_CLOCK_PERIOD;
        i_rst <= '0';

        -- =====================================================================
        -- Instruction lw $s0, 2048($zero)
        
        -- S0: fetch
        i_iOrD      <= '0';     -- set memAddr output to PC reg value
        wait for c_PROP_DELAY;
        assert o_memAddr = X"00000000" report "PC reset failed" severity error;

        i_irWrite   <= '1';     -- write to instr reg
        i_aluSrcA   <= '0';     -- PC
        i_aluSrcB   <= "01";    -- 4
        i_aluControl <= "010";  -- add
        i_pcSrc     <= "00";    -- aluOut
        i_pcWrite   <= '1';     -- set new PC value (PC + 4)
        i_readData  <= X"8C100800";  -- instruction "read" from mem

        wait for c_CLOCK_PERIOD - c_PROP_DELAY;
        i_irWrite   <= '0';     -- disable write signals
        i_pcWrite   <= '0';

        -- S1: decode
        assert o_opcode = "100011" report "Opcode mismatch" severity error;
        assert o_memAddr = X"00000004" report "PC add failed" severity error;
        
        wait for c_CLOCK_PERIOD;

        -- S2: mem addr calc
        i_aluSrcA   <= '1';     -- regA
        i_aluSrcB   <= "10";    -- immediate
        i_aluControl <= "010";  -- add

        wait for c_CLOCK_PERIOD;
        
        -- S3: mem read
        i_iOrD <= '1';
        wait for c_PROP_DELAY;

        -- addr should be 2048 (imm + reg = 2048 + 0 = 2048 = 0x800)
        assert o_memAddr = X"00000800" report "Addr calc failed" severity error;

        i_readData <= X"12345678";  -- random data, to be stored on $s0
        wait for c_CLOCK_PERIOD - c_PROP_DELAY;

        -- S4: mem writeback
        i_regDst    <= '0';     -- regfile A3 = rt (instruction field, $s0)
        i_memToReg  <= '1';     -- regfile WD3 = data, read from mem
        i_regWrite  <= '1';

        wait for c_CLOCK_PERIOD;

        -- End of stimulus

        r_stop_clock <= true;
        wait;
    end process;
    
    clocking: process
    begin
        while not r_stop_clock loop
            i_clk <= '0', '1' after c_CLOCK_PERIOD / 2;
            wait for c_CLOCK_PERIOD;
        end loop;
        wait;
    end process;

end architecture bench;