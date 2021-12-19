library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_encoder is
end entity tb_encoder;  

architecture behavior of tb_encoder is

    constant PERIOD : time := 1us;
    
    signal clk, rst, en, first : std_logic;
    signal a : unsigned(7 downto 0);
    signal b : unsigned(2 downto 0);
    signal data_out : std_logic_vector(12 downto 0);

    component partial_product_generator is
        generic (N_bit : integer := 16);
        port (
            a : in unsigned(N_bit-1 downto 0);
            b : in unsigned(2 downto 0);
            first, clk, en, rst : in std_logic;
            data_out : out std_logic_vector(N_bit+4 downto 0));
                --case first ===> s_n + s + s + "data" ====> the last output bit (MSB) is insignificant
                --case not first ====> 1 + s_n + "data" + 0 + s
    end component;

begin

    clk_proc: process
    begin
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process clk_proc;

    rst <= '0', '1' after 2.3 us;
    en <= '0', '1' after 3.3us;
    
    a <= (others => '1'), "01010101" after 6.3us;
    b <= "000", "100" after 4.3us, "010" after 5.3us, "111" after 6.3us;
    first <= '1', '0' after 4.3us;

    dut : partial_product_generator generic map (N_bit => 8)
        port map(a => a, b => b, clk => clk, rst => rst, en => en, first => first, data_out => data_out);
    
end architecture behavior;