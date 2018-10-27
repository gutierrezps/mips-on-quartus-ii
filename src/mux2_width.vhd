-- Multiplexer 2 to 1 (generic width)
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Based on: https://www.nandland.com/vhdl/modules/mux-multiplexor-in-fpga-vhdl-verilog.html

library ieee;
use ieee.std_logic_1164.all;

entity mux2_width is
    generic (
        g_WIDTH : integer := 32     -- Override when instantiated
    );
    port (
        i_data0 : in  std_logic_vector(g_WIDTH-1 downto 0);
        i_data1 : in  std_logic_vector(g_WIDTH-1 downto 0);
        i_sel   : in  std_logic;
        o_data  : out std_logic_vector(g_WIDTH-1 downto 0)
    );
end mux2_width;

architecture rtl of mux2_width is
begin
    o_data <= i_data0 when i_sel = '0' else i_data1;
end;
