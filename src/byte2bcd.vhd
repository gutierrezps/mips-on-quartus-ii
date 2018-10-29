-- Byte to BCD conversion
-- 
-- Authors: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity byte2bcd is
    port (
        i_byte  : in  std_logic_vector (7 downto 0);
        o_bcd   : out std_logic_vector (7 downto 0)
    );
end byte2bcd;
 
architecture rtl of byte2bcd is
begin
    process (i_byte)
        variable v_tens : integer := 0;
        variable v_units : integer := 0;
    begin
        v_tens := to_integer(unsigned(i_byte)) / 10;
        v_units := to_integer(unsigned(i_byte)) - 10 * v_tens;

        o_bcd(7 downto 4) <= std_logic_vector(to_unsigned(v_tens, 4));
        o_bcd(3 downto 0) <= std_logic_vector(to_unsigned(v_units, 4));
    end process;
end rtl;