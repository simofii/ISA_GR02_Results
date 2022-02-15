-- **************************************** --
-- * Integrated Systems Architecture      * --
-- * Lab 03: RISC-V                       * --  
-- * EXTERNAL DESIGN ELEMENT: Data Memory * --   
-- * Authors:                             * --
-- *  FIORAVANTI Simone S292612           * --
-- *  MOLINA Ottavio    S292527           * --
-- *  OTTINO Lorenzo    S281571           * --
-- **************************************** --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is
	generic (Nbit : integer := 32;
			 ROWS : integer := 16);
	port (clk, rst : in std_logic;
		  addr: in std_logic_vector(Nbit-1 downto 0);
		  d_in : in signed(Nbit-1 downto 0);
		  wr : in std_logic;
		  d_out : out signed(Nbit-1 downto 0) );
end entity data_mem;

architecture behavioral of data_mem is

	type t_mem is array ((2**ROWS)-1 downto 0) of signed(Nbit-1 downto 0);
	signal s_val : t_mem;  

begin
	
	proc_read: process(addr, s_val)
	begin
		d_out <= s_val(to_integer(unsigned(addr(15 downto 0))));
	end process proc_read;

	proc_wr : process(clk)
	begin
		--memory inizialization
		if rst ='0'then
			s_val(8192) <= X"0000000a";
			s_val(8196) <= X"ffffffd1";
			s_val(8200) <= X"00000016";
			s_val(8204) <= X"fffffffd";
			s_val(8208) <= X"0000000f";
			s_val(8212) <= X"0000001b";
			s_val(8216) <= X"fffffffc";
		elsif clk = '1' and clk'event then
			if wr = '1'  then --write the value in the addr position
				s_val(to_integer(unsigned(addr(15 downto 0)))) <= d_in;
			end if;
		end if;
	end process;

			



end architecture behavioral;