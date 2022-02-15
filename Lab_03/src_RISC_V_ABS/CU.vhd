-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * DESIGN ELEMENT: Control Unit    * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CU is
    generic(N_bit: integer := 7);
    port(opcode: in std_logic_vector(N_bit-1 downto 0);
         func3: in std_logic_vector(2 downto 0);
         sel_reg_src, alu_cotrol: out std_logic_vector(2 downto 0);  --ALU: and -> 000, add -> 001, sub -> 011, xor -> 100, shift -> 101
         sel_cu, sel_pc_res, branch, reg_wr, mem_rd, mem_wr: out std_logic;
         en_pc, sel_mux_instr, jal_flag : out std_logic;    --added for blubble instructions
         sel_result : out std_logic;    --added for ABS
         clk, rst: in std_logic);
end entity;

architecture behavioral of CU is

    constant opcode_ADD_XOR_SLT : std_logic_vector(6 downto 0) := "0110011";
    constant opcode_ADDI_SRAI_ANDI : std_logic_vector(6 downto 0) := "0010011";
    constant opcode_AUIPC : std_logic_vector(6 downto 0) := "0010111";
    constant opcode_LUI : std_logic_vector(6 downto 0) := "0110111";
    constant opcode_BEQ : std_logic_vector(6 downto 0) := "1100011";
    constant opcode_LW : std_logic_vector(6 downto 0) := "0000011";
    constant opcode_JAL : std_logic_vector(6 downto 0) := "1101111";
    constant opcode_SW : std_logic_vector(6 downto 0) := "0100011";
    constant opcode_ABS : std_logic_vector(6 downto 0) := "1100010";
    
    --CU signal
    type state_type is (ADDD, ADDI, AUIPC, LUI, BEQ, LW, SRAI, ANDI, XORR, SLT, JAL, SW, IDLE, BUBBLE1, BUBBLE2, BUBBLE3, ABSS);
    signal current_state: state_type;

begin
    allocation_process: process(clk, rst)
        variable opcode_v: std_logic_vector(6 downto 0);
	 begin
        opcode_v := opcode;
        if rst ='0' then
            current_state <= IDLE;
        elsif clk'event and clk='1' then

            if current_state = JAL or current_state = BEQ then
                current_state <= BUBBLE1;
            elsif current_state = BUBBLE1 then
                current_state <= BUBBLE2;
            elsif current_state = BUBBLE2 then
                current_state <= BUBBLE3;
            else
                case opcode_v is
                    when opcode_ADD_XOR_SLT =>
                        if func3 = "000" then
                            current_state <= ADDD;
                        elsif func3 = "100" then
                            current_state <= XORR;
                        elsif func3 = "010" then
                            current_state <= SLT;
                        end if;

                    when opcode_ADDI_SRAI_ANDI =>
                        if func3 = "111" then
                            current_state <= ANDI;
                        elsif func3 = "101" then 
                            current_state <= SRAI;
                        elsif func3 = "000" then
                            current_state <= ADDI;
                        end if;

                    when opcode_AUIPC =>
                        current_state <= AUIPC;

                    when opcode_LUI =>
                        current_state <= LUI;

                    when opcode_BEQ =>

                        if func3 = "000" then
                            current_state <= BEQ;
                        end if;

                    when opcode_LW =>

                        if func3 = "010" then
                            current_state <= LW;
                        end if;
                    when opcode_JAL =>
                        current_state <= JAL;

                    when opcode_ABS => 
                        current_state <= ABSS;

                    when opcode_SW =>

                        if func3 = "010" then
                            current_state <= SW;
                        end if;

                    when others =>
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;


    output_process: process(current_state)
		begin
        case current_state is

            when ADDD =>
                sel_cu <= '1';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "001";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';
                
            when ADDI =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                alu_cotrol <= "001";
                mem_wr <= '0';
                branch <= '0';
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when AUIPC =>
                sel_cu <= '1';
                sel_pc_res <= '1';
                reg_wr <= '1';
                sel_reg_src <= "011";                    
                mem_rd <= '0';
                alu_cotrol <= "000";
                mem_wr <= '0';
                branch <= '0';
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when LUI =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "011";                    
                mem_rd <= '0';
                mem_wr <= '0';
                alu_cotrol <= "000";
                branch <= '0';
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when BEQ =>
                sel_cu <= '1';
                sel_pc_res <= '1';
                reg_wr <= '0';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "100";
                jal_flag <= '0';
                sel_mux_instr <= '1';
                en_pc <= '0';
                sel_result <= '0';

            when LW =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "001";                      
                mem_rd <= '1';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "001";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when SRAI =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "101";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when ANDI =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "000";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when XORR =>
                sel_cu <= '1';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "100";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when SLT =>
                sel_cu <= '1';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "010";                    
                mem_rd <= '0';
                mem_wr <= '0';   
                branch <= '0';
                alu_cotrol <= "011";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when JAL =>
                sel_cu <= '0';
                sel_pc_res <= '1';
                reg_wr <= '1';
                sel_reg_src <= "100";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "000";
                jal_flag <= '1';
                sel_mux_instr <= '1';
                en_pc <= '0';
                sel_result <= '0';

            when SW =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '0';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '1';
                branch <= '0';
                alu_cotrol <= "001";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when ABSS =>
                sel_cu <= '1';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "000";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '1';

            when IDLE =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '0';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "000";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when BUBBLE1 =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "000";
                jal_flag <= '0';
                sel_mux_instr <= '1';
                en_pc <= '0';
                sel_result <= '0';

            when BUBBLE2 =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                       
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '1';
                alu_cotrol <= "000";
                jal_flag <= '0';
                sel_mux_instr <= '1';
                en_pc <= '1';
                sel_result <= '0';

            when BUBBLE3 =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '1';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "000";
                jal_flag <= '0';
                sel_mux_instr <= '0';
                en_pc <= '1';
                sel_result <= '0';

            when others =>
                sel_cu <= '0';
                sel_pc_res <= '0';
                reg_wr <= '0';
                sel_reg_src <= "000";                    
                mem_rd <= '0';
                mem_wr <= '0';
                branch <= '0';
                alu_cotrol <= "000";
                jal_flag <= '0';
                sel_mux_instr <= '0';
				en_pc <= '1';
                sel_result <= '0';
        
        end case;                   
    end process;   
end architecture behavioral;
