-- Register file (generic width) testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Based on results from http://www.doulos.com/knowhow/perl/testbench_creation/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile_width_tb is
end;

architecture bench of regfile_width_tb is
    constant c_CLOCK_PERIOD : time := 10 ns;
    constant c_TIME_DELTA   : time := 1 ns;
    constant c_WIDTH        : integer := 32;
    
    signal r_stop_clock: boolean;

    signal i_clk        : std_logic;
    signal i_we3        : std_logic;
    signal i_a1, i_a2, i_a3 : std_logic_vector(4 downto 0);
    signal i_wd3        : std_logic_vector(c_WIDTH-1 downto 0);
    signal o_rd1, o_rd2 : std_logic_vector(c_WIDTH-1 downto 0);

begin

    dut: entity work.regfile_width
        generic map ( g_WIDTH => c_WIDTH )
        port map (
            i_clk   => i_clk,
            i_we3   => i_we3,
            i_a1    => i_a1,
            i_a2    => i_a2,
            i_a3    => i_a3,
            i_wd3   => i_wd3,
            o_rd1   => o_rd1,
            o_rd2   => o_rd2
        );

    stimulus: process
        constant c_ALL_HIGH : std_logic_vector(c_WIDTH-1 downto 0) := (c_WIDTH-1 downto 0 => '1');
        constant c_ALL_LOW  : std_logic_vector(c_WIDTH-1 downto 0) := (c_WIDTH-1 downto 0 => '0');

        -- write the same data value to all registers
        procedure write_all(
            constant data  : in std_logic_vector(c_WIDTH-1 downto 0)
        )
        is
        begin -- procedure write_all
            i_wd3 <= data;
            i_we3 <= '1';

            -- goes up to 32 to test last register (31)
            for i in 0 to 32 loop

                -- setup address from previous loop
                if i > 0 then
                    i_a1 <= std_logic_vector(to_unsigned(i - 1, i_a1'length));
                    i_a2 <= std_logic_vector(to_unsigned(i - 1, i_a2'length));
                end if ;
                
                if i < 32 then
                    -- set write address (0 to 31)
                    i_a3 <= std_logic_vector(to_unsigned(i, i_a3'length));
                else
                    -- disable writing on last check
                    i_we3 <= '0';
                end if;

                -- to prevent read-during-write
                wait for c_TIME_DELTA;

                
                if i = 1 then   -- test register zero (a1 and a2 = 0)
                    assert o_rd1 = c_ALL_LOW report "mismatch" severity error;
                    assert o_rd2 = c_ALL_LOW report "mismatch" severity error;

                elsif i > 1 then   -- test other registers
                    assert o_rd1 = data report "mismatch" severity error;
                    assert o_rd2 = data report "mismatch" severity error;
                end if;

                -- next clock
                wait for c_CLOCK_PERIOD - c_TIME_DELTA;
            end loop;
        end procedure write_all;

        -- check if all registers except 'addr' contain 'data'
        procedure test_others(
            constant addr  : in std_logic_vector(4 downto 0);
            constant data  : in std_logic_vector(c_WIDTH-1 downto 0)
        )
        is
        begin
            for i in 0 to 31 loop
                i_a1 <= std_logic_vector(to_unsigned(i, i_a1'length));
                i_a2 <= std_logic_vector(to_unsigned(i, i_a2'length));
                
                wait for c_TIME_DELTA;

                if i = 0 then   -- test register zero
                    assert o_rd1 = c_ALL_LOW report "mismatch" severity error;
                    assert o_rd2 = c_ALL_LOW report "mismatch" severity error;
                    
                elsif i /= to_integer(unsigned(addr)) then
                    assert o_rd1 = data report "mismatch" severity error;
                    assert o_rd2 = data report "mismatch" severity error;
                end if;

                wait for c_TIME_DELTA;
            end loop;
        end procedure test_others;

    begin -- stimulus: process
        
        -- initialize input signals
        i_a1 <= "00000";
        i_a2 <= "00000";
        i_a3 <= "00000";
        i_we3 <= '0';
        i_wd3 <= c_ALL_LOW;

        -- write zero to all registers
        write_all(c_ALL_LOW);

        -- test each register, by writing c_ALL_HIGH and checking
        -- if other registers weren't changed
        for i in 1 to 31 loop
            i_we3 <= '1';
            i_a3 <= std_logic_vector(to_unsigned(i, i_a3'length));
            i_wd3 <= c_ALL_HIGH;

            -- write c_ALL_HIGH
            wait until rising_edge(i_clk);
            wait for c_TIME_DELTA;
            i_we3 <= '0';

            -- check other registers
            test_others(i_a3, c_ALL_LOW);
            wait until falling_edge(i_clk);

            -- reset value to c_ALL_LOW
            i_we3 <= '1';
            i_wd3 <= c_ALL_LOW;
            wait until rising_edge(i_clk);
            wait for c_TIME_DELTA;
            i_we3 <= '0';
            wait until falling_edge(i_clk);

            -- go to next register
        end loop;

        
        -- do the same test again, but with all bits flipped
        -- i.e. write all high, and zero out each register

        write_all(c_ALL_HIGH);

        for i in 1 to 31 loop
            i_we3 <= '1';
            i_a3 <= std_logic_vector(to_unsigned(i, i_a3'length));
            i_wd3 <= c_ALL_LOW;

            wait until rising_edge(i_clk);
            wait for c_TIME_DELTA;
            i_we3 <= '0';

            test_others(i_a3, c_ALL_HIGH);
            wait until falling_edge(i_clk);

            i_we3 <= '1';
            i_wd3 <= c_ALL_HIGH;
            wait until rising_edge(i_clk);
            wait for c_TIME_DELTA;
            i_we3 <= '0';
            wait until falling_edge(i_clk);
        end loop;

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