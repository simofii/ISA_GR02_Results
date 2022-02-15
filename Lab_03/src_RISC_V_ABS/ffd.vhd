-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: Register N bits * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ffd is
    generic(N_bit : integer := 1);
    port(
        data_in : in std_logic_vector(N_bit-1 downto 0);
        data_out : out std_logic_vector (N_bit-1 downto 0);
        clk, rst, cs: in std_logic);
end ffd;


architecture behavior of ffd is
begin
    process(rst, clk)
    begin
        if rst='0' then
            data_out <= (others => '0');
        elsif clk'event and clk = '1' then
            if cs = '1' then         
                data_out <= data_in;
            end if;
        end if;
    end process;
end architecture;