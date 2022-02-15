-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: Abs Calculator  * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity abs_calculator is
    generic(N_bit : integer := 32);
    port (
        data_in : in std_logic_vector(N_bit-1 downto 0);
        abs_out : out std_logic_vector(N_bit-1 downto 0));
end entity abs_calculator;

architecture rtl of abs_calculator is
    
    signal swap_sign : std_logic_vector(N_bit-1 downto 0);
    signal mask :  std_logic_vector(N_bit-1 downto 0);
    signal not_data_in :  std_logic_vector(N_bit-1 downto 0);

    component adder is
        generic (N_bit : integer := 32);
        port (
            in1, in2 : in signed (N_bit-1 downto 0);
            c_in : in std_logic;
            result : out signed(N_bit-1 downto 0);
            c_out : out std_logic);
    end component;

begin
    
    abs_process : process(data_in, swap_sign)
    begin
 
        if data_in(N_bit-1) = '0' then
            abs_out <= data_in;
        else
            abs_out <= swap_sign;
        end if;
        
    end process;

    --creation of the mask to performe 2's complement if negative number
    mask <= (others => data_in(N_bit-1));
    not_data_in <= mask xor data_in;

    adder_comp : adder generic map(N_bit => 32)
        port map (in1 => to_signed(0, N_bit), in2 => signed(not_data_in), c_in => '1', c_out => open, std_logic_vector(result) => swap_sign);

    
    
end architecture rtl;