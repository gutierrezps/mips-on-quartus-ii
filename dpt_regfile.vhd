library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity dpt_regfile is
port(
    CLK, WE3    : in  STD_LOGIC;
    A1, A2, A3  : in  STD_LOGIC_VECTOR(4 downto 0);
    WD3         : in  STD_LOGIC_VECTOR(31 downto 0);
    RD1, RD2    : out STD_LOGIC_VECTOR(31 downto 0)
);
end dpt_regfile;

architecture behave of dpt_regfile is
    type ramtype is array (31 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
    signal registers: ramtype;
    signal D1, D2: STD_LOGIC_VECTOR(31 downto 0);

begin
    process( CLK ) begin
        if (rising_edge(CLK)) then
            if (A1 = 0) then
                D1 <= X"00000000";
            else
                D1 <= registers(to_integer(unsigned(A1)));
            end if;

            if (A2 = 0) then
                D2 <= X"00000000";
            else
                D2 <= registers(to_integer(unsigned(A2)));
            end if;

            if (WE3 = '1') then
                registers(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;
    
    RD1 <= D1;
    RD2 <= D2;
end;
