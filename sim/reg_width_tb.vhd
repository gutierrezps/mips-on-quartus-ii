-- Register (generic width) testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Based on results from http://www.doulos.com/knowhow/perl/testbench_creation/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_width_tb is
end;

architecture bench of reg_width_tb is
    constant c_CLOCK_PERIOD: time := 10 ns;
    constant c_WIDTH: integer := 32;
    
    signal r_stop_clock: boolean;

    signal i_clk: std_logic;
    signal i_rst: std_logic;
    signal i_en: std_logic;
    signal i_d: std_logic_vector(c_WIDTH-1 downto 0);
    signal o_q: std_logic_vector(c_WIDTH-1 downto 0) ;

begin

    dut: entity work.reg_width
        generic map ( g_WIDTH => c_WIDTH )
        port map (
            i_clk   => i_clk,
            i_rst   => i_rst,
            i_en    => i_en,
            i_d     => i_d,
            o_q     => o_q
        );

    stimulus: process
        constant c_ALL_HIGH : std_logic_vector(c_WIDTH-1 downto 0) := (c_WIDTH-1 downto 0 => '1');
        constant c_ALL_LOW  : std_logic_vector(c_WIDTH-1 downto 0) := (c_WIDTH-1 downto 0 => '0');
    begin
        -- Reset
        i_rst <= '1';
        wait for c_CLOCK_PERIOD;
        i_rst <= '0';
        assert o_q = c_ALL_LOW report "reset failed" severity error;

        -- Test enable on low level (disabled)
        i_en <= '0';
        i_d <= c_ALL_HIGH;
        wait for c_CLOCK_PERIOD;
        assert o_q = c_ALL_LOW report "not enable failed" severity error;

        -- Test writing
        i_en <= '1';
        wait for c_CLOCK_PERIOD;
        assert o_q = c_ALL_HIGH report "write high failed" severity error;

        i_d <= c_ALL_LOW;
        wait for c_CLOCK_PERIOD;
        assert o_q = c_ALL_LOW report "write low failed" severity error;

        i_d <= c_ALL_HIGH;
        wait for c_CLOCK_PERIOD;
        assert o_q = c_ALL_HIGH report "write high failed" severity error;

        -- Reset again
        i_en <= '-';
        i_rst <= '1';
        wait for c_CLOCK_PERIOD;
        i_rst <= '0';
        assert o_q = c_ALL_LOW report "reset failed" severity error;

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