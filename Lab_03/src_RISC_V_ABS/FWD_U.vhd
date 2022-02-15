-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: Forwarding Unit * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FWD_U is
    generic(N_bit : integer:=5;
            N_bit_sel: integer := 2);
    port(r1, r2, rd_WB, rd_OS: in std_logic_vector(N_bit -1 downto 0);
         opcode: in std_logic_vector(6 downto 0);
         func3: in std_logic_vector(2 downto 0);
         reg_wr_OS, reg_wr_WB, clk, rst: in std_logic;
         sel_frw_imm:out std_logic_vector(2 downto 0);
         sel_fwd, sel_r1: out std_logic_vector(N_bit_sel-1 downto 0));
end entity;

architecture behavioral of FWD_U is
    
    constant opcode_ADD_XOR_SLT : std_logic_vector(6 downto 0) := "0110011";
    constant opcode_ADDI_SRAI_ANDI : std_logic_vector(6 downto 0) := "0010011";
    constant opcode_AUIPC : std_logic_vector(6 downto 0) := "0010111";
    constant opcode_LUI : std_logic_vector(6 downto 0) := "0110111";
    constant opcode_BEQ : std_logic_vector(6 downto 0) := "1100011";
    constant opcode_LW : std_logic_vector(6 downto 0) := "0000011";
    constant opcode_JAL : std_logic_vector(6 downto 0) := "1101111";
    constant opcode_SW : std_logic_vector(6 downto 0) := "0100011";
    constant opcode_ABS : std_logic_vector(6 downto 0) := "1100010";
    
    signal state_menus_1, state_menus_2, curr_state : std_logic_vector (6 downto 0);
    signal func, func_menus_1: std_logic_vector(2 downto 0);
begin

   prev_state: process(clk)
   begin
    if clk'event and clk ='1' and rst ='1' then
    state_menus_2 <= state_menus_1;
    state_menus_1 <= curr_state;
    curr_state <= opcode;
    func <= func3;
    func_menus_1 <= func;
    end if;
   end process prev_state;


forwarding_process: process(r1, r2, rd_WB, rd_OS, reg_wr_OS, reg_wr_WB)

begin
    sel_r1 <= "00";
    sel_fwd <= "00";
	 sel_frw_imm <= "000";

    if ((reg_wr_OS = '1') OR (reg_wr_WB = '1')) and ((rd_OS /= "00000") OR (rd_WB /= "00000"))then

        --if statement to discriminate if the instruction has an immediate in the reg2 position
        if (curr_state /= opcode_SW AND state_menus_2 /= opcode_SW AND state_menus_1 /= opcode_SW) OR (curr_state = opcode_SW AND state_menus_1 /= opcode_SW  AND state_menus_2 /= opcode_SW) then

            --if statement to control mux before input 1 of the alu    
            if r1 = rd_OS then
                sel_r1 <= "01";
            elsif r1 = rd_WB then
                sel_r1 <= "10";
            else
                sel_r1 <="00";
            end if;

            --if statement to control mux before input 2 of the alu
            if r2 = rd_OS then
                sel_fwd <= "01";
            elsif r2 = rd_WB then
                sel_fwd <= "10";
            else
                sel_fwd <= "00";
            end if;

            --if statement to control mux in stage 4
            if state_menus_1 = opcode_LUI OR state_menus_1 = opcode_AUIPC then
                sel_frw_imm <= "001";
            elsif state_menus_1 = opcode_JAL then
                sel_frw_imm <= "010";
            elsif state_menus_1 = opcode_LW then 
                sel_frw_imm <= "011";
            elsif state_menus_1 = opcode_ADD_XOR_SLT and func_menus_1 = "010" then
                sel_frw_imm <= "100";
            else 
                sel_frw_imm <= "000";
            end if;

        elsif (curr_state = opcode_SW AND state_menus_1 = opcode_SW  AND state_menus_2 /= opcode_SW) OR (curr_state /= opcode_SW AND state_menus_1 = opcode_SW  AND state_menus_2 /= opcode_SW) then

            --if statement to control mux before input 1 of the alu
            if r1 = rd_OS then
                sel_r1 <= "00";
            elsif r1 = rd_WB then
                sel_r1 <= "10";
            else
                sel_r1 <="00";
            end if;

            --if statement to control mux before input 2 of the alu
            if r2 = rd_OS then
                sel_fwd <= "00";
            elsif r2 = rd_WB then
                sel_fwd <= "10";
            else
                sel_fwd <= "00";
            end if;

            --if statement to control mux in stage 4
            if state_menus_1 = opcode_LUI OR state_menus_1 = opcode_AUIPC then 
                sel_frw_imm <= "001";
            elsif state_menus_1 = opcode_JAL then
                sel_frw_imm <= "010";
            elsif state_menus_1 = opcode_LW then 
                sel_frw_imm <= "011";
            elsif state_menus_1 = opcode_ADD_XOR_SLT and func_menus_1 = "010" then
                sel_frw_imm <= "100";
            else 
                sel_frw_imm <= "000";
            end if;

        elsif (curr_state = opcode_SW AND state_menus_1 = opcode_SW  AND state_menus_2 = opcode_SW) OR (curr_state /= opcode_SW AND state_menus_1 = opcode_SW  AND state_menus_2 = opcode_SW) then

            sel_r1 <= "00";
            sel_fwd <= "00";

            --if statement to control mux in stage 4
            if state_menus_1 = opcode_LUI OR state_menus_1 = opcode_AUIPC then
                sel_frw_imm <= "001";
            elsif state_menus_1 = opcode_JAL then
                sel_frw_imm <= "010";
            elsif state_menus_1 = opcode_LW then 
                sel_frw_imm <= "011";
            elsif state_menus_1 = opcode_ADD_XOR_SLT and func_menus_1 = "010" then
                sel_frw_imm <= "100";
            else 
                sel_frw_imm <= "000";
            end if;

        else

            sel_r1 <= "00";
            sel_fwd <= "00";

            --if statement to control mux in stage 4
            if state_menus_1 = opcode_LUI OR state_menus_1 = opcode_AUIPC then
                sel_frw_imm <= "001";
            elsif state_menus_1 = opcode_JAL then
                sel_frw_imm <= "010";
            elsif state_menus_1 = opcode_LW then 
                sel_frw_imm <= "011";
            elsif state_menus_1 = opcode_ADD_XOR_SLT and func_menus_1 = "010" then
                sel_frw_imm <= "100";
            else 
                sel_frw_imm <= "000";
            end if;
        end if;
    end if;
    
end process;

end architecture;
