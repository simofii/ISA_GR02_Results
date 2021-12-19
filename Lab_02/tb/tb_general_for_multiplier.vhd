library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;   
USE ieee.std_logic_arith.all;

entity tb_es2_with_MBE is
end entity tb_es2_with_MBE;


architecture behavior of tb_es2_with_MBE is

    --  COMPONENT FPmul IS
    -- PORT( 
    --     FP_A : IN     std_logic_vector (31 DOWNTO 0);
    --     FP_B : IN     std_logic_vector (31 DOWNTO 0);
    --     clk  : IN     std_logic;
    --     FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
    -- );
    -- END COMPONENT ;

    COMPONENT FPmul_reg_in IS
    PORT( 
        FP_A : IN     std_logic_vector (31 DOWNTO 0);
        FP_B : IN     std_logic_vector (31 DOWNTO 0);
        clk  : IN     std_logic;
        FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
    );
    END COMPONENT ;

    component data_maker is
        port (
          CLK  : in  std_logic;
          DATA : out std_logic_vector(31 downto 0));
    end component;

    component data_sink is
        generic (N_bit : integer);
        port (
        CLK   : in std_logic;
        RST_n : in std_logic;
        VIN   : in std_logic;
        DIN   : in std_logic_vector(N_bit-1 downto 0));
    end component;

    signal clk : std_logic;
    signal data_in, data_out : std_logic_vector(31 downto 0);
    --signal data_out_ext: std_logic_vector(63 downto 0);

begin

    clk_proc: process
    begin
        clk <= '0';
        wait for 5ns;
        clk <= '1';
        wait for 5ns;
    end process clk_proc;

    maker_sx : data_maker port map (clk => clk, data => data_in);

    --dut : FPmul port map (clk => clk, FP_A => data_in, FP_B => data_in, FP_Z => data_out);

    write_data : data_sink generic map (N_bit => 32)
        port map (CLK => clk, RST_n => '1', VIN => '1', DIN => data_out);


    dut : FPmul_reg_in port map (clk => clk, FP_A => data_in, FP_B => data_in, FP_Z => data_out);

    
end architecture behavior;  