library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity add_sub is
    generic(N_bit : integer := 14);
    port(   in1, in2 : in signed(N_bit-1 downto 0);
            clk, add_subN : in std_logic;
            result : out signed(N_bit downto 0));
end add_sub;

architecture behavioral of add_sub is
begin
-- result <=   in1 - in2 when add_subN='0' else
--                         in1 + in2;
    result <=   (in1(N_bit-1) & in1) - (in2(N_bit-1) & in2) when add_subN='0' else
                (in1(N_bit-1) & in1) + (in2(N_bit-1) & in2);
end architecture;