-- BCD to 7-segments decoder
-- 
-- Authors: Gutierrez PS, Joao Vitor, Marcos Meira
-- https://github.com/gutierrezps/mips-on-quartus-ii

-- o_hex is (0 to 6) because the output order on the
--  process block is "abcdefg" i.e.
--  o_hex(0) -> a, o_hex(1) -> b, etc.
 
library ieee;
use ieee.std_logic_1164.all;
 
entity bcd2hex is
    port(
        i_bcd: in  std_logic_vector (3 downto 0);
        o_hex: out std_logic_vector (0 to 6)
    );
end bcd2hex;
 
architecture rtl of bcd2hex is
begin
    process (i_bcd)
    begin
        case i_bcd is
            when "0000" => o_hex <= NOT "1111110";
            when "0001" => o_hex <= NOT "0110000";
            when "0010" => o_hex <= NOT "1101101";
            when "0011" => o_hex <= NOT "1111001";
            when "0100" => o_hex <= NOT "0110011";
            when "0101" => o_hex <= NOT "1011011";
            when "0110" => o_hex <= NOT "1011111";
            when "0111" => o_hex <= NOT "1110000";
            when "1000" => o_hex <= NOT "1111111";
            when "1001" => o_hex <= NOT "1110011";
            when others => o_hex <= NOT "0000001";
        end case;
    end process;
end rtl;