-- Multicycle MIPS / Control Unit / Finite State Machine
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii
--
-- Based on Intel's Mealy State Machine template
-- https://www.intel.com/content/www/us/en/programmable/support/support-resources/design-examples/design-software/vhdl/vhd-state-machine.html

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ctrl_fsm is
    port (
        i_clk       : in std_logic;
        i_rst       : in std_logic;
        i_opcode    : in std_logic_vector(5 downto 0);
        o_iOrD      : out std_logic;
        o_irWrite   : out std_logic;
        o_regDst    : out std_logic;
        o_memToReg  : out std_logic;
        o_regWrite  : out std_logic;
        o_aluSrcA   : out std_logic;
        o_aluSrcB   : out std_logic_vector(1 downto 0);
        o_aluOp     : out std_logic_vector(1 downto 0);
        o_pcSrc     : out std_logic_vector(1 downto 0);
        o_pcWrite   : out std_logic;
        o_branch    : out std_logic;
        o_memWrite  : out std_logic;
        o_state     : out std_logic_vector(3 downto 0)
    );
end ctrl_fsm;

architecture rtl of ctrl_fsm is
    -- Build an enumerated type for the state machine
    type t_stateType is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11);
    
    signal r_state: t_stateType;
    
begin
    states: process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            r_state <= s0;

        elsif rising_edge(i_clk) then
        
            case r_state is
                when s0 => r_state <= s1;

                when s1 =>
                    if i_opcode = 35 or i_opcode = 43 then    -- load or store word (lw or sw)
                        r_state <= s2;
                    elsif i_opcode = 0 then     -- r-type (add, sub)
                        r_state <= s6;
                    elsif i_opcode = 4 then     -- branch if equal (beq)
                        r_state <= s8;
                    elsif i_opcode = 8 then     -- addi
                        r_state <= s9;
                    elsif i_opcode = 2 then     -- jump (j)
                        r_state <= s11;
                    else                        -- unknown instruction
                        r_state <= s0;
                    end if;
                
                when s2 =>
                    if i_opcode = 35 then       -- lw
                        r_state <= s3;
                    elsif i_opcode = 43 then    -- sw
                        r_state <= s5;
                    end if;
                
                when s3 => r_state <= s4;
                when s4 => r_state <= s0;
                when s5 => r_state <= s0;
                when s6 => r_state <= s7;
                when s7 => r_state <= s0;
                when s8 => r_state <= s0;
                when s9 => r_state <= s10;
                when s10 => r_state <= s0;
                when s11 => r_state <= s0;
            
            end case;   -- case r_state
        end if;     -- if rising_edge(i_clk)
    end process states;

    outputs: process (r_state)
    begin
        case r_state is
            when s0 =>
                o_iOrD      <= '0';
                o_aluSrcA   <= '0';
                o_aluSrcB   <= "01";
                o_aluOp     <= "00";
                o_pcSrc     <= "00";
                o_irWrite   <= '1';
                o_pcWrite   <= '1';
                o_regWrite  <= '0';
                o_memWrite  <= '0';
                o_branch    <= '0';

            when s1 =>
                o_pcWrite   <= '0';
                o_irWrite   <= '0';
                o_aluSrcA   <= '0';
                o_aluSrcB   <= "11";
                o_aluOp     <= "00";

            when s2 =>
                o_aluSrcA   <= '1';
                o_aluSrcB   <= "10";
                o_aluOp     <= "00";

            when s3 =>
                o_iOrD      <= '1';
                
            when s4 =>
                o_regDst    <= '0';
                o_memToReg  <= '1';
                o_regWrite  <= '1';
                
            when s5 =>
                o_iOrD      <= '1';
                o_memWrite  <= '1';

            when s6 =>
                o_aluSrcA   <= '1';
                o_aluSrcB   <= "00";
                o_aluOp     <= "10";

            when s7 =>
                o_regDst    <= '1';
                o_memToReg  <= '0';
                o_regWrite  <= '1';

            when s8 =>
                o_aluSrcA   <= '1';
                o_aluSrcB   <= "10";
                o_aluOp     <= "01";
                o_pcSrc     <= "01";
                o_branch    <= '1';

            when s9 =>
                o_aluSrcA   <= '1';
                o_aluSrcB   <= "10";
                o_aluOp     <= "00";

            when s10 =>
                o_regDst    <= '0';
                o_memToReg  <= '0';
                o_regWrite  <= '1';

            when s11 =>
                o_pcSrc     <= "10";
                o_pcWrite   <= '1';
        end case;
    end process outputs;

    -- enum to std_logic_vector conversion
    -- source: https://stackoverflow.com/a/42255676/2014507
    o_state <= std_logic_vector(to_unsigned(t_stateType'POS(r_state), o_state'length));
end rtl;
