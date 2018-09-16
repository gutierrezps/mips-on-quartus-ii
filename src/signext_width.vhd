-- Sign extender (generic input and output widths)
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity signext_width is
generic (
    g_INPUT_WIDTH   : integer := 16;
    g_OUTPUT_WIDTH  : integer := 32
);
port (
    i_a: in  std_logic_vector(g_INPUT_WIDTH-1 downto 0);
    o_y: out std_logic_vector(g_OUTPUT_WIDTH-1 downto 0)
);
end signext_width;

architecture rtl of signext_width is
begin
    -- set extra bits of output according to signal bit (MSb) of input
    extraBits : for i in g_INPUT_WIDTH to g_OUTPUT_WIDTH-1 generate
        o_y(i) <= i_a(g_INPUT_WIDTH-1);
    end generate;

    o_y(g_INPUT_WIDTH-1 downto 0) <= i_a;
end;
