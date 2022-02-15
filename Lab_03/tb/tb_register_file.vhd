-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * TESTBENCH Register File         * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_register_file is
end entity tb_register_file;

architecture behavior of tb_register_file is
    
    component register_file is
        generic ( 
            N_bit_addr : integer := 32;
            N_bit_data : integer := 32);
        port (
            addr_read1, addr_read2, addr_wr : in std_logic_vector(N_bit_addr-1 downto 0);
            data_wr : in std_logic_vector(N_bit_data-1 downto 0);
            clk, rst, en_write : in std_logic;
            data_read1, data_read2 : out std_logic_vector(N_bit_data-1 downto 0));
    end component;

    signal clk, en_wr, rst : std_logic;
    constant PERIOD : time := 1us;

    signal data_in, data_read1, data_read2: std_logic_vector(7 downto 0);
    signal addr_wr, addr_read1, addr_read2 : std_logic_vector(4 downto 0);

begin
    
    clk_proc: process
    begin
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process;

    rst <= '0', '1' after 1.3us;
    en_wr <= '0', '1' after 2.3us;

    addr_wr <= "00000";
    addr_read1 <= "00000";
    addr_read2 <= "00000", "00100" after 2.8us;

    data_in <= std_logic_vector(to_unsigned(1, 8)), std_logic_vector(to_unsigned(15, 8)) after 3.3us;

    dut: register_file generic map(
                            N_bit_addr => 5,
                            N_bit_data => 8)
                        port map(
                            addr_read1 => addr_read1, addr_read2 => addr_read2, addr_wr => addr_wr, data_wr => data_in,
                            clk => clk, rst => rst, en_write => en_wr, data_read1 => data_read1, data_read2 => data_read2);    
    
end architecture behavior;