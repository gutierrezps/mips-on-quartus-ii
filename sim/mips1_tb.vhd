-- MIPS struct #1 testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips1_tb is
end;

architecture bench of mips1_tb is
    constant c_CLOCK_PERIOD : time := 10 ns;
    constant c_TIME_DELTA   : time := 1 ns;
    
    signal r_stop_clock: boolean;

    signal i_clk            : std_logic;
    signal i_rst            : std_logic;
    signal o_memReadData    : std_logic_vector(31 downto 0);
    signal o_memWriteData   : std_logic_vector(31 downto 0);
    signal o_memAddr        : std_logic_vector(31 downto 0);
    signal o_memWrite       : std_logic;
    signal o_dptOpcode      : std_logic_vector( 5 downto 0);
    signal o_dptALUResult   : std_logic_vector(31 downto 0);
    signal o_ctrlState      : std_logic_vector( 3 downto 0);

    -- Build an enumerated type for the state machine
    type t_stateType is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11);

begin

    dut: entity work.mips1 port map (
        i_clk           => i_clk,
        i_rst           => i_rst,
        o_memReadData   => o_memReadData,
        o_memWriteData  => o_memWriteData,
        o_memAddr       => o_memAddr,
        o_memWrite      => o_memWrite,
        o_dptOpcode     => o_dptOpcode,
        o_dptALUResult  => o_dptALUResult,
        o_ctrlState     => o_ctrlState
    );

    stimulus: process
        procedure check_state(constant expected_state: in t_stateType) is
        begin
            assert expected_state = t_stateType'VAL(to_integer(unsigned(o_ctrlState)))
                report "State mismatch" severity error;
        end procedure; -- check_state

        procedure check_mem_addr(constant addr: in integer) is
        begin
            assert o_memAddr = std_logic_vector(to_unsigned(addr, o_memAddr'length))
                report "mem addr mismatch" severity error;
        end procedure; -- check_mem_addr

        procedure check_opcode(constant opcode: in integer) is
        begin
            assert o_dptOpcode = std_logic_vector(to_unsigned(opcode, o_dptOpcode'length))
                report "opcode mismatch" severity error;
        end procedure; -- ckeck_opcode

        procedure check_alu(constant alu: in integer) is
        begin
            wait for c_TIME_DELTA;
            assert o_dptALUResult = std_logic_vector(to_unsigned(alu, o_dptALUResult'length))
                report "ALU result mismatch" severity error;
        end procedure; -- ckeck_opcode
    begin
        -- Reset
        i_rst <= '1';
        wait until falling_edge(i_clk);     -- reset datapath
        wait until rising_edge(i_clk);      -- reset FSM
        wait for 1 ns;              -- wait before de-assert reset
        i_rst <= '0';               -- to prevent datapath metastability
        wait until falling_edge(i_clk);

        --------------------------------------------------------
        -- addi    $gp, $zero, 32767
        check_state(s0);
        check_mem_addr(0);

        wait until falling_edge(i_clk);
        check_state(s1); check_opcode(8);

        wait until falling_edge(i_clk);
        check_state(s9); check_alu(32767);

        wait until falling_edge(i_clk);
        check_state(s10);

        --------------------------------------------------------
        -- addi    $gp, $gp, 1
        wait until falling_edge(i_clk);
        check_state(s0); check_mem_addr(4);

        wait until falling_edge(i_clk);
        check_state(s1); check_opcode(8);

        wait until falling_edge(i_clk);
        check_state(s9); check_alu(32768);

        wait until falling_edge(i_clk);
        check_state(s10);

        --------------------------------------------------------
        -- addi    $s3, $zero, 10
        wait until falling_edge(i_clk);
        check_state(s0); check_mem_addr(8);

        wait until falling_edge(i_clk);
        check_state(s1); check_opcode(8);

        wait until falling_edge(i_clk);
        check_state(s9); check_alu(10);

        wait until falling_edge(i_clk);
        check_state(s10);

        --------------------------------------------------------
        -- sw      $zero, 0($gp)
        wait until falling_edge(i_clk);
        check_state(s0); check_mem_addr(12);

        wait until falling_edge(i_clk);
        check_state(s1); check_opcode(43);

        wait until falling_edge(i_clk);
        check_state(s2); check_alu(32768);

        wait until falling_edge(i_clk);
        check_state(s5);
        wait for c_TIME_DELTA;
        assert o_memWriteData = X"00000000" report "mem write mismatch" severity error;

        wait for c_CLOCK_PERIOD*5;
        
        
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