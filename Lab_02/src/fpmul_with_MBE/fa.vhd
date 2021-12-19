library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;   
USE ieee.std_logic_arith.all;

entity fa is  
    port (
    in1, in2: in std_logic;
    c_in: in std_logic;
    c_out: out std_logic;
    sum: out std_logic);
end entity;

architecture behavioral of fa is
begin
    sum <= in1 XOR in2 XOR c_in;
    c_out <= (in1 AND in2) OR (C_in AND (in1 XOR in2 ));
end architecture;