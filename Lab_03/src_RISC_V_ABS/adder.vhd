-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: Adder N bits    * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is
    generic (N_bit : integer := 32);
    port (
        in1, in2 : in signed (N_bit-1 downto 0);
        c_in : in std_logic;
        result : out signed(N_bit-1 downto 0);
        c_out : out std_logic);
end entity;

architecture behavior of adder is

begin
    
    adder_pror: process(in1, in2, c_in)
        variable res_temp : integer;
		  variable carry : integer;
    begin
        res_temp := to_integer(in1) + to_integer(in2) + to_integer(unsigned'('0' & c_in));
        c_out <= to_signed(res_temp, N_bit+1)(N_bit);
        result <= to_signed(res_temp, N_bit)(N_bit-1 downto 0);

    end process;
    
    
end architecture;  