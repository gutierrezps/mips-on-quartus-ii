-- D flip flop (generic width) with rst and enable
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity reg_width is
generic (
    g_WIDTH : integer := 32
);
port (
    i_clk : in  std_logic;
    i_rst : in  std_logic;
    i_en  : in  std_logic;
    i_d   : in  std_logic_vector(g_WIDTH-1 downto 0);
    o_q   : out std_logic_vector(g_WIDTH-1 downto 0)
);
end reg_width;

architecture rtl of reg_width is
begin
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_q <= (g_WIDTH-1 downto 0 => '0');
            elsif i_en = '1' then
                o_q <= i_d;
            end if;
        end if;
    end process;
end;
