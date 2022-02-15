-- ************************************************ --
-- * Integrated Systems Architecture              * --
-- * Lab 03: RISC-V                               * --  
-- * DESIGN ELEMENT: Multiplexer 2 to 1 on N bits * --   
-- * Authors:                                     * --
-- *  FIORAVANTI Simone S292612                   * --
-- *  MOLINA Ottavio    S292527                   * --
-- *  OTTINO Lorenzo    S281571                   * --
-- ************************************************ --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux_2to1 is
    generic (N_bit : integer := 32);
    port (sel : in std_logic;
        in0, in1 : in std_logic_vector(N_bit-1 downto 0);
        sig_out : out std_logic_vector(N_bit-1 downto 0));
end entity mux_2to1;

architecture behavior of mux_2to1 is
    
begin
    
    process(sel, in0, in1)
    begin
        case sel is
            when '0' =>
                sig_out <= in0;
            when '1' =>
                sig_out <= in1;
            when others =>
                sig_out <= in0;
        end case;
    end process;    
end architecture behavior;