-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * TESTBENCH Shifter               * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_shifter is
end entity tb_shifter;

architecture behavior of tb_shifter is
    
    component shifter is
        generic( N_bit_data : integer := 32;
                 N_bit_shift : integer := 4);
        port(
            shift_qty : in std_logic_vector(N_bit_shift-1 downto 0);
            in1 : in signed(N_bit_data-1 downto 0);
            result : out signed(N_bit_data-1 downto 0));
    end component;

    signal in1, result : signed(7 downto 0);
    signal shift_qty : std_logic_vector(2 downto 0);

begin
    
    shift_qty <= "000", "010" after 1us, "111" after 3us, "001" after 3.7us;
    in1 <= "11110000", "11001100" after 1.5us, "00000010" after 3.5us;

    dut: shifter generic map (N_bit_data => 8, N_bit_shift => 3)
            port map( in1 => in1, result => result, shift_qty => shift_qty);
    
end architecture behavior;