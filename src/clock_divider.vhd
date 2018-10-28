-- Clock divider
--
-- After g_FACTOR rising edges of i_clk, o_clk is toggled
--
-- Authors: Gutierrez PS, Joao Vitor, Marcos Meira
-- https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity clock_divider is
    generic (
        g_FACTOR : integer := 25000000
    );
    port (
        i_clk   : in  std_logic;
        o_clk   : out std_logic
    );
end clock_divider;

architecture rtl of clock_divider is
    signal r_clkOut: std_logic := '0';
begin
    process (i_clk)
        variable v_count: integer := 0;
    begin
        if rising_edge(i_clk) then
            v_count := v_count + 1;
            if v_count = g_FACTOR then
                r_clkOut <= not r_clkOut;
                v_count := 0;
            end if;
        end if;
    end process;

    o_clk <= r_clkOut;
end rtl;