-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * TESTBENCH top-level RISC-V      * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use WORK.package_tb_RISC_V.all;

entity tb_RISC_V is
end entity tb_RISC_V;

architecture behavioral of tb_RISC_V is

	component RISC_V is
		port (
        		instr_mem_addr : out std_logic_vector(31 downto 0);
        		instr_mem_read : in std_logic_vector(31 downto 0);
        		data_mem_addr : out std_logic_vector(31 downto 0);
        		data_mem_read : in std_logic_vector(31 downto 0);
        		data_mem_write : out std_logic_vector(31 downto 0);
        		data_mem_wr: out std_logic;
        		clk, rst : in std_logic );
	end component RISC_V;

	component instr_mem is
		generic ( 
			  Nbit: integer := 32;
			  ROWS: integer := 16);
		port (
		       addr: in std_logic_vector(Nbit-1 downto 0);
		       instr : out std_logic_vector(Nbit-1 downto 0) );
	end component instr_mem;

	component data_mem is
		generic ( 
		  	  Nbit : integer := 32;
		 	  ROWS : integer := 16 );
		port (
		       clk, rst: in std_logic;
		       addr: in std_logic_vector(Nbit-1 downto 0);
		       d_in: in signed(Nbit-1 downto 0);
		       wr: in std_logic;
		       d_out: out signed(Nbit-1 downto 0) );
	end component data_mem;

	signal s_instr_mem_addr : std_logic_vector(31 downto 0);
	signal s_instr_mem_read : std_logic_vector(31 downto 0);
	signal s_data_mem_addr  : std_logic_vector(31 downto 0);
	signal s_data_mem_read  : signed(31 downto 0);
	signal s_data_mem_write : std_logic_vector(31 downto 0);
	signal s_data_mem_wr : std_logic;
	signal s_clk : std_logic;
	signal s_rst : std_logic;

begin
	
	DUT: RISC_V
	port map ( instr_mem_addr => s_instr_mem_addr, 
		   instr_mem_read => s_instr_mem_read,
		   data_mem_addr => s_data_mem_addr,
		   data_mem_read => std_logic_vector(s_data_mem_read),
		   data_mem_write => s_data_mem_write,
		   data_mem_wr => s_data_mem_wr, 
		   clk => s_clk, rst => s_rst );
	
	DUT1: instr_mem
	generic map (Nbit => 32, ROWS => 16)
	port map (addr => s_instr_mem_addr, instr => s_instr_mem_read);

	DUT2: data_mem
	generic map (Nbit => 32, ROWS => 16)
	port map (clk => s_clk, rst => s_rst, addr => s_data_mem_addr, d_in => signed(s_data_mem_write), wr => s_data_mem_wr, d_out => s_data_mem_read);	

	proc_clk : process
	begin
		s_clk <= '0';
        	wait for PERIOD/2;
        	s_clk <= '1';
        	wait for PERIOD/2;	
	end process proc_clk;

	s_rst <= '0', '1' after 0.6*PERIOD;

end architecture behavioral;
	
