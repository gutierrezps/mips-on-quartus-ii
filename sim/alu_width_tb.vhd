-- Arithmetic logic unit (generic width) testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_width_tb is
end;

architecture bench of alu_width_tb is
    constant c_TIME_DELTA : time := 10 ns;
    constant g_WIDTH: integer := 32;

    signal i_a, i_b : std_logic_vector(g_WIDTH-1 downto 0);
    signal i_ctrl   : std_logic_vector(2 downto 0);
    signal o_res    : std_logic_vector(g_WIDTH-1 downto 0) ;
    signal o_zero   : std_logic;

begin -- architecture bench

    dut: entity work.alu_width
    port map (
        i_a     => i_a,
        i_b     => i_b,
        i_ctrl  => i_ctrl,
        o_res   => o_res,
        o_zero  => o_zero
    );

    stimulus: process
    begin
        i_ctrl  <= "010";    -- add
        i_a     <= X"00000000";
        i_b     <= X"00000000";

        wait for c_TIME_DELTA;
        assert o_res = X"00000000" report "Add error" severity error;
        assert o_zero = '1' report "zero error" severity error;

        i_a     <= X"FFFFFFFF";
        
        wait for c_TIME_DELTA;
        assert o_res = X"FFFFFFFF" report "Add error" severity error;
        assert o_zero = '0' report "zero error" severity error;

        i_b <= X"00000001";
        wait for c_TIME_DELTA;
        assert o_res = X"00000000" report "Add error" severity error;
        assert o_zero = '1' report "zero error" severity error;

        wait;
    end process;

end architecture bench;
