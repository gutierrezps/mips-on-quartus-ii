library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dpt_sl2 is
port(
	A: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
	Y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
);
end dpt_sl2;

architecture behave of dpt_sl2 is

begin
	Y(31 downto 2) <= A(29 downto 0);
	Y( 1 downto 0) <= "00";
end;
