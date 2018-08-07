library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dpt_mux2_5b is
port(
	D0, D1: in  STD_LOGIC_VECTOR(4 DOWNTO 0);
	sel	: in  STD_LOGIC;
	Y		: out STD_LOGIC_VECTOR(4 DOWNTO 0)
);
end dpt_mux2_5b;

architecture behave of dpt_mux2_5b is

begin
	Y <= D0 when sel = '0' else D1;
end;
