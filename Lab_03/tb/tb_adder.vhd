-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * TESTBENCH Adder                 * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_adder is
end entity tb_adder;

architecture behavior of tb_adder is

    component adder is
        generic (
            N_bit : integer := 32);
        port (
            in1, in2 : in signed (N_bit-1 downto 0);
            c_in : in std_logic;
            result : out signed(N_bit-1 downto 0);
            c_out : out std_logic);
    end component;

    signal in1, in2, result : signed(7 downto 0);
    signal c_in, c_out : std_logic;

begin

    in1 <= "00000000", "11111111" after 1.3 us;
    in2 <= "00000000", "11111111" after 1.3 us;
    c_in <= '0', '1' after 0.5 us, '0' after 1us, '1' after 1.5 us;
        
    dut: adder generic map(N_bit => 8)
                port map(in1 => in1, in2 => in2, result => result, c_in => c_in, c_out => c_out);
        
end architecture behavior;