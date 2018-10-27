-- Multiplexer 4 to 1 (generic width) testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Based on: VHDL Testbench Tutorial, by Sahand Kashani-Akhavan


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4_width_tb is
end;

architecture bench of mux4_width_tb is
    constant c_TIME_DELTA : time := 100 ns;
    constant c_WIDTH: integer := 32;

    signal i_data0  : std_logic_vector(c_WIDTH-1 downto 0);
    signal i_data1  : std_logic_vector(c_WIDTH-1 downto 0);
    signal i_data2  : std_logic_vector(c_WIDTH-1 downto 0);
    signal i_data3  : std_logic_vector(c_WIDTH-1 downto 0);
    signal i_sel    : std_logic_vector(1 downto 0);
    signal o_data   : std_logic_vector(c_WIDTH-1 downto 0) ;

begin -- architecture bench

    dut: entity work.mux4_width port map (
        i_data0 => i_data0,
        i_data1 => i_data1,
        i_data2 => i_data2,
        i_data3 => i_data3,
        i_sel   => i_sel,
        o_data  => o_data
    );

    stimulus: process
        procedure check_mux(
            constant data0  : in std_logic_vector(c_WIDTH-1 downto 0);
            constant data1  : in std_logic_vector(c_WIDTH-1 downto 0);
            constant data2  : in std_logic_vector(c_WIDTH-1 downto 0);
            constant data3  : in std_logic_vector(c_WIDTH-1 downto 0);
            constant sel    : in std_logic_vector(1 downto 0);
            constant data   : in std_logic_vector(c_WIDTH-1 downto 0))
        is
        begin -- procedure check_mux
            i_data0 <= data0;
            i_data1 <= data1;
            i_data2 <= data2;
            i_data3 <= data3;
            i_sel   <= sel;
            wait for c_TIME_DELTA;

            -- Check output against expected result.
            assert o_data = data report "mismatch" severity error;
        end procedure check_mux;
        
        constant c_ALL_HIGH : std_logic_vector(c_WIDTH-1 downto 0) := (c_WIDTH-1 downto 0 => '1');
        constant c_ALL_LOW  : std_logic_vector(c_WIDTH-1 downto 0) := (c_WIDTH-1 downto 0 => '0');

    begin -- stimulus

        check_mux(c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, "00", c_ALL_HIGH);
        check_mux(c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, "01", c_ALL_LOW);
        check_mux(c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, "10", c_ALL_LOW);
        check_mux(c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, "11", c_ALL_LOW);

        check_mux(c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, "00", c_ALL_LOW);
        check_mux(c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, "01", c_ALL_HIGH);
        check_mux(c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, "10", c_ALL_LOW);
        check_mux(c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, c_ALL_LOW, "11", c_ALL_LOW);

        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, "00", c_ALL_LOW);
        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, "01", c_ALL_LOW);
        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, "10", c_ALL_HIGH);
        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, c_ALL_LOW, "11", c_ALL_LOW);

        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, "00", c_ALL_LOW);
        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, "01", c_ALL_LOW);
        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, "10", c_ALL_LOW);
        check_mux(c_ALL_LOW, c_ALL_LOW, c_ALL_LOW, c_ALL_HIGH, "11", c_ALL_HIGH);

        wait;
    end process; -- stimulus

end architecture bench;
