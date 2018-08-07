library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dpt_mux2 is
port(
	D0, D1: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
	Sel	: in  STD_LOGIC;
	Y		: out STD_LOGIC_VECTOR(31 DOWNTO 0)
);
end dpt_mux2;

architecture behave of dpt_mux2 is

begin
	Y <= D0 when Sel = '0' else D1;
end;
