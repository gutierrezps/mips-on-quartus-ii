library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dpt_pcsl2 is
port(
	A: in  STD_LOGIC_VECTOR(25 DOWNTO 0);
	Y: out STD_LOGIC_VECTOR(27 DOWNTO 0)
);
end dpt_pcsl2;

architecture behave of dpt_pcsl2 is

begin
	Y(27 downto 2) <= A(25 downto 0);
	Y( 1 downto 0) <= "00";
end;
