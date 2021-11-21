library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IIR_filter_mask_in is
    port(
        DIN: in signed (13 downto 0);
        DOUT: out signed (13 downto 0);
        clk, rst, Vin: in std_logic;
        Vout: out std_logic);
end IIR_filter_mask_in;

architecture behavioral of IIR_filter_mask_in is

    
    component add_sub is
        generic(N_bit : integer := 14);
        port(  
        in1, in2 : in signed(N_bit-1 downto 0);
        clk, add_subN : in std_logic;
        result : out signed(N_bit downto 0));
    end component;

    component ffd is
        generic(N_bit : integer := 14);
        port(
            data_in : in signed(N_bit-1 downto 0);
            data_out : out signed (N_bit-1 downto 0);
            clk, rst, cs: in std_logic);
    end component;

    component ffd_std is
    port(
        data_in : in std_logic;
        data_out : out std_logic;
        clk, rst, cs: in std_logic);
    end component;

    component molt is
        generic(N_bit : integer := 14);
        port(   in1, in2 : in signed(N_bit-1 downto 0);
                clk : in std_logic;
                result : out signed((N_bit*2)-1 downto 0));
    end component;

    -- constants, represented on 15 bit 
    constant a1: signed (14 downto 0) := "111101011101110";
    constant b0: signed (14 downto 0) := "000110101110111";
    constant b1: signed (14 downto 0) := "000110101110111";

    constant tco : time := 1 ns;

    signal fb, ff, ff_b0 : signed(13 downto 0);
    signal v, v_old : signed(5 downto 0);
    signal v_ext : signed(14 downto 0);
    signal molt_b0, molt_b1, molt_a1 : signed(11 downto 0);
    signal DOUT_temp : signed(14 downto 0);
    signal data_in_temp : signed(13 downto 0);
    signal Vout_int, Vout_std : std_logic;

    --------------------------------


begin

    fb <= molt_a1(9 downto 0) & "0000";
    ff <= molt_b1(9 downto 0) & "0000";
    ff_b0 <= molt_b0(9 downto 0) & "0000";
    v <= v_ext(14 downto 9);
    Vout <= Vout_std after tco;
   
    add_sx: add_sub  generic map(N_bit=>14)
        port map(in1=>data_in_temp, in2=>fb, add_subN=>'0', clk=>clk, result=>v_ext);
    
    add_dx: add_sub  generic map(N_bit=>14)
        port map(in1=>ff_b0, in2=>ff, add_subN=>'1', clk=>clk, result=>DOUT_temp);

    molta1: molt generic map(N_bit=>6) 
        port map(in1=>v_old, in2=> a1(13 downto 8), clk=>clk, result=>molt_a1);

    moltb1: molt generic map(N_bit=>6)
        port map(in1=>v_old, in2=> b1(13 downto 8), clk=>clk, result=>molt_b1);

    moltb0: molt generic map(N_bit=>6)
        port map(in1=>v, in2=> b0(13 downto 8), clk=>clk, result=>molt_b0);

    del: ffd generic map (N_bit => 6) 
        port map(data_in=>v, data_out=>v_old, clk=>clk, cs=> Vin, rst=>rst);

    reg_in: ffd generic map(N_bit=>14) 
        port map(data_in=>DIN, data_out=>data_in_temp, clk=>clk, cs=> Vin, rst=>rst); 

    reg_DOUT: ffd generic map(N_bit=>14) 
        port map(data_in=>DOUT_temp(13 downto 0), data_out=>DOUT, clk=>clk, cs=> Vout_int, rst=>rst); 

    reg_VOUT_int: ffd_std port map(data_in=>Vin, data_out=>Vout_int, clk=>clk, cs=> '1', rst=>rst); 

    reg_VOUT: ffd_std port map(data_in=>Vout_int, data_out=>Vout_std, clk=>clk, cs=> '1', rst=>rst);




end architecture;