-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: Shifter         * --
-- * NOTES: Right-Shift of N bits    * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is
    generic( N_bit_data : integer := 32;
			 N_bit_shift : integer := 5);
    port(
        shift_qty : in std_logic_vector(N_bit_shift-1 downto 0);
        in1 : in signed(N_bit_data-1 downto 0);
        result : out signed(N_bit_data-1 downto 0));
end entity shifter;

architecture behavior of shifter is
    
begin
    
    result <= shift_right(in1, to_integer(unsigned(shift_qty)));
    
end architecture behavior;