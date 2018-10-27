-- Multicycle MIPS / Control Unit / ALU Decoder testbench
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_aludec_tb is
end;

architecture bench of ctrl_aludec_tb is
    constant c_TIME_DELTA : time := 10 ns;

    signal i_funct      : std_logic_vector(5 downto 0);
    signal i_aluOp      : std_logic_vector(1 downto 0);
    signal o_aluControl : std_logic_vector(2 downto 0);

begin -- architecture bench

    dut: entity work.ctrl_aludec port map (
        i_funct => i_funct,
        i_aluOp => i_aluOp,
        o_aluControl => o_aluControl
    );

    stimulus: process
    begin
        i_aluOp <= "00";    -- add
        wait for c_TIME_DELTA;
        assert o_aluControl = "010" report "mismatch" severity error;

        i_aluOp <= "01";    -- sub
        wait for c_TIME_DELTA;
        assert o_aluControl = "110" report "mismatch" severity error;

        i_aluOp <= "10";    -- check funct
        
        i_funct <= "100000";    -- add
        wait for c_TIME_DELTA;
        assert o_aluControl = "010" report "mismatch" severity error;

        i_funct <= "100010";    -- sub
        wait for c_TIME_DELTA;
        assert o_aluControl = "110" report "mismatch" severity error;

        i_funct <= "100100";    -- and
        wait for c_TIME_DELTA;
        assert o_aluControl = "000" report "mismatch" severity error;

        i_funct <= "100101";    -- or
        wait for c_TIME_DELTA;
        assert o_aluControl = "001" report "mismatch" severity error;

        i_funct <= "101010";    -- slt
        wait for c_TIME_DELTA;
        assert o_aluControl = "111" report "mismatch" severity error;

        wait;
    end process;

end architecture bench;
