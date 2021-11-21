library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity molt is
    generic(N_bit : integer := 14);
    port(   in1, in2 : in signed(N_bit-1 downto 0);
            clk : in std_logic;
            result : out signed((N_bit*2)-1 downto 0));
end molt;

architecture behavioral of molt is

    signal res_temp: signed ((2*N_bit)-1 downto 0);

begin
    result <= in1 * in2;
end architecture;