-- MIPS processor integrated with DE0 peripherals
--
-- Author: Gutierrez PS / https://github.com/gutierrezps/mips-on-quartus-ii

library ieee;
use ieee.std_logic_1164.all;

entity de0_mips is
    port (
        i_clk   : in  std_logic;
        i_rst   : in  std_logic;
        o_hex0  : out std_logic_vector(0 to 6);
        o_hex2  : out std_logic_vector(0 to 6);
        o_hex3  : out std_logic_vector(0 to 6);
        o_clk   : out std_logic
    );
end de0_mips;

architecture struct of de0_mips is
    component mips2
        port (
            i_clk       : in  std_logic;
            i_rst       : in  std_logic;
            o_data0     : out std_logic_vector(31 downto 0);
            o_data1     : out std_logic_vector(31 downto 0);
            o_ctrlState : out std_logic_vector( 3 downto 0)
        );
    end component;
    
    component clock_divider
        generic ( g_FACTOR : integer := 50000000 );
        port (
            i_clk   : in  std_logic;
            o_clk   : out std_logic
        );
    end component;

    component bcd2hex
        port(
            i_bcd: in  std_logic_vector (3 downto 0);
            o_hex: out std_logic_vector (0 to 6)
        );
    end component;

    component byte2bcd
        port (
            i_byte  : in  std_logic_vector (7 downto 0);
            o_bcd   : out std_logic_vector (7 downto 0)
        );
    end component;

    signal w_clkDiv : std_logic;
    signal w_data0  : std_logic_vector(31 downto 0);
    signal w_state  : std_logic_vector(3 downto 0);
    signal w_data0bcd : std_logic_vector(3 downto 0);
    signal w_stateBcd : std_logic_vector(7 downto 0);
    
begin

    clkDiv: clock_divider port map (
        i_clk   => i_clk,
        o_clk   => w_clkDiv
    );

    o_clk <= w_clkDiv;

    mips: mips2 port map (
        i_clk       => w_clkDiv,
        i_rst       => not i_rst,
        o_data0     => w_data0,
        o_ctrlState => w_state
    );

    data0toBcd: byte2bcd port map (
        i_byte  => w_data0(7 downto 0),
        o_bcd(3 downto 0)   => w_data0Bcd
    );

    stateTobcd: byte2bcd port map (
        i_byte  => "0000" & w_state(3 downto 0),
        o_bcd   => w_stateBcd
    );

    data0toHex: bcd2hex port map (
        i_bcd   => w_data0Bcd,
        o_hex   => o_hex0
    );

    stateTensToHex: bcd2hex port map (
        i_bcd   => w_stateBcd(7 downto 4),
        o_hex   => o_hex3
    );

    stateUnitsToHex: bcd2hex port map (
        i_bcd   => w_stateBcd(3 downto 0),
        o_hex   => o_hex2
    );

end struct;
