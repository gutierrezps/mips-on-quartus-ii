library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dpt_reg is
port(
	CLK: in  STD_LOGIC;
	RST: in  STD_LOGIC;
	EN	: in  STD_LOGIC;
	D	: in  STD_LOGIC_VECTOR(31 downto 0);
	Q	: out STD_LOGIC_VECTOR(31 downto 0)
);
end dpt_reg;

architecture sync of dpt_reg is

begin
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				q <= X"00000000";
			elsif en = '1' then
					q <= d;
			end if;
		end if;
	end process;
end;
