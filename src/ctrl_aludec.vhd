-- Multicycle MIPS / Control Unit / ALU Decoder
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity ctrl_aludec is
    port( 
        i_funct     : in  std_logic_vector(5 downto 0);
        i_aluOp     : in  std_logic_vector(1 downto 0);
        o_aluControl: out std_logic_vector(2 downto 0)
    );
end ctrl_aludec;

architecture rtl of ctrl_aludec is
begin
    process(i_funct, i_aluOp) begin
        if i_aluOp = "00" then      -- add
            o_aluControl <= "010";

        elsif i_aluOp = "01" then   -- sub
            o_aluControl <= "110";

        elsif i_aluOp = "10" then   -- check i_funct
            case i_funct is
                when "100000" => o_aluControl <= "010";     -- add
                when "100010" => o_aluControl <= "110";     -- sub
                when "100100" => o_aluControl <= "000";     -- and
                when "100101" => o_aluControl <= "001";     -- or
                when "101010" => o_aluControl <= "111";     -- slt
                when others   => o_aluControl <= "---";
            end case;

        else
            o_aluControl <= "---";
        end if;
    end process;
end;
