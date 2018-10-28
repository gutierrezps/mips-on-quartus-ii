-- MIPS Instruction/Data Memory testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_mem_tb is
end;

architecture bench of mips_mem_tb is
    constant c_CLOCK_PERIOD: time := 10 ns;
    constant c_TIME_DELTA: time := 1 ns;
    
    signal r_stop_clock: boolean;

    signal i_clk        : std_logic;
    signal o_readData   : std_logic_vector(31 downto 0);
    signal o_data0      : std_logic_vector(31 downto 0);
    signal o_data1      : std_logic_vector(31 downto 0);
    signal i_writeData  : std_logic_vector(31 downto 0);
    signal i_addr       : std_logic_vector(31 downto 0);
    signal i_writeEnable: std_logic := '0';

begin

    dut: entity work.mips_mem port map (
        i_clk           => i_clk,
        i_writeData     => i_writeData,
        i_addr          => i_addr,
        i_writeEnable   => i_writeEnable,
        o_readData      => o_readData,
        o_data0         => o_data0,
        o_data1         => o_data1
    );

    stimulus: process
    begin
        -- Test instruction memory (read-only)

        i_addr <= X"00000000";
        wait for c_TIME_DELTA;
        assert o_readData = X"201C7FFF" report "instr mismatch" severity error;

        wait for c_TIME_DELTA;

        i_addr <= X"00000004";
        wait for c_TIME_DELTA;
        assert o_readData = X"239C0001" report "instr mismatch" severity error;

        wait for c_TIME_DELTA;

        i_addr <= X"00000008";
        wait for c_TIME_DELTA;
        assert o_readData = X"2013000A" report "instr mismatch" severity error;

        wait until falling_edge(i_clk);


        -- Test data memory (read/write)

        i_addr <= X"00008000";
        i_writeData <= X"12345678";
        i_writeEnable <= '1';
        wait until rising_edge(i_clk);
        wait for c_TIME_DELTA;
        assert o_readData = X"12345678" report "write failed" severity error;
        assert o_data0 = X"12345678" report "data0 mismatch" severity error;

        wait for c_TIME_DELTA;

        i_addr <= X"00008004";
        i_writeData <= X"98765432";
        wait until rising_edge(i_clk);
        wait for c_TIME_DELTA;
        assert o_readData = X"98765432" report "write failed" severity error;
        assert o_data0 = X"12345678" report "data0 mismatch" severity error;
        assert o_data1 = X"98765432" report "data1 mismatch" severity error;

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