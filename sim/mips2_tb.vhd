-- MIPS struct #2 testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips2_tb is
end;

architecture bench of mips2_tb is
    constant c_CLOCK_PERIOD : time := 10 ns;
    constant c_TIME_DELTA   : time := 1 ns;
    
    signal r_stop_clock: boolean;

    signal i_clk            : std_logic;
    signal i_rst            : std_logic;
    signal o_ctrlState      : std_logic_vector( 3 downto 0);
    signal o_data0          : std_logic_vector(31 downto 0);
    signal o_data1          : std_logic_vector(31 downto 0);

    -- Build an enumerated type for the state machine
    type t_stateType is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11);

begin

    dut: entity work.mips2 port map (
        i_clk       => i_clk,
        i_rst       => i_rst,
        o_ctrlState => o_ctrlState,
        o_data0     => o_data0,
        o_data1     => o_data1
    );

    stimulus: process
        procedure check_state(constant expected_state: in t_stateType) is
        begin
            assert expected_state = t_stateType'VAL(to_integer(unsigned(o_ctrlState)))
                report "State mismatch" severity error;
        end procedure check_state;

        procedure check_data0(constant data0: in integer) is
        begin
            wait for c_TIME_DELTA;
            assert o_data0 = std_logic_vector(to_unsigned(data0, o_data0'length))
                report "data0 mismatch" severity error;
        end procedure check_data0;
    begin
        -- Reset
        i_rst <= '1';
        wait until falling_edge(i_clk);     -- reset datapath
        wait until rising_edge(i_clk);      -- reset FSM
        wait for 1 ns;              -- wait before de-assert reset
        i_rst <= '0';               -- to prevent datapath metastability

        --------------------------------------------------------
        -- addi    $gp, $zero, 32767
        for i in 1 to 4 loop    -- s0, s1, s9, s10
            wait until falling_edge(i_clk);
        end loop;
        
        --------------------------------------------------------
        -- addi    $gp, $gp, 1
        for i in 1 to 4 loop
            wait until falling_edge(i_clk);
        end loop;

        --------------------------------------------------------
        -- addi    $s3, $zero, 10
        for i in 1 to 4 loop
            wait until falling_edge(i_clk);
        end loop;

        --------------------------------------------------------
        -- reset: sw      $zero, 0($gp)
        for i in 1 to 4 loop        -- s0, s1, s2, s5
            wait until falling_edge(i_clk);
        end loop;
        wait for c_TIME_DELTA;
        check_data0(0);

        --------------------------------------------------------
        -- loop: lw      $s0, 0($gp)
        for i in 1 to 5 loop        -- s0, s1, s2, s3, s4
            wait until falling_edge(i_clk);
        end loop;

        --------------------------------------------------------
        -- addi    $s1, $zero, 1
        for i in 1 to 4 loop
            wait until falling_edge(i_clk);
        end loop;

        --------------------------------------------------------
        -- add     $s2, $s0, $s1
        for i in 1 to 4 loop
            wait until falling_edge(i_clk);
        end loop;

        --------------------------------------------------------
        -- beq     $s2, $s3, reset
        for i in 1 to 3 loop
            wait until falling_edge(i_clk);
        end loop;

        --------------------------------------------------------
        -- sw      $s2, 0($gp)
        for i in 1 to 4 loop
            wait until falling_edge(i_clk);
        end loop;
        wait for c_TIME_DELTA;
        check_data0(1);

        --------------------------------------------------------
        -- j       loop
        for i in 1 to 3 loop
            wait until falling_edge(i_clk);
        end loop;

        --------------------------------------------------------
        -- wait until end of sw instruction
        for i in 1 to 20 loop
            wait until falling_edge(i_clk);
        end loop;
        wait for c_TIME_DELTA;
        check_data0(2);

        --------------------------------------------------------
        -- wait until sw instruction be executed again
        for i in 1 to 23 loop
            wait until falling_edge(i_clk);
        end loop;
        wait for c_TIME_DELTA;
        check_data0(3);

        --------------------------------------------------------
        -- wait until data0 be 9 (138), until sw is executed
        for i in 1 to 138 loop
            wait until falling_edge(i_clk);
        end loop;
        wait for c_TIME_DELTA;
        check_data0(9);

        --------------------------------------------------------
        -- wait until sw instruction be executed again, to reset data0
        for i in 1 to 23 loop
            wait until falling_edge(i_clk);
        end loop;
        wait for c_TIME_DELTA;
        check_data0(0);

        --------------------------------------------------------
        -- wait until sw instruction be executed again ()
        for i in 1 to 23 loop
            wait until falling_edge(i_clk);
        end loop;
        wait for c_TIME_DELTA;
        check_data0(1);
        
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