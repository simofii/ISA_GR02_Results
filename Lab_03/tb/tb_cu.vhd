-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * TESTBENCH Control Unit          * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_CU is
end entity;

architecture behavioral of tb_CU is

    component CU is
        generic(N_bit: integer := 7);
        port(opcode: in std_logic_vector(N_bit-1 downto 0);
            func3: in std_logic_vector(2 downto 0);
            clk: in std_logic);
    end component;

    constant PERIOD : time := 1us;
    signal clk: std_logic;
    signal opcode: std_logic_vector (6 downto 0);
    signal func3: std_logic_vector (2 downto 0);

begin

    clk_proc: process
    begin
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process;

    opcode <= "0110011", "1101111" after 1.3us, "0010011" after 2.2us;
    func3 <= "000", "111" after 1.3us, "101" after 2.2us, "000" after 3.3us;

    dut: CU generic map (N_bit => 7)
            port map (opcode => opcode, func3 => func3, clk => clk);

end architecture;
