-- Multiplexer 2 to 1 (generic width)
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Based on: https://www.nandland.com/vhdl/modules/mux-multiplexor-in-fpga-vhdl-verilog.html

library ieee;
use ieee.std_logic_1164.all;

entity mux4_width is
generic (
    g_WIDTH : integer := 32     -- Override when instantiated
);
port (
    i_data0,
    i_data1,
    i_data2,
    i_data3 : in  std_logic_vector(g_WIDTH-1 downto 0);
    i_sel   : in  std_logic_vector(1 downto 0);
    o_data  : out std_logic_vector(g_WIDTH-1 downto 0)
);
end mux4_width;

architecture rtl of mux4_width is
begin
    with i_sel select
        o_data <=
            i_data1 when "01",
            i_data2 when "10",
            i_data3 when "11",
            i_data0 when others;
end;
