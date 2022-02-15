-- ************************************************ --
-- * Integrated Systems Architecture              * --
-- * Lab 03: RISC-V                               * --  
-- * DESIGN ELEMENT: Multiplexer 5 to 1 on N bits * --   
-- * Authors:                                     * --
-- *  FIORAVANTI Simone S292612                   * --
-- *  MOLINA Ottavio    S292527                   * --
-- *  OTTINO Lorenzo    S281571                   * --
-- ************************************************ --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux_5to1 is
    generic ( 
        N_bit : integer := 32);
    port (sel : in std_logic_vector(2 downto 0);
        in0, in1, in2, in3, in4 : in std_logic_vector(N_bit-1 downto 0);
        sig_out : out std_logic_vector(N_bit-1 downto 0));
end entity mux_5to1;

architecture behavior of mux_5to1 is
    
begin
    process(sel, in0, in1, in2, in3, in4) 
	 begin
		 case sel is
			  when "000" =>
					sig_out <= in0;
			  when "001" =>
					sig_out <= in1;
			  when "010" =>
					sig_out <= in2;
			  when "011" =>
					sig_out <= in3;
			  when "100" =>
					sig_out <= in4;
			  when others =>
					sig_out <= in0;
		 end case;
	end process;
end architecture behavior;