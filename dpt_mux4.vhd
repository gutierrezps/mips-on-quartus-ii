library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dpt_mux4 is
port(
	D0, D1: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
	D2, D3: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
	Sel	: in  STD_LOGIC_VECTOR( 1 DOWNTO 0);
	Y		: out STD_LOGIC_VECTOR(31 DOWNTO 0)
);
end dpt_mux4;

architecture behave of dpt_mux4 is

begin
    with Sel select
        Y <= D0 when "00",
             D1 when "01",
             D2 when "10",
             D3 when "11",
             D0 when others;
end;
