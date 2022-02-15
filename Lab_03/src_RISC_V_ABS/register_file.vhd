-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: Register File   * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity register_file is
    generic ( 
        N_bit_addr : integer := 32;
        N_bit_data : integer := 32);
    port (
        addr_read1, addr_read2, addr_wr : in std_logic_vector(N_bit_addr-1 downto 0);
        data_wr : in std_logic_vector(N_bit_data-1 downto 0);
        clk, rst, en_write : in std_logic;
        data_read1, data_read2 : out std_logic_vector(N_bit_data-1 downto 0));
end entity;


architecture behavior of register_file is
    type mem_type is array ((2**N_bit_addr)-1 downto 0) of std_logic_vector(N_bit_data-1 downto 0);
    signal data : mem_type;
begin

    rf_process: process(clk, rst)

    begin
        if rst = '0' then
            for i in 0 to (2**N_bit_addr)-1 loop
                data(i) <= (others => '0');
            end loop;
        elsif clk'event and clk = '1' then
        
            data_read1 <= data( to_integer( unsigned(addr_read1) ) );
            data_read2 <= data( to_integer( unsigned(addr_read2) ) );

            if en_write='1' then

                data( to_integer( unsigned(addr_wr) ) ) <= data_wr;
                if addr_read1 = addr_wr then
                    data_read1 <= data_wr;
                end if;
                if addr_read2 = addr_wr then
                    data_read2 <= data_wr;
                end if;
            end if;
        end if;
    end process;
    
end architecture behavior;