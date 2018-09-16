-- MIPS Arithmetic and Logic Unit (generic width)
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_width is
generic (
    g_WIDTH : integer := 32
);
port (
    i_a, i_b: in  std_logic_vector(g_WIDTH-1 downto 0);
    i_ctrl  : in  std_logic_vector( 2 downto 0);
    o_res   : out std_logic_vector(g_WIDTH-1 downto 0);
    o_zero  : out std_logic
);
end alu_width;

architecture rtl of alu_width is

    signal res_add, res_sub : std_logic_vector(g_WIDTH-1 downto 0);
    signal res_and, res_or  :  std_logic_vector(g_WIDTH-1 downto 0);
    signal res_andnot, res_ornot:  std_logic_vector(g_WIDTH-1 downto 0);
    signal res_slt, result  : std_logic_vector(g_WIDTH-1 downto 0);

begin
    res_add     <= i_a +    i_b;
    res_sub     <= i_a -    i_b;
    res_and     <= i_a and  i_b;
    res_or      <= i_a or   i_b;
    res_andnot 	<= i_a and not  i_b;
    res_ornot  	<= i_a or not   i_b;
    res_slt	    <= "000" & X"0000000" & res_sub(g_WIDTH-1);
    
    with i_ctrl select
        result <=   res_and     when "000",
                    res_or      when "001",
                    res_add     when "010",
                    res_andnot  when "100",
                    res_ornot  	when "101",
                    res_sub     when "110",
                    res_slt     when "111",
                    X"00000000" when others;
    
    o_zero <= '1' when result = x"00000000" else '0';
    o_res <= result;
end architecture rtl;