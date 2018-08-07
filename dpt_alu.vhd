LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dpt_alu IS
PORT(
	A, B	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
	Ctrl	: IN  STD_LOGIC_VECTOR( 2 DOWNTO 0);
	Res	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	Zero	: OUT STD_LOGIC
);
END dpt_alu;

ARCHITECTURE behave OF dpt_alu IS

	SIGNAL res_add, res_sub: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL res_and, res_or:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL res_andnot, res_ornot:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal res_slt, result : STD_LOGIC_VECTOR(31 downto 0);

BEGIN
	res_add <= A + B;
	res_sub <= A - B;
	res_and <= A AND B;
	res_or  <= A OR  B;
	res_andnot 	<= A AND NOT B;
	res_ornot  	<= A OR NOT B;
	res_slt	<= "000" & X"0000000" & res_sub(31);
	
	WITH Ctrl SELECT
		result <= res_and 	WHEN "000",
				res_or  		WHEN "001",
				res_add 		WHEN "010",
				res_andnot 	WHEN "100",
				res_ornot  	WHEN "101",
				res_sub 		WHEN "110",
				res_slt 		WHEN "111",
				X"00000000" WHEN others;
	
	Zero <= '1' WHEN result = X"00000000" ELSE '0';
	
	Res <= result;
END;