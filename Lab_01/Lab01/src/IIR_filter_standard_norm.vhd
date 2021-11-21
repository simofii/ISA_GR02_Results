library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IIR_filter is
    port(
        DIN: in signed (13 downto 0);
        DOUT: out signed (13 downto 0);
        clk, rst, Vin: in std_logic;
        Vout: out std_logic);
end IIR_filter;

architecture behavioral of IIR_filter is

    
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

    
    constant a1: signed (14 downto 0) := "111101011101110";
    constant b0: signed (14 downto 0) := "000110101110111";
    constant b1: signed (14 downto 0) := "000110101110111";

    signal v_old: signed (14 downto 0);
    signal v: signed (14 downto 0);
    signal molt_b0, ff, fb : signed (29 downto 0);
    signal molt_b0_masked, ff_masked, fb_masked : signed (13 downto 0);
    signal data_out_temp: signed (14 downto 0);
    signal data_in_temp, mask : signed (13 downto 0);
    signal Vout_int : std_logic; 

begin

    -- --STANDARD IMPLEMENTAZION
    -- add_sx: add_sub  generic map(N_bit=>14)
    --                  port map(in1=>data_in_temp, in2=>fb(26 downto 13), add_subN=>'0', clk=>clk, result=>v);

    -- add_dx: add_sub  generic map(N_bit=>14)
    --              port map(in1=>molt_b0(26 downto 13), in2=>ff(26 downto 13), add_subN=>'1', clk=>clk, result=>data_out_temp);
    --------------------------------

    --MASKED IMPLEMENTATION (C LIKE)
    mask <= "11111110000000";
    fb_masked <= fb(26 downto 13) and mask;
    ff_masked <= ff(26 downto 13) and mask;
    molt_b0_masked <= molt_b0(26 downto 13) and mask;
    add_sx: add_sub  generic map(N_bit=>14)
                     port map(in1=>data_in_temp, in2=>fb_masked, add_subN=>'0', clk=>clk, result=>v);
    
    add_dx: add_sub  generic map(N_bit=>14)
                 port map(in1=>molt_b0_masked, in2=>ff_masked, add_subN=>'1', clk=>clk, result=>data_out_temp);
    --------------------------------

    molta1: molt generic map(N_bit=>15) 
                port map(in1=>v_old, in2=> a1, clk=>clk, result=>fb);

    moltb1: molt generic map(N_bit=>15)
                port map(in1=>v_old, in2=> b1, clk=>clk, result=>ff);

    moltb0: molt generic map(N_bit=>15)
                port map(in1=>v, in2=> b0, clk=>clk, result=>molt_b0);

    del: ffd generic map (N_bit => 15) 
         port map(data_in=>v, data_out=>v_old, clk=>clk, cs=> Vin, rst=>rst);

    reg_in: ffd generic map(N_bit=>14) 
         port map(data_in=>DIN, data_out=>data_in_temp, clk=>clk, cs=> Vin, rst=>rst); 

    reg_DOUT: ffd generic map(N_bit=>14) 
        port map(data_in=>data_out_temp(13 downto 0), data_out=>DOUT, clk=>clk, cs=> Vout_int, rst=>rst); 

    reg_VOUT_int: ffd_std port map(data_in=>Vin, data_out=>Vout_int, clk=>clk, cs=> '1', rst=>rst); 

    reg_VOUT: ffd_std port map(data_in=>Vout_int, data_out=>Vout, clk=>clk, cs=> '1', rst=>rst);
     

    
end architecture;
