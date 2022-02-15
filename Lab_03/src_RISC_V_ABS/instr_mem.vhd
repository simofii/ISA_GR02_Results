-- *********************************************** --
-- * Integrated Systems Architecture             * --
-- * Lab 03: RISC-V                              * --  
-- * EXTERNAL DESIGN ELEMENT: Instruction Memory * --   
-- * Authors:                                    * --
-- *  FIORAVANTI Simone S292612                  * --
-- *  MOLINA Ottavio    S292527                  * --
-- *  OTTINO Lorenzo    S281571                  * --
-- *********************************************** --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
	generic (Nbit: integer := 32;
			 ROWS: integer := 16 );
	port (addr: in std_logic_vector(Nbit-1 downto 0);
		  instr: out std_logic_vector(Nbit-1 downto 0) );
end entity instr_mem;

architecture behavioral of instr_mem is

	type t_mem is array ((2**ROWS)-1 downto 0) of std_logic_vector(Nbit-1 downto 0);
	signal s_instr : t_mem;

begin
	
	--fill memory	
	--set of instructions for ABS solution
	s_instr(0) <= X"00700813"; -- addi x16, x0, 0x00000007
	s_instr(4) <= X"00002217"; -- auipc x4, 0x00000002
	s_instr(8) <= X"ffc20213"; -- addi x4, x4, 0xfffffffc
	s_instr(12) <= X"00002297"; -- auipc x5, 0x00000002
	s_instr(16) <= X"01028293"; -- addi x5, x5, 0x00000010
	s_instr(20) <= X"400006b7"; -- lui x13, 0x00040000
	s_instr(24) <= X"fff68693"; -- addi x13, x13, 0xffffffff
	s_instr(28) <= X"02080263"; -- beq x16, x0, 0x00000018
	s_instr(32) <= X"00022403"; -- lw x8, 0x00000000(x4)
	s_instr(36) <= X"00040562"; -- abs x10, x8
	s_instr(40) <= X"00420213"; -- addi x4, x4, 0x00000004
	s_instr(44) <= X"fff80813"; -- slt x11, x10, x13
	s_instr(48) <= X"00d525b3"; -- addi x16, x16, 0xffffffff
	s_instr(52) <= X"fe0584e3"; -- beq x11, x0, 0xfffffff4
	s_instr(56) <= X"000506b3"; -- add x13, x10, x0
	s_instr(60) <= X"fe1ff0ef"; -- jal x1, 0xfffffff0
	s_instr(64) <= X"00d2a023"; -- sw x13, 0x00000000(x5)
	s_instr(68) <= X"000000ef"; -- jal x1, 0x00000000
	s_instr(72) <= X"00000013"; --addi x0, x0, 0x00000000
	proc_fetch: process(addr, s_instr)
	begin
		instr <= s_instr(to_integer(unsigned(addr(15 downto 0))));
	end process proc_fetch;

end architecture behavioral;