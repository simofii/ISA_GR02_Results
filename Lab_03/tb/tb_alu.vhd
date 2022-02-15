-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * TESTBENCH ALU                   * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_alu is
end entity tb_alu;

architecture behavior of tb_alu is

    component alu is
        generic( N_bit_data : integer := 8;
                 N_bit_mode : integer := 2);
        port (
            in1, in2 : in signed(N_bit_data-1 downto 0);
            mode : in std_logic_vector(N_bit_mode-1 downto 0);
            result : out signed(N_bit_data-1 downto 0);
            zero : out std_logic);
    end component;

    signal in1, in2, result : signed(7 downto 0) ;
    signal mode : std_logic_vector(2 downto 0);
    signal zero : std_logic;

begin

    in1 <= "00000111", "11001100" after 1us;
    in2 <= "00000000", "11000111" after 2us;
    mode <= "001", "001" after 2.5us, "010" after 3us, "011" after 4us;
    
    dut : alu generic map (N_bit_data => 8, N_bit_mode => 3)
        port map (in1 => in1, in2 => in2, result => result, mode => mode, zero => zero);

end architecture;