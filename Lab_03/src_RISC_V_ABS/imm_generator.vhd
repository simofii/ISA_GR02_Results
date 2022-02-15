-- *************************************** --
-- * Integrated Systems Architecture     * --
-- * Lab 03: RISC-V                      * --  
-- * DESIGN ELEMENT: Immediate Generator * --   
-- * Authors:                            * --
-- *  FIORAVANTI Simone S292612          * --
-- *  MOLINA Ottavio    S292527          * --
-- *  OTTINO Lorenzo    S281571          * --
-- *************************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity imm_generator is
    generic(N_bit : integer := 32);
    port( instr : in std_logic_vector(N_bit-1 downto 0);
        func3: in std_logic_vector(2 downto 0);
        immediate : out std_logic_vector(N_bit-1 downto 0));
end entity;

architecture behavior of imm_generator is

    constant opcode_ADD_XOR_SLT : std_logic_vector(6 downto 0) := "0110011";
    constant opcode_ADDI_SRAI_ANDI : std_logic_vector(6 downto 0) := "0010011";
    constant opcode_AUIPC : std_logic_vector(6 downto 0) := "0010111";
    constant opcode_LUI : std_logic_vector(6 downto 0) := "0110111";
    constant opcode_BEQ : std_logic_vector(6 downto 0) := "1100011";
    constant opcode_LW : std_logic_vector(6 downto 0) := "0000011";
    constant opcode_JAL : std_logic_vector(6 downto 0) := "1101111";
    constant opcode_SW : std_logic_vector(6 downto 0) := "0100011";

begin

    imm_process : process(instr)

        variable opcode : std_logic_vector(6 downto 0);
        variable imm : std_logic_vector(31 downto 0);
        variable extension_20 : std_logic_vector(19 downto 0);
        constant extension_27 : std_logic_vector(26 downto 0) := (others => '0');
        
    begin
	 
	    if instr(31) = '0' then
            extension_20 := (others => '0');
        else
            extension_20 := (others => '1');
        end if;


        opcode := instr(6 downto 0);

        if opcode = opcode_ADD_XOR_SLT then
            imm := extension_20 & instr(31 downto 20);

        elsif opcode = opcode_ADDI_SRAI_ANDI then
            if func3 = "101" then 
                imm := extension_27 & instr(24 downto 20);
            else
                imm := extension_20 & instr(31 downto 20); 
            end if;         
        elsif opcode = opcode_AUIPC then
            imm := instr(31 downto 12) & "000000000000";
        elsif opcode = opcode_LUI then
            imm := instr(31 downto 12) & "000000000000";
        elsif opcode = opcode_BEQ then
            imm := extension_20(18 downto 0) & instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
        elsif opcode = opcode_LW then
            imm := extension_20 & instr(31 downto 20);            
        elsif opcode = opcode_JAL then
            imm := extension_20(10 downto 0) & instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
        elsif opcode = opcode_SW then
            imm := extension_20 & instr(31 downto 25) & instr(11 downto 7);
        else
            imm := extension_20 & instr(31 downto 20);
        end if;

        immediate <= imm;

    end process;
    
    
end architecture behavior;