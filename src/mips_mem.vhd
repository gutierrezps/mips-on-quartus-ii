library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity mips_mem is
port(
    CLK         : in  STD_LOGIC;
    Addr        : in  STD_LOGIC_VECTOR(31 downto 0);
    WE          : in  STD_LOGIC;
    WriteData   : in  STD_LOGIC_VECTOR(31 downto 0);
    ReadData    : out STD_LOGIC_VECTOR(31 downto 0)
);
end mips_mem;

architecture sync of mips_mem is
    type memory is array (15 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
    
    signal dataMem: memory;
    
    signal outData: STD_LOGIC_VECTOR(31 downto 0);
    
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
    constant instrMem: memory := (
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
    
    signal realAddr: STD_LOGIC_VECTOR(3 downto 0);
    
begin
    realAddr <= Addr(5 downto 2);
    
    process (CLK) begin
        if (rising_edge(CLK)) then
            if (WE = '1' and Addr(7) = '1') then
                dataMem(to_integer(unsigned(realAddr))) <= WriteData;
            end if;
        end if;
    end process;
    
    process (Addr, dataMem) begin
        if (Addr(7) = '1') then     -- Addr = 8xxxh, data mem
            outData <= dataMem(to_integer(unsigned(realAddr)));
        else
            outData <= instrMem(to_integer(unsigned(realAddr)));
        end if;
    end process;
    
    ReadData <= outData;
end;
