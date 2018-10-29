-- Arithmetic logic unit (generic width) testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity byte2bcd_tb is
end;

architecture bench of byte2bcd_tb is
    constant c_TIME_DELTA : time := 1 ns;

    signal i_byte   : std_logic_vector(7 downto 0);
    signal o_bcd    : std_logic_vector(7 downto 0);

begin -- architecture bench

    dut: entity work.byte2bcd port map (
        i_byte  => i_byte,
        o_bcd   => o_bcd
    );

    stimulus: process
    begin
        for v_tens in 0 to 9 loop
            for v_units in 0 to 9 loop
                i_byte <= std_logic_vector(to_unsigned(v_tens*10 + v_units, 8));
                wait for c_TIME_DELTA;
                assert o_bcd(7 downto 4) = std_logic_vector(to_unsigned(v_tens, 4))
                    report "Tens mismatch" severity error;
                assert o_bcd(3 downto 0) = std_logic_vector(to_unsigned(v_units, 4))
                    report "Units mismatch" severity error;
            end loop;
        end loop;

        wait;
    end process;

end architecture bench;
