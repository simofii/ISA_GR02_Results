--prende  in ingresso A, i 3 bit scelti del B e fornisce in uscita il prodotto parziale
--come ingresso necessita anche un segnale che indica se il prodotto è il primo della serie



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity partial_product_generator is
    generic (N_bit : integer := 32);
    port (
        a : in unsigned(N_bit-1 downto 0);
        b : in unsigned(2 downto 0);
        s_prev : in std_logic;
        s_next : out std_logic;
        first : in std_logic;
        data_out : out std_logic_vector(N_bit+4 downto 0));
            --case first ===> s_n + s + s + "data" ====> the last output bit (MSB) is insignificant
            --case not first ====> 1 + s_n + "data" + 0 + s
end entity partial_product_generator;

architecture behavior of partial_product_generator is

    

begin

    proc_name: process(a, b, s_prev)
		 variable partial_product : unsigned(N_bit downto 0);
		 variable s : std_logic;
         variable mask : std_logic_vector(N_bit downto 0);
    begin
        
        if b="111" then
            s := '0';
        else
            s := b(2);
        end if;
        
        mask := (others => s);
        --mask := (others => '0');

        --calcolo prodotto parziale
        if b = "000" or b = "111" then
            partial_product :=  to_unsigned(0, N_bit+1) xor unsigned(mask);
            
        elsif b = "011" or b = "100" then
            partial_product := (a & "0") xor unsigned(mask);
        else
            partial_product := ("0" & a) xor unsigned(mask);
        end if;

        --calcolo prodotto parziale da sommare agli altri (dadda tree)
        if first = '1' then
            data_out <= '0' & not(s) & s & s & std_logic_vector(partial_product);
        else
            data_out <= '1' & not(s) & std_logic_vector(partial_product) & '0' & s_prev;
        end if;
        s_next <= s;

    end process proc_name;
        
end architecture behavior;