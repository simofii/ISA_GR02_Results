-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: ALU             * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    generic( N_bit_data : integer := 8;
             N_bit_mode : integer := 2);
    port (
        in1, in2 : in signed(N_bit_data-1 downto 0);
        mode : in std_logic_vector(N_bit_mode-1 downto 0)  := std_logic_vector(to_unsigned(0,N_bit_mode));
        result : out signed(N_bit_data-1 downto 0);
        zero : out std_logic);
end entity;

architecture behavior of alu is

    component adder is
        generic (
            N_bit : integer := 32);
        port (
            in1, in2 : in signed (N_bit-1 downto 0);
            c_in : in std_logic;
            result : out signed(N_bit-1 downto 0);
            c_out : out std_logic);
    end component;

    component shifter is
        generic( N_bit_data : integer := 32;
                 N_bit_shift : integer := 4);
        port(
            shift_qty : in std_logic_vector(N_bit_shift-1 downto 0);
            in1 : in signed(N_bit_data-1 downto 0);
            result : out signed(N_bit_data-1 downto 0));
    end component;

--and -> 000, add -> 001, sub -> 011, xor -> 100, shift -> 101

    constant add_code : integer := 1;          
    constant shift_code : integer := 5;
    constant and_code : integer := 0;
    constant sub_code : integer := 3;
    constant xor_code : integer := 4;

    constant shift_qty_bits : integer := 5;
    constant offest_shift_qty : integer := 0;

    signal adder_result, shifter_result, alu_result : signed(N_bit_data-1 downto 0);
    signal addN_sub : std_logic;
    signal mask : signed(N_bit_data-1 downto 0);

    signal in2_xor_mask : signed(N_bit_data-1 downto 0);

begin

    mask <= (others => addN_sub);
    
    alu_proc: process(in1, in2, mode, adder_result, shifter_result)
    begin
        addN_sub <= '0';
        if mode = std_logic_vector(to_unsigned(add_code, N_bit_mode)) then 
            alu_result <= adder_result;
        elsif mode = std_logic_vector(to_unsigned(shift_code, N_bit_mode)) then
            alu_result <= shifter_result;
        elsif mode = std_logic_vector(to_unsigned(and_code, N_bit_mode)) then
            alu_result <= in1 and in2;
        elsif mode = std_logic_vector(to_unsigned(xor_code, N_bit_mode)) then
            alu_result <= in1 xor in2;
        elsif mode = std_logic_vector(to_unsigned(sub_code, N_bit_mode)) then 
            addN_sub <= '1';
            alu_result <= adder_result;
        else
            alu_result <= adder_result;
        end if;
    end process;

    in2_xor_mask <= in2 xor mask;

    adder_component: adder generic map(N_bit => N_bit_data)
        port map( in1 => in1, in2 => in2_xor_mask, c_in => addN_sub, c_out => open, result => adder_result);

    shifter_component : shifter generic map(N_bit_data => N_bit_data, N_bit_shift => shift_qty_bits)
        port map( in1 => in1, shift_qty => std_logic_vector(in2(shift_qty_bits-1+offest_shift_qty downto offest_shift_qty)), result => shifter_result);    

    zero <= '1' when (alu_result = to_signed(0, N_bit_data)) else '0';
	 result <= alu_result;

end architecture behavior;