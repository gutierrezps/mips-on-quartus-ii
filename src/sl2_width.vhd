-- Shift left by 2 (generic width)
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity sl2_width is
generic (
    g_WIDTH : integer := 32
);
port (
    i_a: in  std_logic_vector(g_WIDTH-1 downto 0);
    o_y: out std_logic_vector(g_WIDTH-1 downto 0)
);
end sl2_width;

architecture rtl of sl2_width is
begin
    o_y(g_WIDTH-1 downto 2) <= i_a(g_WIDTH-3 downto 0);
    o_y(1 downto 0) <= "00";
end;
