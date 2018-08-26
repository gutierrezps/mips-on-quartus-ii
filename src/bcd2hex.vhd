-- Decodificador BCD para 7 segmentos (vetores)
-- Entrada: bcd (vetor de 4 posicoes);
-- Saida: hex (vetor de 7 posicoes)
-- Autores: Joao Vitor e Marcos Meira
-- Aluno: Gabriel Gutierrez
-- Data: 29 de julho de 2018

-- hex is (0 to 6) because the output order on the
-- process block is "abcdefg" i.e.
-- hex(0) -> a, hex(1) -> b, etc.
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity bcd2hex is
port(
    bcd: in  std_logic_vector (3 downto 0);
    hex: out std_logic_vector (0 to 6)
);
end bcd2hex;
 
architecture arquitetura of bcd2hex is
begin
    process(bcd)
    begin
        case bcd is
            when "0000" => hex <= NOT "1111110";
            when "0001" => hex <= NOT "0110000";
            when "0010" => hex <= NOT "1101101";
            when "0011" => hex <= NOT "1111001";
            when "0100" => hex <= NOT "0110011";
            when "0101" => hex <= NOT "1011011";
            when "0110" => hex <= NOT "1011111";
            when "0111" => hex <= NOT "1110000";
            when "1000" => hex <= NOT "1111111";
            when "1001" => hex <= NOT "1110011";
            when others => hex <= NOT "0000000";
        end case;
    end process;
end arquitetura;