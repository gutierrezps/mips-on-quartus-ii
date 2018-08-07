library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dpt_signext is
port(
	A: in  STD_LOGIC_VECTOR(15 DOWNTO 0);
	Y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
);
end dpt_signext;

architecture behave of dpt_signext is

begin
	Y(31 downto 16) <= X"FFFF" WHEN A(15) = '1' ELSE X"0000";
	Y(15 downto  0) <= A;
end;
