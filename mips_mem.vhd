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
    
    constant instrMem: memory := (
        0   => X"201C4000",     --          addi $gp, $zero, 4000h
        1   => X"AF800000",     --          sw   $zero, 0($gp)
        2   => X"8F900000",     -- loop:    lw   $s0, 0($gp)
        3   => X"20110001",     --          addi $s1, $zero, 1
        4   => X"02119020",     --          add  $s2, $s0, $s1
        5   => X"AF920000",     --          sw   $s2, 0($gp)
        6   => X"08100002",     --          j    loop
        others  => X"00000000"
    );
    
    signal realAddr: STD_LOGIC_VECTOR(3 downto 0);
    
begin
    realAddr <= Addr(5 downto 2);
    
    process (CLK) begin
        if (rising_edge(CLK)) then
            if (WE = '1' and Addr(6) = '1') then
                dataMem(to_integer(unsigned(realAddr))) <= WriteData;
            end if;
        end if;
    end process;
    
    process (Addr, dataMem) begin
        if (Addr(6) = '1') then     -- Addr = 4xxxh, data mem
            outData <= dataMem(to_integer(unsigned(realAddr)));
        else
            outData <= instrMem(to_integer(unsigned(realAddr)));
        end if;
    end process;
    
    ReadData <= outData;
end;
