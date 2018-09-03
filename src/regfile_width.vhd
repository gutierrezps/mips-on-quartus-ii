library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity regfile_width is
generic (
    g_WIDTH : integer := 32     -- Override when instantiated
);
port (
    i_clk, i_we3    : in  std_logic;
    i_a1, i_a2, i_a3: in  std_logic_vector(4 downto 0);
    i_wd3           : in  std_logic_vector(g_WIDTH-1 downto 0);
    o_rd1, o_rd2    : out std_logic_vector(g_WIDTH-1 downto 0)
);
end regfile_width;

architecture rtl of regfile_width is
    type ramtype is array (g_WIDTH-1 downto 0) of std_logic_vector(g_WIDTH-1 downto 0);
    
    signal r_registers: ramtype;
    signal r_d1, r_d2: std_logic_vector(g_WIDTH-1 downto 0);

begin
    writing: process (i_clk)
    begin
        if rising_edge(i_clk) and i_we3 = '1' then
            r_registers(to_integer(unsigned(i_a3))) <= i_wd3;
        end if;
    end process; -- writing

    reading: process (i_a1, i_a2, r_registers)
    begin
        if (i_a1 = 0) then
            r_d1 <= (g_WIDTH-1 downto 0 => '0');
        else
            r_d1 <= r_registers(to_integer(unsigned(i_a1)));
        end if;

        if (i_a2 = 0) then
            r_d2 <= (g_WIDTH-1 downto 0 => '0');
        else
            r_d2 <= r_registers(to_integer(unsigned(i_a2)));
        end if;
    end process; -- reading
    
    o_rd1 <= r_d1;
    o_rd2 <= r_d2;
end architecture rtl;
