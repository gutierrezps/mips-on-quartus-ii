-- Multicycle MIPS / Control Unit / Finite State Machine testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_fsm_tb is
end;

architecture bench of ctrl_fsm_tb is
    constant c_CLOCK_PERIOD: time := 10 ns;
    
    signal r_stop_clock: boolean;

    signal i_clk        : std_logic;
    signal i_rst        : std_logic;
    signal i_opcode     : std_logic_vector(5 downto 0);
    signal o_iOrD       : std_logic;
    signal o_irWrite    : std_logic;
    signal o_regDst     : std_logic;
    signal o_memToReg   : std_logic;
    signal o_regWrite   : std_logic;
    signal o_aluSrcA    : std_logic;
    signal o_aluSrcB    : std_logic_vector(1 downto 0);
    signal o_aluOp      : std_logic_vector(1 downto 0);
    signal o_pcSrc      : std_logic_vector(1 downto 0);
    signal o_pcWrite    : std_logic;
    signal o_branch     : std_logic;
    signal o_memWrite   : std_logic;
    signal o_state      : std_logic_vector(3 downto 0);

    -- Build an enumerated type for the state machine
    type t_stateType is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11);

begin

    dut: entity work.ctrl_fsm port map (
        i_clk   => i_clk,
        i_rst   => i_rst,
        i_opcode    => i_opcode,
        o_iOrD      => o_iOrD,
        o_irWrite   => o_irWrite,
        o_regDst    => o_regDst,
        o_memToReg  => o_memToReg,
        o_regWrite  => o_regWrite,
        o_aluSrcA   => o_aluSrcA,
        o_aluSrcB   => o_aluSrcB,
        o_aluOp     => o_aluOp,
        o_pcSrc     => o_pcSrc,
        o_pcWrite   => o_pcWrite,
        o_branch    => o_branch,
        o_memWrite  => o_memWrite,
        o_state     => o_state
    );

    stimulus: process
        
        procedure check_state(constant expected_state: in t_stateType) is
        begin
            assert expected_state = t_stateType'VAL(to_integer(unsigned(o_state)))
                report "State mismatch" severity error;
        end procedure; -- check_state

    begin
        -- Reset
        i_rst <= '1';
        wait for c_CLOCK_PERIOD;
        i_rst <= '0';

        check_state(s0);
        assert o_iOrD = '0' and o_aluSrcA = '0' and o_aluSrcB = "01"
            and o_aluOp = "00" and o_pcSrc = "00"
            report "Mismatch S0 flow output" severity error;
        assert o_irWrite = '1' and o_pcWrite = '1'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S0 enables output" severity error;
        
        i_opcode <= "100011";   -- load word
        
        wait for c_CLOCK_PERIOD;

        check_state(s1);
        assert o_aluSrcA = '0' and o_aluSrcB = "11" and o_aluOp = "00"
            report "Mismatch S1 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S1 enables output" severity error;
        
        wait for c_CLOCK_PERIOD;

        check_state(s2);
        assert o_aluSrcA = '1' and o_aluSrcB = "10" and o_aluOp = "00"
            report "Mismatch S2 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S2 enables output" severity error;
        
        wait for c_CLOCK_PERIOD;

        check_state(s3);
        assert o_iOrD = '1' report "Mismatch S3 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S3 enables output" severity error;

        wait for c_CLOCK_PERIOD;

        check_state(s4);
        assert o_regDst = '0' and o_memToReg = '1'
            report "Mismatch S4 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '1' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S4 enables output" severity error;

        wait for c_CLOCK_PERIOD;

        check_state(s0);
        i_opcode <= "101011";   -- store word
        wait for c_CLOCK_PERIOD;

        check_state(s1);
        wait for c_CLOCK_PERIOD;

        check_state(s2);
        wait for c_CLOCK_PERIOD;

        check_state(s5);
        assert o_iOrD = '1' report "Mismatch S5 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '1'
            report "Mismatch S5 enables output" severity error;

        wait for c_CLOCK_PERIOD;

        check_state(s0);
        i_opcode <= "000000";   -- r-type
        wait for c_CLOCK_PERIOD;

        check_state(s1);
        wait for c_CLOCK_PERIOD;

        check_state(s6);
        assert o_aluSrcA = '1' and o_aluSrcB = "00" and o_aluOp = "10"
            report "Mismatch S6 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S6 enables output" severity error;
        wait for c_CLOCK_PERIOD;

        check_state(s7);
        assert o_regDst = '1' and o_memToReg = '0'
            report "Mismatch S7 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '1' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S7 enables output" severity error;
        wait for c_CLOCK_PERIOD;

        check_state(s0);
        i_opcode <= "000100";   -- beq
        wait for c_CLOCK_PERIOD;

        check_state(s1);
        wait for c_CLOCK_PERIOD;

        check_state(s8);
        assert o_aluSrcA = '1' and o_aluSrcB = "10"
            and o_aluOp = "01" and o_pcSrc = "01"
            report "Mismatch S8 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '0' and o_branch = '1' and o_memWrite = '0'
            report "Mismatch S8 enables output" severity error;
        wait for c_CLOCK_PERIOD;

        check_state(s0);
        i_opcode <= "001000";   -- addi
        wait for c_CLOCK_PERIOD;

        check_state(s1);
        wait for c_CLOCK_PERIOD;

        check_state(s9);
        assert o_aluSrcA = '1' and o_aluSrcB = "10" and o_aluOp = "00"
            report "Mismatch S9 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S9 enables output" severity error;
        wait for c_CLOCK_PERIOD;

        check_state(s10);
        assert o_regDst = '0' and o_memToReg = '0'
            report "Mismatch S10 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '0'
            and o_regWrite = '1' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S10 enables output" severity error;
        wait for c_CLOCK_PERIOD;

        check_state(s0);
        i_opcode <= "000010";   -- jump
        wait for c_CLOCK_PERIOD;

        check_state(s1);
        wait for c_CLOCK_PERIOD;

        check_state(s11);
        assert o_pcSrc = "10" report "Mismatch S11 flow output" severity error;
        assert o_irWrite = '0' and o_pcWrite = '1'
            and o_regWrite = '0' and o_branch = '0' and o_memWrite = '0'
            report "Mismatch S11 enables output" severity error;

        wait for c_CLOCK_PERIOD;

        check_state(s0);
        i_opcode <= "111111";   -- undefined instruction
        wait for c_CLOCK_PERIOD;

        check_state(s1);        -- should return to s0
        wait for c_CLOCK_PERIOD;

        check_state(s0);
        
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