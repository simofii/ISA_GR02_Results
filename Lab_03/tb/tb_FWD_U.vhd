-- *********************************** --
-- * Integrated Systems Architecture * --
-- * Lab 03: RISC-V                  * --  
-- * TESTBENCH Forwarding Unit       * --   
-- * Authors:                        * --
-- *  FIORAVANTI Simone S292612      * --
-- *  MOLINA Ottavio    S292527      * --
-- *  OTTINO Lorenzo    S281571      * --
-- *********************************** --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_FWD_U is
end entity;

architecture behavioral of tb_FWD_U is

    component FWD_U is
    generic(N_bit : integer:=5;
            N_bit_sel: integer := 2);
    port(r1, r2, rd_WB, rd_OS: in std_logic_vector(N_bit -1 downto 0);
         reg_wr_OS, reg_wr_WB: in std_logic;
         sel_fwd, sel_r1: out std_logic_vector(N_bit_sel-1 downto 0));
    end component;

    signal r1, r2, rd_WB, rd_OS: std_logic_vector(4 downto 0);
    signal reg_wr_OS, reg_wr_WB: std_logic;
    signal sel_fwd, sel_r1: std_logic_vector(1 downto 0);

begin
    r1 <= "00001", "00110" after 1us, "01000" after 2us, "00111" after 3us, "11111" after 4us;
    r2 <= "00000", "01010" after 1us, "11000" after 2us, "10101" after 3us, "01111" after 4us;
    rd_WB <= "00000", "00110" after 1us, "11000" after 2us, "11111" after 3us;
    rd_OS <= "00000", "01111" after 1us, "01001" after 2us, "00111" after 3us, "01111" after 4us;
    reg_wr_OS <= '0', '1' after 0.5us;
    reg_wr_WB <= '1', '0' after 2.5us;

    dut: FWD_U generic map (N_bit=>5, N_bit_sel=>2)
               port map (r1 => r1, r2 => r2, rd_OS => rd_OS, rd_WB => rd_WB, reg_wr_WB => reg_wr_WB, reg_wr_OS => reg_wr_OS, sel_fwd => sel_fwd, sel_r1 => sel_r1);
end architecture;