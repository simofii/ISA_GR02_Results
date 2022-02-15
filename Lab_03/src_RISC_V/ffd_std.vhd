-- ************************************ --
-- * Integrated Systems Architecture  * --
-- * Lab 03: RISC-V                   * --  
-- * DESIGN ELEMENT: Flip-Flop type D * --   
-- * Authors:                         * --
-- *  FIORAVANTI Simone S292612       * --
-- *  MOLINA Ottavio    S292527       * --
-- *  OTTINO Lorenzo    S281571       * --
-- ************************************ --

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ffd_std is
    port(
        data_in : in std_logic;
        data_out : out std_logic;
        clk, rst, cs: in std_logic);
end ffd_std;


architecture behavior of ffd_std is
begin
    process(rst, clk)
    begin
        if rst='0' then
            data_out <= '0';
        elsif clk'event and clk = '1' then
            if cs = '1' then         
                data_out <= data_in;
            end if;
        end if;
    end process;
end architecture;