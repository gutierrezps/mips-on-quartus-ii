-- Multiplexer 2 to 1 (generic width) testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Based on: VHDL Testbench Tutorial, by Sahand Kashani-Akhavan


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2_width_tb is
end;

architecture bench of mux2_width_tb is
    constant c_TIME_DELTA : time := 100 ns;
    constant g_WIDTH: integer := 32;

    signal i_data0: std_logic_vector(g_WIDTH-1 downto 0);
    signal i_data1: std_logic_vector(g_WIDTH-1 downto 0);
    signal i_sel: std_logic;
    signal o_data: std_logic_vector(g_WIDTH-1 downto 0) ;

begin -- architecture bench

    dut: entity work.mux2_width port map (
        i_data0 => i_data0,
        i_data1 => i_data1,
        i_sel   => i_sel,
        o_data  => o_data
    );

    stimulus: process
    
        procedure check_mux(
            constant data0  : in std_logic_vector(g_WIDTH-1 downto 0);
            constant data1  : in std_logic_vector(g_WIDTH-1 downto 0);
            constant sel    : in std_logic;
            constant data   : in std_logic_vector(g_WIDTH-1 downto 0))
        is
        begin
            i_data0 <= data0;
            i_data1 <= data1;
            i_sel   <= sel;
            wait for c_TIME_DELTA;

            -- Check output against expected result.
            assert o_data = data
            report "mismatch" severity error;
        end procedure check_mux;
    
    begin
        check_mux(X"FFFFFFFF", X"00000000", '0', X"FFFFFFFF");
        check_mux(X"FFFFFFFF", X"00000000", '1', X"00000000");
        check_mux(X"00000000", X"FFFFFFFF", '0', X"00000000");
        check_mux(X"00000000", X"FFFFFFFF", '1', X"FFFFFFFF");
        wait;
    end process;

end architecture bench;
