-- Multicycle MIPS Processor - Instruction/Data memory
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Instructions are read-only, starting at address 0x00000000
-- Data memory starts at address 0x00008000 (i_addr(7) = '1')

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity mips_mem is
    port (
        i_clk         : in  std_logic;
        i_addr        : in  std_logic_vector(31 downto 0);
        i_writeEnable : in  std_logic;
        i_writeData   : in  std_logic_vector(31 downto 0);
        o_readData    : out std_logic_vector(31 downto 0)
    );
end mips_mem;

architecture rtl of mips_mem is
    constant c_IMPLEMENTED_POSITIONS: integer := 16;

    type t_memory is array (c_IMPLEMENTED_POSITIONS-1 downto 0)
        of std_logic_vector (31 downto 0);
    
    signal r_dataMem: t_memory;
    
    signal r_outData: std_logic_vector(31 downto 0) := X"00000000";
    
    -- Test program:
    --      addi    $gp, $zero, 32767
    --      addi    $gp, $zero, 1
    --      addi    $s3, $s3, 10
    --  reset:  sw      $zero, 0($gp)
    --  loop:   lw      $s0, 0($gp)
    --      addi    $s1, $zero, 1
    --      add     $s2, $s0, $s1
    --      beq     $s2, $s3, reset
    --      sw      $s2, 0($gp)
    --      j       loop
    constant c_instrMem: t_memory := (
        0   => X"201C7FFF",
        1   => X"201C0001",
        2   => X"2273000A",
        3   => X"AF800000",
        4   => X"8F900000",
        5   => X"20110001",
        6   => X"02119020",
        7   => X"1253FFFB",
        8   => X"AF920000",
        9   => X"08000004",
        others  => X"00000000"
    );
    
    signal w_wordAddr: integer;
    
begin
    w_wordAddr <= to_integer(unsigned(i_addr(6 downto 2)));
    
    writeProc: process (i_clk)
    begin
        if rising_edge(i_clk) and w_wordAddr < c_IMPLEMENTED_POSITIONS then
            if i_writeEnable = '1' and i_addr(7) = '1' then
                r_dataMem(w_wordAddr) <= i_writeData;
            end if;
        end if;
    end process writeProc;
    
    readProc: process (i_addr, r_dataMem)
    begin
        if w_wordAddr < c_IMPLEMENTED_POSITIONS then
            if i_addr(7) = '1' then
                r_outData <= r_dataMem(w_wordAddr);
            else
                r_outData <= c_instrMem(w_wordAddr);
            end if;
        else
            r_outData <= X"00000000";
        end if;
    end process readProc;
    
    o_readData <= r_outData;
end;
