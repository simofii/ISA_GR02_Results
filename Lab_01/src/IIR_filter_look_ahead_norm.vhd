library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IIR_filter_std_pipe is
    port(
        DIN: in signed (13 downto 0);
        DOUT: out signed (13 downto 0);
        clk, rst, Vin: in std_logic;
        Vout: out std_logic);
end IIR_filter_std_pipe;

architecture behavioral of IIR_filter_std_pipe is

    
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
    constant a1_squared: signed (14 downto 0) := "000000011001110";
    constant b0: signed (14 downto 0) := "000110101110111";
    constant b1: signed (14 downto 0) := "000110101110111";

    constant tco : time := 1 ns;

    signal data_in_pipe, molt_a1_in_out_pipe, molt_a1_squared_out_pipe, molt_a1_v_out_pipe, molt_a1_v_out_pipe_pipe, molt_b0_out_pipe, molt_b1_out_pipe: signed (13 downto 0);
    signal data_in_pipe_pipe, data_in_pipe_pipe_pipe, molt_b0_out_pipe_pipe : signed(13 downto 0);
    signal add_v_sx_out, add_v_dx_out, add_v_dx_out_pipe, add_dx_out, add_sx_out : signed(14 downto 0);
    signal molt_a1_in_out : signed(27 downto 0);
    signal molt_a1_squared_out, molt_a1_v_out, molt_b0_out, molt_b1_out : signed(29 downto 0);
    signal v_old, v : signed(14 downto 0);
	signal Vin_1, Vin_2, Vin_3, Vin_4 : std_logic;
    signal en_reg_4: std_logic;

    --------------------------------


begin

    add_sx: add_sub  generic map(N_bit=>14) --  
        port map(in1=>data_in_pipe, in2=>add_v_sx_out(13 downto 0), add_subN=>'1', clk=>clk, result=>add_sx_out);
    
    add_dx: add_sub  generic map(N_bit=>14) --
        port map(in1=>molt_b0_out_pipe_pipe, in2=>molt_b1_out_pipe, add_subN=>'1', clk=>clk, result=>add_dx_out);

    add_v_sx: add_sub  generic map(N_bit=>14) --
        port map(in2=>molt_a1_in_out_pipe, in1=>molt_a1_squared_out_pipe, add_subN=>'0', clk=>clk, result=>add_v_sx_out);
    
    add_v_dx: add_sub  generic map(N_bit=>14) --
        port map(in1=>data_in_pipe_pipe_pipe, in2=>molt_a1_v_out_pipe_pipe, add_subN=>'0', clk=>clk, result=>add_v_dx_out);

-----------------------------------------

    molt_a1_v: molt generic map(N_bit=>15) --
        port map(in1=>v_old, in2=> a1, clk=>clk, result=>molt_a1_v_out);

    molt_a1_in: molt generic map(N_bit=>14) --
        port map(in1=>data_in_pipe, in2=> a1(13 downto 0), clk=>clk, result=>molt_a1_in_out);

    molt_a1_squared: molt generic map(N_bit=>15) --
        port map(in1=>v_old, in2=> a1_squared, clk=>clk, result=>molt_a1_squared_out);

    molt_b1: molt generic map(N_bit=>15) --
        port map(in1=>add_v_dx_out_pipe, in2=> b1, clk=>clk, result=>molt_b1_out);

    molt_b0: molt generic map(N_bit=>15) --
        port map(in1=>v_old, in2=> b0, clk=>clk, result=>molt_b0_out);

---------------------------------------        

    reg_1: ffd generic map (N_bit => 14) --
        port map(data_in=>DIN, data_out=>data_in_pipe, clk=>clk, cs=> Vin, rst=>rst);

    reg_2: ffd generic map(N_bit=>14) --
        port map(data_in=>molt_b0_out_pipe, data_out=>molt_b0_out_pipe_pipe, clk=>clk, cs=> Vin_3, rst=>rst); 

    reg_3: ffd generic map(N_bit=>14) --
        port map(data_in=>molt_a1_in_out(26 downto 13), data_out=>molt_a1_in_out_pipe, clk=>clk, cs=> Vin_1, rst=>rst); 

    reg_4: ffd generic map(N_bit=>14) --
        port map(data_in=>molt_a1_squared_out(26 downto 13), data_out=>molt_a1_squared_out_pipe, clk=>clk, cs=> Vin_1, rst=>rst); 

    reg_5: ffd generic map(N_bit=>15) --
        port map(data_in=>v, data_out=>v_old, clk=>clk, cs=> Vin_1, rst=>rst); 

    reg_6: ffd generic map(N_bit=>14) --
        port map(data_in=>molt_a1_v_out_pipe, data_out=>molt_a1_v_out_pipe_pipe, clk=>clk, cs=> Vin_3, rst=>rst); 

    reg_7: ffd generic map(N_bit=>14) --
        port map(data_in=>molt_b0_out(26 downto 13), data_out=>molt_b0_out_pipe, clk=>clk, cs=> Vin_2, rst=>rst); 

    reg_8: ffd generic map(N_bit=>14) --
        port map(data_in=>molt_b1_out(26 downto 13), data_out=>molt_b1_out_pipe, clk=>clk, cs=> Vin_4, rst=>rst); 

    reg_9: ffd generic map(N_bit=>15) --
        port map(data_in=>add_v_dx_out, data_out=>add_v_dx_out_pipe, clk=>clk, cs=> Vin_3, rst=>rst); 

    reg_10: ffd generic map(N_bit=>14) --
        port map(data_in=>data_in_pipe, data_out=>data_in_pipe_pipe, clk=>clk, cs=> Vin_1, rst=>rst); 
    
    reg_11: ffd generic map(N_bit=>14) --
        port map(data_in=>data_in_pipe_pipe, data_out=>data_in_pipe_pipe_pipe, clk=>clk, cs=> Vin_2, rst=>rst); 
        
    reg_12: ffd generic map(N_bit=>14) --
        port map(data_in=>molt_a1_v_out(26 downto 13), data_out=>molt_a1_v_out_pipe, clk=>clk, cs=> Vin_2, rst=>rst);
    
    reg_DOUT: ffd generic map(N_bit=>14) --
        port map(data_in=>add_dx_out(13 downto 0), data_out=>DOUT, clk=>clk, cs=> Vin_4, rst=>rst); 

    
    
    
    reg_VOUT_1: ffd_std port map(data_in=>Vin, data_out=>Vin_1, clk=>clk, cs=> '1', rst=>rst); 

    reg_VOUT_2: ffd_std port map(data_in=>Vin_1, data_out=>Vin_2, clk=>clk, cs=> '1', rst=>rst); 

    reg_VOUT_3: ffd_std port map(data_in=>Vin_2, data_out=>Vin_3, clk=>clk, cs=> '1', rst=>rst); 

    reg_VOUT_4: ffd_std port map(data_in=>Vin_3, data_out=>Vin_4, clk=>clk, cs=> '1', rst=>rst);
    
    reg_VOUT_5: ffd_std port map(data_in=>Vin_4, data_out=>Vout, clk=>clk, cs=> '1', rst=>rst); 
    
    v <= add_sx_out;
    en_reg_4 <= (Vin_1 and Vin_2) or (Vin_2 and Vin_3);




end architecture;