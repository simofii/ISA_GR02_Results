library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MBE_molt is
    generic (N_bit : integer := 32);
    --generic (N_bit : integer := 6);
    port(
        in1: in unsigned(N_bit-1 downto 0);
        in2: in unsigned(N_bit-1 downto 0);
		sig_out: out unsigned(2*N_bit-1 downto 0));		

end MBE_molt;

architecture behavioral of MBE_molt is
    
    component partial_product_generator is
	    generic (N_bit : integer := 32);
--		  generic (N_bit : integer := 6);
        port (
            a : in unsigned(N_bit-1 downto 0);
            b : in unsigned(2 downto 0);
            s_prev : in std_logic;
            s_next : out std_logic;
            first : in std_logic;
            data_out : out std_logic_vector(N_bit+4 downto 0));
                --case first ===> s_n + s + s + "data" ====> the last output bit (MSB) is insignificant
                --case not first ====> 1 + s_n + "data" + 0 + s
    end component;

	component fa is
		port (
			in1, in2: in std_logic;
			c_in: in std_logic;
			c_out: out std_logic;
			sum: out std_logic);
	end component;

	component ha is
		port (
			in1: in std_logic;
			in2: in std_logic;
			c_out: out std_logic;
			sum: out std_logic);
	end component;

	--signal to geenrate tabel of partial product
    type partial_product is array (16 downto 0) of std_logic_vector (36 downto 0);
    signal part_prod: partial_product;
	
	--signal in2 extended
	signal in2_ext: unsigned (34 downto 0);
	 
	--signal used for dadda tree
	signal s_encode: std_logic_vector(17 downto 0);
	signal sum_st1 : std_logic_vector(51 downto 0);
	signal carry_st1 : std_logic_vector(51 downto 0);
	signal sum_st2 : std_logic_vector(115 downto 0);
	signal carry_st2 : std_logic_vector(115 downto 0);
	signal sum_st3 : std_logic_vector(128 downto 0);
	signal carry_st3 : std_logic_vector(128 downto 0);
	signal sum_st4 : std_logic_vector(105 downto 0);
	signal carry_st4 : std_logic_vector(105 downto 0);
	signal sum_st5 : std_logic_vector(58 downto 0);
	signal carry_st5 : std_logic_vector(58 downto 0);
	signal sum_st6 : std_logic_vector(61 downto 0);
	signal carry_st6 : std_logic_vector(61 downto 0);
	signal carry_st7 : std_logic_vector(64 downto 0);
	signal result: std_logic_vector(65 downto 0);

begin

    --in2 extenction
    in2_ext<="00" & in2 & '0';
	 s_encode(0)<='0';
	--table of partial product
    partialprod1: partial_product_generator generic map(N_bit=>32) 
					   port map (a=>in1, b=>in2_ext(2 downto 0), data_out=>part_prod(0), first=> '1',  s_prev=>s_encode(0), s_next=>s_encode(1));
	 
    tabel_culumn: for i in 2 to 17 generate
				partialprod: partial_product_generator generic map(N_bit=>32)
					port map (a=>in1, b=>in2_ext(2*i downto ((2*i)-2)), data_out=>part_prod(i-1), first=> '0', s_prev=>s_encode(i-1), s_next=>s_encode(i));	
	 
    end generate;
	 
	--dadda tree

	add_num0_st1 : ha port map (in1 => part_prod(0)(24), in2 => part_prod(1)(24), sum => sum_st1(0), c_out => carry_st1(0));

	add_num1_st1 : ha port map (in1 => part_prod(0)(25), in2 => part_prod(1)(25), sum => sum_st1(1), c_out => carry_st1(1));
	
	add_num2_st1 : fa port map (in1 => part_prod(0)(26), in2 => part_prod(1)(26), c_in => part_prod(2)(24), sum => sum_st1(2), c_out => carry_st1(2));
	
	add_num3_st1 : ha port map (in1 => part_prod(3)(22), in2 => part_prod(4)(20), sum => sum_st1(3), c_out => carry_st1(3));
	
	add_num4_st1 : fa port map (in1 => part_prod(0)(27), in2 => part_prod(1)(27), c_in => part_prod(2)(25), sum => sum_st1(4), c_out => carry_st1(4));
	
	add_num5_st1 : ha port map (in1 => part_prod(3)(23), in2 => part_prod(4)(21), sum => sum_st1(5), c_out => carry_st1(5));
	
	add_num6_st1 : fa port map (in1 => part_prod(0)(28), in2 => part_prod(1)(28), c_in => part_prod(2)(26), sum => sum_st1(6), c_out => carry_st1(6));
	
	add_num7_st1 : fa port map (in1 => part_prod(3)(24), in2 => part_prod(4)(22), c_in => part_prod(5)(20), sum => sum_st1(7), c_out => carry_st1(7));
	
	add_num8_st1 : ha port map (in1 => part_prod(6)(18), in2 => part_prod(7)(16), sum => sum_st1(8), c_out => carry_st1(8));
	
	add_num9_st1 : fa port map (in1 => part_prod(0)(29), in2 => part_prod(1)(29), c_in => part_prod(2)(27), sum => sum_st1(9), c_out => carry_st1(9));
	
	add_num10_st1 : fa port map (in1 => part_prod(3)(25), in2 => part_prod(4)(23), c_in => part_prod(5)(21), sum => sum_st1(10), c_out => carry_st1(10));
	
	add_num11_st1 : ha port map (in1 => part_prod(6)(19), in2 => part_prod(7)(17), sum => sum_st1(11), c_out => carry_st1(11));
	
	add_num12_st1 : fa port map (in1 => part_prod(0)(30), in2 => part_prod(1)(30), c_in => part_prod(2)(28), sum => sum_st1(12), c_out => carry_st1(12));
	
	add_num13_st1 : fa port map (in1 => part_prod(3)(26), in2 => part_prod(4)(24), c_in => part_prod(5)(22), sum => sum_st1(13), c_out => carry_st1(13));
	
	add_num14_st1 : fa port map (in1 => part_prod(6)(20), in2 => part_prod(7)(18), c_in => part_prod(8)(16), sum => sum_st1(14), c_out => carry_st1(14));
	
	add_num15_st1 : ha port map (in1 => part_prod(9)(14), in2 => part_prod(10)(12), sum => sum_st1(15), c_out => carry_st1(15));
	
	add_num16_st1 : fa port map (in1 => part_prod(0)(31), in2 => part_prod(1)(31), c_in => part_prod(2)(29), sum => sum_st1(16), c_out => carry_st1(16));
	
	add_num17_st1 : fa port map (in1 => part_prod(3)(27), in2 => part_prod(4)(25), c_in => part_prod(5)(23), sum => sum_st1(17), c_out => carry_st1(17));
	
	add_num18_st1 : fa port map (in1 => part_prod(6)(21), in2 => part_prod(7)(19), c_in => part_prod(8)(17), sum => sum_st1(18), c_out => carry_st1(18));
	
	add_num19_st1 : ha port map (in1 => part_prod(9)(15), in2 => part_prod(10)(13), sum => sum_st1(19), c_out => carry_st1(19));
	
	add_num20_st1 : fa port map (in1 => part_prod(0)(32), in2 => part_prod(1)(32), c_in => part_prod(2)(30), sum => sum_st1(20), c_out => carry_st1(20));
	
	add_num21_st1 : fa port map (in1 => part_prod(3)(28), in2 => part_prod(4)(26), c_in => part_prod(5)(24), sum => sum_st1(21), c_out => carry_st1(21));
	
	add_num22_st1 : fa port map (in1 => part_prod(6)(22), in2 => part_prod(7)(20), c_in => part_prod(8)(18), sum => sum_st1(22), c_out => carry_st1(22));
	
	add_num23_st1 : fa port map (in1 => part_prod(9)(16), in2 => part_prod(10)(14), c_in => part_prod(11)(12), sum => sum_st1(23), c_out => carry_st1(23));
	
	add_num24_st1 : fa port map (in1 => part_prod(0)(33), in2 => part_prod(1)(33), c_in => part_prod(2)(31), sum => sum_st1(24), c_out => carry_st1(24));
	
	add_num25_st1 : fa port map (in1 => part_prod(3)(29), in2 => part_prod(4)(27), c_in => part_prod(5)(25), sum => sum_st1(25), c_out => carry_st1(25));
	
	add_num26_st1 : fa port map (in1 => part_prod(6)(23), in2 => part_prod(7)(21), c_in => part_prod(8)(19), sum => sum_st1(26), c_out => carry_st1(26));
	
	add_num27_st1 : fa port map (in1 => part_prod(9)(17), in2 => part_prod(10)(15), c_in => part_prod(11)(13), sum => sum_st1(27), c_out => carry_st1(27));
	
	add_num28_st1 : fa port map (in1 => part_prod(0)(34), in2 => part_prod(1)(34), c_in => part_prod(2)(32), sum => sum_st1(28), c_out => carry_st1(28));
	
	add_num29_st1 : fa port map (in1 => part_prod(3)(30), in2 => part_prod(4)(28), c_in => part_prod(5)(26), sum => sum_st1(29), c_out => carry_st1(29));
	
	add_num30_st1 : fa port map (in1 => part_prod(6)(24), in2 => part_prod(7)(22), c_in => part_prod(8)(20), sum => sum_st1(30), c_out => carry_st1(30));
	
	add_num31_st1 : fa port map (in1 => part_prod(9)(18), in2 => part_prod(10)(16), c_in => part_prod(11)(14), sum => sum_st1(31), c_out => carry_st1(31));
	
	add_num32_st1 : fa port map (in1 => part_prod(0)(35), in2 => part_prod(1)(35), c_in => part_prod(2)(33), sum => sum_st1(32), c_out => carry_st1(32));
	
	add_num33_st1 : fa port map (in1 => part_prod(3)(31), in2 => part_prod(4)(29), c_in => part_prod(5)(27), sum => sum_st1(33), c_out => carry_st1(33));
	
	add_num34_st1 : fa port map (in1 => part_prod(6)(25), in2 => part_prod(7)(23), c_in => part_prod(8)(21), sum => sum_st1(34), c_out => carry_st1(34));
	
	add_num35_st1 : fa port map (in1 => part_prod(9)(19), in2 => part_prod(10)(17), c_in => part_prod(11)(15), sum => sum_st1(35), c_out => carry_st1(35));
	
	add_num36_st1 : fa port map (in1 => part_prod(1)(36), in2 => part_prod(2)(34), c_in => part_prod(3)(32), sum => sum_st1(36), c_out => carry_st1(36));
	
	add_num37_st1 : fa port map (in1 => part_prod(4)(30), in2 => part_prod(5)(28), c_in => part_prod(6)(26), sum => sum_st1(37), c_out => carry_st1(37));
	
	add_num38_st1 : fa port map (in1 => part_prod(7)(24), in2 => part_prod(8)(22), c_in => part_prod(9)(20), sum => sum_st1(38), c_out => carry_st1(38));
	
	add_num39_st1 : ha port map (in1 => part_prod(10)(18), in2 => part_prod(11)(16), sum => sum_st1(39), c_out => carry_st1(39));
	
	add_num40_st1 : fa port map (in1 => part_prod(2)(35), in2 => part_prod(3)(33), c_in => part_prod(4)(31), sum => sum_st1(40), c_out => carry_st1(40));
	
	add_num41_st1 : fa port map (in1 => part_prod(5)(29), in2 => part_prod(6)(27), c_in => part_prod(7)(25), sum => sum_st1(41), c_out => carry_st1(41));
	
	add_num42_st1 : fa port map (in1 => part_prod(8)(23), in2 => part_prod(9)(21), c_in => part_prod(10)(19), sum => sum_st1(42), c_out => carry_st1(42));
	
	add_num43_st1 : fa port map (in1 => part_prod(2)(36), in2 => part_prod(3)(34), c_in => part_prod(4)(32), sum => sum_st1(43), c_out => carry_st1(43));
	
	add_num44_st1 : fa port map (in1 => part_prod(5)(30), in2 => part_prod(6)(28), c_in => part_prod(7)(26), sum => sum_st1(44), c_out => carry_st1(44));
	
	add_num45_st1 : ha port map (in1 => part_prod(8)(24), in2 => part_prod(9)(22), sum => sum_st1(45), c_out => carry_st1(45));
	
	add_num46_st1 : fa port map (in1 => part_prod(3)(35), in2 => part_prod(4)(33), c_in => part_prod(5)(31), sum => sum_st1(46), c_out => carry_st1(46));
	
	add_num47_st1 : fa port map (in1 => part_prod(6)(29), in2 => part_prod(7)(27), c_in => part_prod(8)(25), sum => sum_st1(47), c_out => carry_st1(47));
	
	add_num48_st1 : fa port map (in1 => part_prod(3)(36), in2 => part_prod(4)(34), c_in => part_prod(5)(32), sum => sum_st1(48), c_out => carry_st1(48));
	
	add_num49_st1 : ha port map (in1 => part_prod(6)(30), in2 => part_prod(7)(28), sum => sum_st1(49), c_out => carry_st1(49));
	
	add_num50_st1 : fa port map (in1 => part_prod(4)(35), in2 => part_prod(5)(33), c_in => part_prod(6)(31), sum => sum_st1(50), c_out => carry_st1(50));
	
	add_num51_st1 : ha port map (in1 => part_prod(4)(36), in2 => part_prod(5)(34), sum => sum_st1(51), c_out => carry_st1(51));
	
	add_num0_st2 : ha port map (in1 => part_prod(0)(16), in2 => part_prod(1)(16), sum => sum_st2(0), c_out => carry_st2(0));
	
	add_num1_st2 : ha port map (in1 => part_prod(0)(17), in2 => part_prod(1)(17), sum => sum_st2(1), c_out => carry_st2(1));
	
	add_num2_st2 : fa port map (in1 => part_prod(0)(18), in2 => part_prod(1)(18), c_in => part_prod(2)(16), sum => sum_st2(2), c_out => carry_st2(2));
	
	add_num3_st2 : ha port map (in1 => part_prod(3)(14), in2 => part_prod(4)(12), sum => sum_st2(3), c_out => carry_st2(3));
	
	add_num4_st2 : fa port map (in1 => part_prod(0)(19), in2 => part_prod(1)(19), c_in => part_prod(2)(17), sum => sum_st2(4), c_out => carry_st2(4));
	
	add_num5_st2 : ha port map (in1 => part_prod(3)(15), in2 => part_prod(4)(13), sum => sum_st2(5), c_out => carry_st2(5));
	
	add_num6_st2 : fa port map (in1 => part_prod(0)(20), in2 => part_prod(1)(20), c_in => part_prod(2)(18), sum => sum_st2(6), c_out => carry_st2(6));
	
	add_num7_st2 : fa port map (in1 => part_prod(3)(16), in2 => part_prod(4)(14), c_in => part_prod(5)(12), sum => sum_st2(7), c_out => carry_st2(7));
	
	add_num8_st2 : ha port map (in1 => part_prod(6)(10), in2 => part_prod(7)(8), sum => sum_st2(8), c_out => carry_st2(8));
	
	add_num9_st2 : fa port map (in1 => part_prod(0)(21), in2 => part_prod(1)(21), c_in => part_prod(2)(19), sum => sum_st2(9), c_out => carry_st2(9));
	
	add_num10_st2 : fa port map (in1 => part_prod(3)(17), in2 => part_prod(4)(15), c_in => part_prod(5)(13), sum => sum_st2(10), c_out => carry_st2(10));
	
	add_num11_st2 : ha port map (in1 => part_prod(6)(11), in2 => part_prod(7)(9), sum => sum_st2(11), c_out => carry_st2(11));
	
	add_num12_st2 : fa port map (in1 => part_prod(0)(22), in2 => part_prod(1)(22), c_in => part_prod(2)(20), sum => sum_st2(12), c_out => carry_st2(12));
	
	add_num13_st2 : fa port map (in1 => part_prod(3)(18), in2 => part_prod(4)(16), c_in => part_prod(5)(14), sum => sum_st2(13), c_out => carry_st2(13));
	
	add_num14_st2 : fa port map (in1 => part_prod(6)(12), in2 => part_prod(7)(10), c_in => part_prod(8)(8), sum => sum_st2(14), c_out => carry_st2(14));
	
	add_num15_st2 : ha port map (in1 => part_prod(9)(6), in2 => part_prod(10)(4), sum => sum_st2(15), c_out => carry_st2(15));
	
	add_num16_st2 : fa port map (in1 => part_prod(0)(23), in2 => part_prod(1)(23), c_in => part_prod(2)(21), sum => sum_st2(16), c_out => carry_st2(16));
	
	add_num17_st2 : fa port map (in1 => part_prod(3)(19), in2 => part_prod(4)(17), c_in => part_prod(5)(15), sum => sum_st2(17), c_out => carry_st2(17));
	
	add_num18_st2 : fa port map (in1 => part_prod(6)(13), in2 => part_prod(7)(11), c_in => part_prod(8)(9), sum => sum_st2(18), c_out => carry_st2(18));
	
	add_num19_st2 : ha port map (in1 => part_prod(9)(7), in2 => part_prod(10)(5), sum => sum_st2(19), c_out => carry_st2(19));
	
	add_num20_st2 : fa port map (in1 => sum_st1(0), in2 => part_prod(2)(22), c_in => part_prod(3)(20), sum => sum_st2(20), c_out => carry_st2(20));
	
	add_num21_st2 : fa port map (in1 => part_prod(4)(18), in2 => part_prod(5)(16), c_in => part_prod(6)(14), sum => sum_st2(21), c_out => carry_st2(21));
	
	add_num22_st2 : fa port map (in1 => part_prod(7)(12), in2 => part_prod(8)(10), c_in => part_prod(9)(8), sum => sum_st2(22), c_out => carry_st2(22));
	
	add_num23_st2 : fa port map (in1 => part_prod(10)(6), in2 => part_prod(11)(4), c_in => part_prod(12)(2), sum => sum_st2(23), c_out => carry_st2(23));
	
	add_num24_st2 : fa port map (in1 => carry_st1(0), in2 => sum_st1(1), c_in => part_prod(2)(23), sum => sum_st2(24), c_out => carry_st2(24));
	
	add_num25_st2 : fa port map (in1 => part_prod(3)(21), in2 => part_prod(4)(19), c_in => part_prod(5)(17), sum => sum_st2(25), c_out => carry_st2(25));
	
	add_num26_st2 : fa port map (in1 => part_prod(6)(15), in2 => part_prod(7)(13), c_in => part_prod(8)(11), sum => sum_st2(26), c_out => carry_st2(26));
	
	add_num27_st2 : fa port map (in1 => part_prod(9)(9), in2 => part_prod(10)(7), c_in => part_prod(11)(5), sum => sum_st2(27), c_out => carry_st2(27));
	
	add_num28_st2 : fa port map (in1 => carry_st1(1), in2 => sum_st1(2), c_in => sum_st1(3), sum => sum_st2(28), c_out => carry_st2(28));
	
	add_num29_st2 : fa port map (in1 => part_prod(5)(18), in2 => part_prod(6)(16), c_in => part_prod(7)(14), sum => sum_st2(29), c_out => carry_st2(29));
	
	add_num30_st2 : fa port map (in1 => part_prod(8)(12), in2 => part_prod(9)(10), c_in => part_prod(10)(8), sum => sum_st2(30), c_out => carry_st2(30));
	
	add_num31_st2 : fa port map (in1 => part_prod(11)(6), in2 => part_prod(12)(4), c_in => part_prod(13)(2), sum => sum_st2(31), c_out => carry_st2(31));
	
	add_num32_st2 : fa port map (in1 => carry_st1(2), in2 => carry_st1(3), c_in => sum_st1(4), sum => sum_st2(32), c_out => carry_st2(32));
	
	add_num33_st2 : fa port map (in1 => sum_st1(5), in2 => part_prod(5)(19), c_in => part_prod(6)(17), sum => sum_st2(33), c_out => carry_st2(33));
	
	add_num34_st2 : fa port map (in1 => part_prod(7)(15), in2 => part_prod(8)(13), c_in => part_prod(9)(11), sum => sum_st2(34), c_out => carry_st2(34));
	
	add_num35_st2 : fa port map (in1 => part_prod(10)(9), in2 => part_prod(11)(7), c_in => part_prod(12)(5), sum => sum_st2(35), c_out => carry_st2(35));
	
	add_num36_st2 : fa port map (in1 => carry_st1(4), in2 => carry_st1(5), c_in => sum_st1(6), sum => sum_st2(36), c_out => carry_st2(36));
	
	add_num37_st2 : fa port map (in1 => sum_st1(7), in2 => sum_st1(8), c_in => part_prod(8)(14), sum => sum_st2(37), c_out => carry_st2(37));
	
	add_num38_st2 : fa port map (in1 => part_prod(9)(12), in2 => part_prod(10)(10), c_in => part_prod(11)(8), sum => sum_st2(38), c_out => carry_st2(38));
	
	add_num39_st2 : fa port map (in1 => part_prod(12)(6), in2 => part_prod(13)(4), c_in => part_prod(14)(2), sum => sum_st2(39), c_out => carry_st2(39));
	
	add_num40_st2 : fa port map (in1 => carry_st1(6), in2 => carry_st1(7), c_in => carry_st1(8), sum => sum_st2(40), c_out => carry_st2(40));
	
	add_num41_st2 : fa port map (in1 => sum_st1(9), in2 => sum_st1(10), c_in => sum_st1(11), sum => sum_st2(41), c_out => carry_st2(41));
	
	add_num42_st2 : fa port map (in1 => part_prod(8)(15), in2 => part_prod(9)(13), c_in => part_prod(10)(11), sum => sum_st2(42), c_out => carry_st2(42));
	
	add_num43_st2 : fa port map (in1 => part_prod(11)(9), in2 => part_prod(12)(7), c_in => part_prod(13)(5), sum => sum_st2(43), c_out => carry_st2(43));
	
	add_num44_st2 : fa port map (in1 => carry_st1(9), in2 => carry_st1(10), c_in => carry_st1(11), sum => sum_st2(44), c_out => carry_st2(44));
	
	add_num45_st2 : fa port map (in1 => sum_st1(12), in2 => sum_st1(13), c_in => sum_st1(14), sum => sum_st2(45), c_out => carry_st2(45));
	
	add_num46_st2 : fa port map (in1 => sum_st1(15), in2 => part_prod(11)(10), c_in => part_prod(12)(8), sum => sum_st2(46), c_out => carry_st2(46));
	
	add_num47_st2 : fa port map (in1 => part_prod(13)(6), in2 => part_prod(14)(4), c_in => part_prod(15)(2), sum => sum_st2(47), c_out => carry_st2(47));
	
	add_num48_st2 : fa port map (in1 => carry_st1(12), in2 => carry_st1(13), c_in => carry_st1(14), sum => sum_st2(48), c_out => carry_st2(48));
	
	add_num49_st2 : fa port map (in1 => carry_st1(15), in2 => sum_st1(16), c_in => sum_st1(17), sum => sum_st2(49), c_out => carry_st2(49));
	
	add_num50_st2 : fa port map (in1 => sum_st1(18), in2 => sum_st1(19), c_in => part_prod(11)(11), sum => sum_st2(50), c_out => carry_st2(50));
	
	add_num51_st2 : fa port map (in1 => part_prod(12)(9), in2 => part_prod(13)(7), c_in => part_prod(14)(5), sum => sum_st2(51), c_out => carry_st2(51));
	
	add_num52_st2 : fa port map (in1 => carry_st1(16), in2 => carry_st1(17), c_in => carry_st1(18), sum => sum_st2(52), c_out => carry_st2(52));
	
	add_num53_st2 : fa port map (in1 => carry_st1(19), in2 => sum_st1(20), c_in => sum_st1(21), sum => sum_st2(53), c_out => carry_st2(53));
	
	add_num54_st2 : fa port map (in1 => sum_st1(22), in2 => sum_st1(23), c_in => part_prod(12)(10), sum => sum_st2(54), c_out => carry_st2(54));
	
	add_num55_st2 : fa port map (in1 => part_prod(13)(8), in2 => part_prod(14)(6), c_in => part_prod(15)(4), sum => sum_st2(55), c_out => carry_st2(55));
	
	add_num56_st2 : fa port map (in1 => carry_st1(20), in2 => carry_st1(21), c_in => carry_st1(22), sum => sum_st2(56), c_out => carry_st2(56));
	
	add_num57_st2 : fa port map (in1 => carry_st1(23), in2 => sum_st1(24), c_in => sum_st1(25), sum => sum_st2(57), c_out => carry_st2(57));
	
	add_num58_st2 : fa port map (in1 => sum_st1(26), in2 => sum_st1(27), c_in => part_prod(12)(11), sum => sum_st2(58), c_out => carry_st2(58));
	
	add_num59_st2 : fa port map (in1 => part_prod(13)(9), in2 => part_prod(14)(7), c_in => part_prod(15)(5), sum => sum_st2(59), c_out => carry_st2(59));
	
	add_num60_st2 : fa port map (in1 => carry_st1(24), in2 => carry_st1(25), c_in => carry_st1(26), sum => sum_st2(60), c_out => carry_st2(60));
	
	add_num61_st2 : fa port map (in1 => carry_st1(27), in2 => sum_st1(28), c_in => sum_st1(29), sum => sum_st2(61), c_out => carry_st2(61));
	
	add_num62_st2 : fa port map (in1 => sum_st1(30), in2 => sum_st1(31), c_in => part_prod(12)(12), sum => sum_st2(62), c_out => carry_st2(62));
	
	add_num63_st2 : fa port map (in1 => part_prod(13)(10), in2 => part_prod(14)(8), c_in => part_prod(15)(6), sum => sum_st2(63), c_out => carry_st2(63));
	
	add_num64_st2 : fa port map (in1 => carry_st1(28), in2 => carry_st1(29), c_in => carry_st1(30), sum => sum_st2(64), c_out => carry_st2(64));
	
	add_num65_st2 : fa port map (in1 => carry_st1(31), in2 => sum_st1(32), c_in => sum_st1(33), sum => sum_st2(65), c_out => carry_st2(65));
	
	add_num66_st2 : fa port map (in1 => sum_st1(34), in2 => sum_st1(35), c_in => part_prod(12)(13), sum => sum_st2(66), c_out => carry_st2(66));
	
	add_num67_st2 : fa port map (in1 => part_prod(13)(11), in2 => part_prod(14)(9), c_in => part_prod(15)(7), sum => sum_st2(67), c_out => carry_st2(67));
	
	add_num68_st2 : fa port map (in1 => carry_st1(32), in2 => carry_st1(33), c_in => carry_st1(34), sum => sum_st2(68), c_out => carry_st2(68));
	
	add_num69_st2 : fa port map (in1 => carry_st1(35), in2 => sum_st1(36), c_in => sum_st1(37), sum => sum_st2(69), c_out => carry_st2(69));
	
	add_num70_st2 : fa port map (in1 => sum_st1(38), in2 => sum_st1(39), c_in => part_prod(12)(14), sum => sum_st2(70), c_out => carry_st2(70));
	
	add_num71_st2 : fa port map (in1 => part_prod(13)(12), in2 => part_prod(14)(10), c_in => part_prod(15)(8), sum => sum_st2(71), c_out => carry_st2(71));
	
	add_num72_st2 : fa port map (in1 => carry_st1(36), in2 => carry_st1(37), c_in => carry_st1(38), sum => sum_st2(72), c_out => carry_st2(72));
	
	add_num73_st2 : fa port map (in1 => carry_st1(39), in2 => sum_st1(40), c_in => sum_st1(41), sum => sum_st2(73), c_out => carry_st2(73));
	
	add_num74_st2 : fa port map (in1 => sum_st1(42), in2 => part_prod(11)(17), c_in => part_prod(12)(15), sum => sum_st2(74), c_out => carry_st2(74));
	
	add_num75_st2 : fa port map (in1 => part_prod(13)(13), in2 => part_prod(14)(11), c_in => part_prod(15)(9), sum => sum_st2(75), c_out => carry_st2(75));
	
	add_num76_st2 : fa port map (in1 => carry_st1(40), in2 => carry_st1(41), c_in => carry_st1(42), sum => sum_st2(76), c_out => carry_st2(76));
	
	add_num77_st2 : fa port map (in1 => sum_st1(43), in2 => sum_st1(44), c_in => sum_st1(45), sum => sum_st2(77), c_out => carry_st2(77));
	
	add_num78_st2 : fa port map (in1 => part_prod(10)(20), in2 => part_prod(11)(18), c_in => part_prod(12)(16), sum => sum_st2(78), c_out => carry_st2(78));
	
	add_num79_st2 : fa port map (in1 => part_prod(13)(14), in2 => part_prod(14)(12), c_in => part_prod(15)(10), sum => sum_st2(79), c_out => carry_st2(79));
	
	add_num80_st2 : fa port map (in1 => carry_st1(43), in2 => carry_st1(44), c_in => carry_st1(45), sum => sum_st2(80), c_out => carry_st2(80));
	
	add_num81_st2 : fa port map (in1 => sum_st1(46), in2 => sum_st1(47), c_in => part_prod(9)(23), sum => sum_st2(81), c_out => carry_st2(81));
	
	add_num82_st2 : fa port map (in1 => part_prod(10)(21), in2 => part_prod(11)(19), c_in => part_prod(12)(17), sum => sum_st2(82), c_out => carry_st2(82));
	
	add_num83_st2 : fa port map (in1 => part_prod(13)(15), in2 => part_prod(14)(13), c_in => part_prod(15)(11), sum => sum_st2(83), c_out => carry_st2(83));
	
	add_num84_st2 : fa port map (in1 => carry_st1(46), in2 => carry_st1(47), c_in => sum_st1(48), sum => sum_st2(84), c_out => carry_st2(84));
	
	add_num85_st2 : fa port map (in1 => sum_st1(49), in2 => part_prod(8)(26), c_in => part_prod(9)(24), sum => sum_st2(85), c_out => carry_st2(85));
	
	add_num86_st2 : fa port map (in1 => part_prod(10)(22), in2 => part_prod(11)(20), c_in => part_prod(12)(18), sum => sum_st2(86), c_out => carry_st2(86));
	
	add_num87_st2 : fa port map (in1 => part_prod(13)(16), in2 => part_prod(14)(14), c_in => part_prod(15)(12), sum => sum_st2(87), c_out => carry_st2(87));
	
	add_num88_st2 : fa port map (in1 => carry_st1(48), in2 => carry_st1(49), c_in => sum_st1(50), sum => sum_st2(88), c_out => carry_st2(88));
	
	add_num89_st2 : fa port map (in1 => part_prod(7)(29), in2 => part_prod(8)(27), c_in => part_prod(9)(25), sum => sum_st2(89), c_out => carry_st2(89));
	
	add_num90_st2 : fa port map (in1 => part_prod(10)(23), in2 => part_prod(11)(21), c_in => part_prod(12)(19), sum => sum_st2(90), c_out => carry_st2(90));
	
	add_num91_st2 : fa port map (in1 => part_prod(13)(17), in2 => part_prod(14)(15), c_in => part_prod(15)(13), sum => sum_st2(91), c_out => carry_st2(91));
	
	add_num92_st2 : fa port map (in1 => carry_st1(50), in2 => sum_st1(51), c_in => part_prod(6)(32), sum => sum_st2(92), c_out => carry_st2(92));
	
	add_num93_st2 : fa port map (in1 => part_prod(7)(30), in2 => part_prod(8)(28), c_in => part_prod(9)(26), sum => sum_st2(93), c_out => carry_st2(93));
	
	add_num94_st2 : fa port map (in1 => part_prod(10)(24), in2 => part_prod(11)(22), c_in => part_prod(12)(20), sum => sum_st2(94), c_out => carry_st2(94));
	
	add_num95_st2 : fa port map (in1 => part_prod(13)(18), in2 => part_prod(14)(16), c_in => part_prod(15)(14), sum => sum_st2(95), c_out => carry_st2(95));
	
	add_num96_st2 : fa port map (in1 => carry_st1(51), in2 => part_prod(5)(35), c_in => part_prod(6)(33), sum => sum_st2(96), c_out => carry_st2(96));
	
	add_num97_st2 : fa port map (in1 => part_prod(7)(31), in2 => part_prod(8)(29), c_in => part_prod(9)(27), sum => sum_st2(97), c_out => carry_st2(97));
	
	add_num98_st2 : fa port map (in1 => part_prod(10)(25), in2 => part_prod(11)(23), c_in => part_prod(12)(21), sum => sum_st2(98), c_out => carry_st2(98));
	
	add_num99_st2 : fa port map (in1 => part_prod(13)(19), in2 => part_prod(14)(17), c_in => part_prod(15)(15), sum => sum_st2(99), c_out => carry_st2(99));
	
	add_num100_st2 : fa port map (in1 => part_prod(5)(36), in2 => part_prod(6)(34), c_in => part_prod(7)(32), sum => sum_st2(100), c_out => carry_st2(100));
	
	add_num101_st2 : fa port map (in1 => part_prod(8)(30), in2 => part_prod(9)(28), c_in => part_prod(10)(26), sum => sum_st2(101), c_out => carry_st2(101));
	
	add_num102_st2 : fa port map (in1 => part_prod(11)(24), in2 => part_prod(12)(22), c_in => part_prod(13)(20), sum => sum_st2(102), c_out => carry_st2(102));
	
	add_num103_st2 : ha port map (in1 => part_prod(14)(18), in2 => part_prod(15)(16), sum => sum_st2(103), c_out => carry_st2(103));
	
	add_num104_st2 : fa port map (in1 => part_prod(6)(35), in2 => part_prod(7)(33), c_in => part_prod(8)(31), sum => sum_st2(104), c_out => carry_st2(104));
	
	add_num105_st2 : fa port map (in1 => part_prod(9)(29), in2 => part_prod(10)(27), c_in => part_prod(11)(25), sum => sum_st2(105), c_out => carry_st2(105));
	
	add_num106_st2 : fa port map (in1 => part_prod(12)(23), in2 => part_prod(13)(21), c_in => part_prod(14)(19), sum => sum_st2(106), c_out => carry_st2(106));
	
	add_num107_st2 : fa port map (in1 => part_prod(6)(36), in2 => part_prod(7)(34), c_in => part_prod(8)(32), sum => sum_st2(107), c_out => carry_st2(107));
	
	add_num108_st2 : fa port map (in1 => part_prod(9)(30), in2 => part_prod(10)(28), c_in => part_prod(11)(26), sum => sum_st2(108), c_out => carry_st2(108));
	
	add_num109_st2 : ha port map (in1 => part_prod(12)(24), in2 => part_prod(13)(22), sum => sum_st2(109), c_out => carry_st2(109));
	
	add_num110_st2 : fa port map (in1 => part_prod(7)(35), in2 => part_prod(8)(33), c_in => part_prod(9)(31), sum => sum_st2(110), c_out => carry_st2(110));
	
	add_num111_st2 : fa port map (in1 => part_prod(10)(29), in2 => part_prod(11)(27), c_in => part_prod(12)(25), sum => sum_st2(111), c_out => carry_st2(111));
	
	add_num112_st2 : fa port map (in1 => part_prod(7)(36), in2 => part_prod(8)(34), c_in => part_prod(9)(32), sum => sum_st2(112), c_out => carry_st2(112));
	
	add_num113_st2 : ha port map (in1 => part_prod(10)(30), in2 => part_prod(11)(28), sum => sum_st2(113), c_out => carry_st2(113));
	
	add_num114_st2 : fa port map (in1 => part_prod(8)(35), in2 => part_prod(9)(33), c_in => part_prod(10)(31), sum => sum_st2(114), c_out => carry_st2(114));
	
	add_num115_st2 : ha port map (in1 => part_prod(8)(36), in2 => part_prod(9)(34), sum => sum_st2(115), c_out => carry_st2(115));
	
	add_num0_st3 : ha port map (in1 => part_prod(0)(10), in2 => part_prod(1)(10), sum => sum_st3(0), c_out => carry_st3(0));
	
	add_num1_st3 : ha port map (in1 => part_prod(0)(11), in2 => part_prod(1)(11), sum => sum_st3(1), c_out => carry_st3(1));
	
	add_num2_st3 : fa port map (in1 => part_prod(0)(12), in2 => part_prod(1)(12), c_in => part_prod(2)(10), sum => sum_st3(2), c_out => carry_st3(2));
	
	add_num3_st3 : ha port map (in1 => part_prod(3)(8), in2 => part_prod(4)(6), sum => sum_st3(3), c_out => carry_st3(3));
	
	add_num4_st3 : fa port map (in1 => part_prod(0)(13), in2 => part_prod(1)(13), c_in => part_prod(2)(11), sum => sum_st3(4), c_out => carry_st3(4));
	
	add_num5_st3 : ha port map (in1 => part_prod(3)(9), in2 => part_prod(4)(7), sum => sum_st3(5), c_out => carry_st3(5));
	
	add_num6_st3 : fa port map (in1 => part_prod(0)(14), in2 => part_prod(1)(14), c_in => part_prod(2)(12), sum => sum_st3(6), c_out => carry_st3(6));
	
	add_num7_st3 : fa port map (in1 => part_prod(3)(10), in2 => part_prod(4)(8), c_in => part_prod(5)(6), sum => sum_st3(7), c_out => carry_st3(7));
	
	add_num8_st3 : ha port map (in1 => part_prod(6)(4), in2 => part_prod(7)(2), sum => sum_st3(8), c_out => carry_st3(8));
	
	add_num9_st3 : fa port map (in1 => part_prod(0)(15), in2 => part_prod(1)(15), c_in => part_prod(2)(13), sum => sum_st3(9), c_out => carry_st3(9));
	
	add_num10_st3 : fa port map (in1 => part_prod(3)(11), in2 => part_prod(4)(9), c_in => part_prod(5)(7), sum => sum_st3(10), c_out => carry_st3(10));
	
	add_num11_st3 : ha port map (in1 => part_prod(6)(5), in2 => part_prod(7)(3), sum => sum_st3(11), c_out => carry_st3(11));
	
	add_num12_st3 : fa port map (in1 => sum_st2(0), in2 => part_prod(2)(14), c_in => part_prod(3)(12), sum => sum_st3(12), c_out => carry_st3(12));
	
	add_num13_st3 : fa port map (in1 => part_prod(4)(10), in2 => part_prod(5)(8), c_in => part_prod(6)(6), sum => sum_st3(13), c_out => carry_st3(13));
	
	add_num14_st3 : fa port map (in1 => part_prod(7)(4), in2 => part_prod(8)(2), c_in => part_prod(9)(0), sum => sum_st3(14), c_out => carry_st3(14));
	
	add_num15_st3 : fa port map (in1 => carry_st2(0), in2 => sum_st2(1), c_in => part_prod(2)(15), sum => sum_st3(15), c_out => carry_st3(15));
	
	add_num16_st3 : fa port map (in1 => part_prod(3)(13), in2 => part_prod(4)(11), c_in => part_prod(5)(9), sum => sum_st3(16), c_out => carry_st3(16));
	
	add_num17_st3 : fa port map (in1 => part_prod(6)(7), in2 => part_prod(7)(5), c_in => part_prod(8)(3), sum => sum_st3(17), c_out => carry_st3(17));
	
	add_num18_st3 : fa port map (in1 => carry_st2(1), in2 => sum_st2(2), c_in => sum_st2(3), sum => sum_st3(18), c_out => carry_st3(18));
	
	add_num19_st3 : fa port map (in1 => part_prod(5)(10), in2 => part_prod(6)(8), c_in => part_prod(7)(6), sum => sum_st3(19), c_out => carry_st3(19));
	
	add_num20_st3 : fa port map (in1 => part_prod(8)(4), in2 => part_prod(9)(2), c_in => part_prod(10)(0), sum => sum_st3(20), c_out => carry_st3(20));
	
	add_num21_st3 : fa port map (in1 => carry_st2(2), in2 => carry_st2(3), c_in => sum_st2(4), sum => sum_st3(21), c_out => carry_st3(21));
	
	add_num22_st3 : fa port map (in1 => sum_st2(5), in2 => part_prod(5)(11), c_in => part_prod(6)(9), sum => sum_st3(22), c_out => carry_st3(22));
	
	add_num23_st3 : fa port map (in1 => part_prod(7)(7), in2 => part_prod(8)(5), c_in => part_prod(9)(3), sum => sum_st3(23), c_out => carry_st3(23));
	
	add_num24_st3 : fa port map (in1 => carry_st2(4), in2 => carry_st2(5), c_in => sum_st2(6), sum => sum_st3(24), c_out => carry_st3(24));
	
	add_num25_st3 : fa port map (in1 => sum_st2(7), in2 => sum_st2(8), c_in => part_prod(8)(6), sum => sum_st3(25), c_out => carry_st3(25));
	
	add_num26_st3 : fa port map (in1 => part_prod(9)(4), in2 => part_prod(10)(2), c_in => part_prod(11)(0), sum => sum_st3(26), c_out => carry_st3(26));
	
	add_num27_st3 : fa port map (in1 => carry_st2(6), in2 => carry_st2(7), c_in => carry_st2(8), sum => sum_st3(27), c_out => carry_st3(27));
	
	add_num28_st3 : fa port map (in1 => sum_st2(9), in2 => sum_st2(10), c_in => sum_st2(11), sum => sum_st3(28), c_out => carry_st3(28));
	
	add_num29_st3 : fa port map (in1 => part_prod(8)(7), in2 => part_prod(9)(5), c_in => part_prod(10)(3), sum => sum_st3(29), c_out => carry_st3(29));
	
	add_num30_st3 : fa port map (in1 => carry_st2(9), in2 => carry_st2(10), c_in => carry_st2(11), sum => sum_st3(30), c_out => carry_st3(30));
	
	add_num31_st3 : fa port map (in1 => sum_st2(12), in2 => sum_st2(13), c_in => sum_st2(14), sum => sum_st3(31), c_out => carry_st3(31));
	
	add_num32_st3 : fa port map (in1 => sum_st2(15), in2 => part_prod(11)(2), c_in => part_prod(12)(0), sum => sum_st3(32), c_out => carry_st3(32));
	
	add_num33_st3 : fa port map (in1 => carry_st2(12), in2 => carry_st2(13), c_in => carry_st2(14), sum => sum_st3(33), c_out => carry_st3(33));
	
	add_num34_st3 : fa port map (in1 => carry_st2(15), in2 => sum_st2(16), c_in => sum_st2(17), sum => sum_st3(34), c_out => carry_st3(34));
	
	add_num35_st3 : fa port map (in1 => sum_st2(18), in2 => sum_st2(19), c_in => part_prod(11)(3), sum => sum_st3(35), c_out => carry_st3(35));
	
	add_num36_st3 : fa port map (in1 => carry_st2(16), in2 => carry_st2(17), c_in => carry_st2(18), sum => sum_st3(36), c_out => carry_st3(36));
	
	add_num37_st3 : fa port map (in1 => carry_st2(19), in2 => sum_st2(20), c_in => sum_st2(21), sum => sum_st3(37), c_out => carry_st3(37));
	
	add_num38_st3 : fa port map (in1 => sum_st2(22), in2 => sum_st2(23), c_in => part_prod(13)(0), sum => sum_st3(38), c_out => carry_st3(38));
	
	add_num39_st3 : fa port map (in1 => carry_st2(20), in2 => carry_st2(21), c_in => carry_st2(22), sum => sum_st3(39), c_out => carry_st3(39));
	
	add_num40_st3 : fa port map (in1 => carry_st2(23), in2 => sum_st2(24), c_in => sum_st2(25), sum => sum_st3(40), c_out => carry_st3(40));
	
	add_num41_st3 : fa port map (in1 => sum_st2(26), in2 => sum_st2(27), c_in => part_prod(12)(3), sum => sum_st3(41), c_out => carry_st3(41));
	
	add_num42_st3 : fa port map (in1 => carry_st2(24), in2 => carry_st2(25), c_in => carry_st2(26), sum => sum_st3(42), c_out => carry_st3(42));
	
	add_num43_st3 : fa port map (in1 => carry_st2(27), in2 => sum_st2(28), c_in => sum_st2(29), sum => sum_st3(43), c_out => carry_st3(43));
	
	add_num44_st3 : fa port map (in1 => sum_st2(30), in2 => sum_st2(31), c_in => part_prod(14)(0), sum => sum_st3(44), c_out => carry_st3(44));
	
	add_num45_st3 : fa port map (in1 => carry_st2(28), in2 => carry_st2(29), c_in => carry_st2(30), sum => sum_st3(45), c_out => carry_st3(45));
	
	add_num46_st3 : fa port map (in1 => carry_st2(31), in2 => sum_st2(32), c_in => sum_st2(33), sum => sum_st3(46), c_out => carry_st3(46));
	
	add_num47_st3 : fa port map (in1 => sum_st2(34), in2 => sum_st2(35), c_in => part_prod(13)(3), sum => sum_st3(47), c_out => carry_st3(47));
	
	add_num48_st3 : fa port map (in1 => carry_st2(32), in2 => carry_st2(33), c_in => carry_st2(34), sum => sum_st3(48), c_out => carry_st3(48));
	
	add_num49_st3 : fa port map (in1 => carry_st2(35), in2 => sum_st2(36), c_in => sum_st2(37), sum => sum_st3(49), c_out => carry_st3(49));
	
	add_num50_st3 : fa port map (in1 => sum_st2(38), in2 => sum_st2(39), c_in => part_prod(15)(0), sum => sum_st3(50), c_out => carry_st3(50));
	
	add_num51_st3 : fa port map (in1 => carry_st2(36), in2 => carry_st2(37), c_in => carry_st2(38), sum => sum_st3(51), c_out => carry_st3(51));
	
	add_num52_st3 : fa port map (in1 => carry_st2(39), in2 => sum_st2(40), c_in => sum_st2(41), sum => sum_st3(52), c_out => carry_st3(52));
	
	add_num53_st3 : fa port map (in1 => sum_st2(42), in2 => sum_st2(43), c_in => part_prod(14)(3), sum => sum_st3(53), c_out => carry_st3(53));
	
	add_num54_st3 : fa port map (in1 => carry_st2(40), in2 => carry_st2(41), c_in => carry_st2(42), sum => sum_st3(54), c_out => carry_st3(54));
	
	add_num55_st3 : fa port map (in1 => carry_st2(43), in2 => sum_st2(44), c_in => sum_st2(45), sum => sum_st3(55), c_out => carry_st3(55));
	
	add_num56_st3 : fa port map (in1 => sum_st2(46), in2 => sum_st2(47), c_in => part_prod(16)(0), sum => sum_st3(56), c_out => carry_st3(56));
	
	add_num57_st3 : fa port map (in1 => carry_st2(44), in2 => carry_st2(45), c_in => carry_st2(46), sum => sum_st3(57), c_out => carry_st3(57));
	
	add_num58_st3 : fa port map (in1 => carry_st2(47), in2 => sum_st2(48), c_in => sum_st2(49), sum => sum_st3(58), c_out => carry_st3(58));
	
	add_num59_st3 : fa port map (in1 => sum_st2(50), in2 => sum_st2(51), c_in => part_prod(15)(3), sum => sum_st3(59), c_out => carry_st3(59));
	
	add_num60_st3 : fa port map (in1 => carry_st2(48), in2 => carry_st2(49), c_in => carry_st2(50), sum => sum_st3(60), c_out => carry_st3(60));
	
	add_num61_st3 : fa port map (in1 => carry_st2(51), in2 => sum_st2(52), c_in => sum_st2(53), sum => sum_st3(61), c_out => carry_st3(61));
	
	add_num62_st3 : fa port map (in1 => sum_st2(54), in2 => sum_st2(55), c_in => part_prod(16)(2), sum => sum_st3(62), c_out => carry_st3(62));
	
	add_num63_st3 : fa port map (in1 => carry_st2(52), in2 => carry_st2(53), c_in => carry_st2(54), sum => sum_st3(63), c_out => carry_st3(63));
	
	add_num64_st3 : fa port map (in1 => carry_st2(55), in2 => sum_st2(56), c_in => sum_st2(57), sum => sum_st3(64), c_out => carry_st3(64));
	
	add_num65_st3 : fa port map (in1 => sum_st2(58), in2 => sum_st2(59), c_in => part_prod(16)(3), sum => sum_st3(65), c_out => carry_st3(65));
	
	add_num66_st3 : fa port map (in1 => carry_st2(56), in2 => carry_st2(57), c_in => carry_st2(58), sum => sum_st3(66), c_out => carry_st3(66));
	
	add_num67_st3 : fa port map (in1 => carry_st2(59), in2 => sum_st2(60), c_in => sum_st2(61), sum => sum_st3(67), c_out => carry_st3(67));
	
	add_num68_st3 : fa port map (in1 => sum_st2(62), in2 => sum_st2(63), c_in => part_prod(16)(4), sum => sum_st3(68), c_out => carry_st3(68));
	
	add_num69_st3 : fa port map (in1 => carry_st2(60), in2 => carry_st2(61), c_in => carry_st2(62), sum => sum_st3(69), c_out => carry_st3(69));
	
	add_num70_st3 : fa port map (in1 => carry_st2(63), in2 => sum_st2(64), c_in => sum_st2(65), sum => sum_st3(70), c_out => carry_st3(70));
	
	add_num71_st3 : fa port map (in1 => sum_st2(66), in2 => sum_st2(67), c_in => part_prod(16)(5), sum => sum_st3(71), c_out => carry_st3(71));
	
	add_num72_st3 : fa port map (in1 => carry_st2(64), in2 => carry_st2(65), c_in => carry_st2(66), sum => sum_st3(72), c_out => carry_st3(72));
	
	add_num73_st3 : fa port map (in1 => carry_st2(67), in2 => sum_st2(68), c_in => sum_st2(69), sum => sum_st3(73), c_out => carry_st3(73));
	
	add_num74_st3 : fa port map (in1 => sum_st2(70), in2 => sum_st2(71), c_in => part_prod(16)(6), sum => sum_st3(74), c_out => carry_st3(74));
	
	add_num75_st3 : fa port map (in1 => carry_st2(68), in2 => carry_st2(69), c_in => carry_st2(70), sum => sum_st3(75), c_out => carry_st3(75));
	
	add_num76_st3 : fa port map (in1 => carry_st2(71), in2 => sum_st2(72), c_in => sum_st2(73), sum => sum_st3(76), c_out => carry_st3(76));
	
	add_num77_st3 : fa port map (in1 => sum_st2(74), in2 => sum_st2(75), c_in => part_prod(16)(7), sum => sum_st3(77), c_out => carry_st3(77));
	
	add_num78_st3 : fa port map (in1 => carry_st2(72), in2 => carry_st2(73), c_in => carry_st2(74), sum => sum_st3(78), c_out => carry_st3(78));
	
	add_num79_st3 : fa port map (in1 => carry_st2(75), in2 => sum_st2(76), c_in => sum_st2(77), sum => sum_st3(79), c_out => carry_st3(79));
	
	add_num80_st3 : fa port map (in1 => sum_st2(78), in2 => sum_st2(79), c_in => part_prod(16)(8), sum => sum_st3(80), c_out => carry_st3(80));
	
	add_num81_st3 : fa port map (in1 => carry_st2(76), in2 => carry_st2(77), c_in => carry_st2(78), sum => sum_st3(81), c_out => carry_st3(81));
	
	add_num82_st3 : fa port map (in1 => carry_st2(79), in2 => sum_st2(80), c_in => sum_st2(81), sum => sum_st3(82), c_out => carry_st3(82));
	
	add_num83_st3 : fa port map (in1 => sum_st2(82), in2 => sum_st2(83), c_in => part_prod(16)(9), sum => sum_st3(83), c_out => carry_st3(83));
	
	add_num84_st3 : fa port map (in1 => carry_st2(80), in2 => carry_st2(81), c_in => carry_st2(82), sum => sum_st3(84), c_out => carry_st3(84));
	
	add_num85_st3 : fa port map (in1 => carry_st2(83), in2 => sum_st2(84), c_in => sum_st2(85), sum => sum_st3(85), c_out => carry_st3(85));
	
	add_num86_st3 : fa port map (in1 => sum_st2(86), in2 => sum_st2(87), c_in => part_prod(16)(10), sum => sum_st3(86), c_out => carry_st3(86));
	
	add_num87_st3 : fa port map (in1 => carry_st2(84), in2 => carry_st2(85), c_in => carry_st2(86), sum => sum_st3(87), c_out => carry_st3(87));
	
	add_num88_st3 : fa port map (in1 => carry_st2(87), in2 => sum_st2(88), c_in => sum_st2(89), sum => sum_st3(88), c_out => carry_st3(88));
	
	add_num89_st3 : fa port map (in1 => sum_st2(90), in2 => sum_st2(91), c_in => part_prod(16)(11), sum => sum_st3(89), c_out => carry_st3(89));
	
	add_num90_st3 : fa port map (in1 => carry_st2(88), in2 => carry_st2(89), c_in => carry_st2(90), sum => sum_st3(90), c_out => carry_st3(90));
	
	add_num91_st3 : fa port map (in1 => carry_st2(91), in2 => sum_st2(92), c_in => sum_st2(93), sum => sum_st3(91), c_out => carry_st3(91));
	
	add_num92_st3 : fa port map (in1 => sum_st2(94), in2 => sum_st2(95), c_in => part_prod(16)(12), sum => sum_st3(92), c_out => carry_st3(92));
	
	add_num93_st3 : fa port map (in1 => carry_st2(92), in2 => carry_st2(93), c_in => carry_st2(94), sum => sum_st3(93), c_out => carry_st3(93));
	
	add_num94_st3 : fa port map (in1 => carry_st2(95), in2 => sum_st2(96), c_in => sum_st2(97), sum => sum_st3(94), c_out => carry_st3(94));
	
	add_num95_st3 : fa port map (in1 => sum_st2(98), in2 => sum_st2(99), c_in => part_prod(16)(13), sum => sum_st3(95), c_out => carry_st3(95));
	
	add_num96_st3 : fa port map (in1 => carry_st2(96), in2 => carry_st2(97), c_in => carry_st2(98), sum => sum_st3(96), c_out => carry_st3(96));
	
	add_num97_st3 : fa port map (in1 => carry_st2(99), in2 => sum_st2(100), c_in => sum_st2(101), sum => sum_st3(97), c_out => carry_st3(97));
	
	add_num98_st3 : fa port map (in1 => sum_st2(102), in2 => sum_st2(103), c_in => part_prod(16)(14), sum => sum_st3(98), c_out => carry_st3(98));
	
	add_num99_st3 : fa port map (in1 => carry_st2(100), in2 => carry_st2(101), c_in => carry_st2(102), sum => sum_st3(99), c_out => carry_st3(99));
	
	add_num100_st3 : fa port map (in1 => carry_st2(103), in2 => sum_st2(104), c_in => sum_st2(105), sum => sum_st3(100), c_out => carry_st3(100));
	
	add_num101_st3 : fa port map (in1 => sum_st2(106), in2 => part_prod(15)(17), c_in => part_prod(16)(15), sum => sum_st3(101), c_out => carry_st3(101));
	
	add_num102_st3 : fa port map (in1 => carry_st2(104), in2 => carry_st2(105), c_in => carry_st2(106), sum => sum_st3(102), c_out => carry_st3(102));
	
	add_num103_st3 : fa port map (in1 => sum_st2(107), in2 => sum_st2(108), c_in => sum_st2(109), sum => sum_st3(103), c_out => carry_st3(103));
	
	add_num104_st3 : fa port map (in1 => part_prod(14)(20), in2 => part_prod(15)(18), c_in => part_prod(16)(16), sum => sum_st3(104), c_out => carry_st3(104));
	
	add_num105_st3 : fa port map (in1 => carry_st2(107), in2 => carry_st2(108), c_in => carry_st2(109), sum => sum_st3(105), c_out => carry_st3(105));
	
	add_num106_st3 : fa port map (in1 => sum_st2(110), in2 => sum_st2(111), c_in => part_prod(13)(23), sum => sum_st3(106), c_out => carry_st3(106));
	
	add_num107_st3 : fa port map (in1 => part_prod(14)(21), in2 => part_prod(15)(19), c_in => part_prod(16)(17), sum => sum_st3(107), c_out => carry_st3(107));
	
	add_num108_st3 : fa port map (in1 => carry_st2(110), in2 => carry_st2(111), c_in => sum_st2(112), sum => sum_st3(108), c_out => carry_st3(108));
	
	add_num109_st3 : fa port map (in1 => sum_st2(113), in2 => part_prod(12)(26), c_in => part_prod(13)(24), sum => sum_st3(109), c_out => carry_st3(109));
	
	add_num110_st3 : fa port map (in1 => part_prod(14)(22), in2 => part_prod(15)(20), c_in => part_prod(16)(18), sum => sum_st3(110), c_out => carry_st3(110));
	
	add_num111_st3 : fa port map (in1 => carry_st2(112), in2 => carry_st2(113), c_in => sum_st2(114), sum => sum_st3(111), c_out => carry_st3(111));
	
	add_num112_st3 : fa port map (in1 => part_prod(11)(29), in2 => part_prod(12)(27), c_in => part_prod(13)(25), sum => sum_st3(112), c_out => carry_st3(112));
	
	add_num113_st3 : fa port map (in1 => part_prod(14)(23), in2 => part_prod(15)(21), c_in => part_prod(16)(19), sum => sum_st3(113), c_out => carry_st3(113));
	
	add_num114_st3 : fa port map (in1 => carry_st2(114), in2 => sum_st2(115), c_in => part_prod(10)(32), sum => sum_st3(114), c_out => carry_st3(114));
	
	add_num115_st3 : fa port map (in1 => part_prod(11)(30), in2 => part_prod(12)(28), c_in => part_prod(13)(26), sum => sum_st3(115), c_out => carry_st3(115));
	
	add_num116_st3 : fa port map (in1 => part_prod(14)(24), in2 => part_prod(15)(22), c_in => part_prod(16)(20), sum => sum_st3(116), c_out => carry_st3(116));
	
	add_num117_st3 : fa port map (in1 => carry_st2(115), in2 => part_prod(9)(35), c_in => part_prod(10)(33), sum => sum_st3(117), c_out => carry_st3(117));
	
	add_num118_st3 : fa port map (in1 => part_prod(11)(31), in2 => part_prod(12)(29), c_in => part_prod(13)(27), sum => sum_st3(118), c_out => carry_st3(118));
	
	add_num119_st3 : fa port map (in1 => part_prod(14)(25), in2 => part_prod(15)(23), c_in => part_prod(16)(21), sum => sum_st3(119), c_out => carry_st3(119));
	
	add_num120_st3 : fa port map (in1 => part_prod(9)(36), in2 => part_prod(10)(34), c_in => part_prod(11)(32), sum => sum_st3(120), c_out => carry_st3(120));
	
	add_num121_st3 : fa port map (in1 => part_prod(12)(30), in2 => part_prod(13)(28), c_in => part_prod(14)(26), sum => sum_st3(121), c_out => carry_st3(121));
	
	add_num122_st3 : ha port map (in1 => part_prod(15)(24), in2 => part_prod(16)(22), sum => sum_st3(122), c_out => carry_st3(122));
	
	add_num123_st3 : fa port map (in1 => part_prod(10)(35), in2 => part_prod(11)(33), c_in => part_prod(12)(31), sum => sum_st3(123), c_out => carry_st3(123));
	
	add_num124_st3 : fa port map (in1 => part_prod(13)(29), in2 => part_prod(14)(27), c_in => part_prod(15)(25), sum => sum_st3(124), c_out => carry_st3(124));
	
	add_num125_st3 : fa port map (in1 => part_prod(10)(36), in2 => part_prod(11)(34), c_in => part_prod(12)(32), sum => sum_st3(125), c_out => carry_st3(125));
	
	add_num126_st3 : ha port map (in1 => part_prod(13)(30), in2 => part_prod(14)(28), sum => sum_st3(126), c_out => carry_st3(126));
	
	add_num127_st3 : fa port map (in1 => part_prod(11)(35), in2 => part_prod(12)(33), c_in => part_prod(13)(31), sum => sum_st3(127), c_out => carry_st3(127));
	
	add_num128_st3 : ha port map (in1 => part_prod(11)(36), in2 => part_prod(12)(34), sum => sum_st3(128), c_out => carry_st3(128));
	
	add_num0_st4 : ha port map (in1 => part_prod(0)(6), in2 => part_prod(1)(6), sum => sum_st4(0), c_out => carry_st4(0));
	
	add_num1_st4 : ha port map (in1 => part_prod(0)(7), in2 => part_prod(1)(7), sum => sum_st4(1), c_out => carry_st4(1));
	
	add_num2_st4 : fa port map (in1 => part_prod(0)(8), in2 => part_prod(1)(8), c_in => part_prod(2)(6), sum => sum_st4(2), c_out => carry_st4(2));
	
	add_num3_st4 : ha port map (in1 => part_prod(3)(4), in2 => part_prod(4)(2), sum => sum_st4(3), c_out => carry_st4(3));
	
	add_num4_st4 : fa port map (in1 => part_prod(0)(9), in2 => part_prod(1)(9), c_in => part_prod(2)(7), sum => sum_st4(4), c_out => carry_st4(4));
	
	add_num5_st4 : ha port map (in1 => part_prod(3)(5), in2 => part_prod(4)(3), sum => sum_st4(5), c_out => carry_st4(5));
	
	add_num6_st4 : fa port map (in1 => sum_st3(0), in2 => part_prod(2)(8), c_in => part_prod(3)(6), sum => sum_st4(6), c_out => carry_st4(6));
	
	add_num7_st4 : fa port map (in1 => part_prod(4)(4), in2 => part_prod(5)(2), c_in => part_prod(6)(0), sum => sum_st4(7), c_out => carry_st4(7));
	
	add_num8_st4 : fa port map (in1 => carry_st3(0), in2 => sum_st3(1), c_in => part_prod(2)(9), sum => sum_st4(8), c_out => carry_st4(8));
	
	add_num9_st4 : fa port map (in1 => part_prod(3)(7), in2 => part_prod(4)(5), c_in => part_prod(5)(3), sum => sum_st4(9), c_out => carry_st4(9));
	
	add_num10_st4 : fa port map (in1 => carry_st3(1), in2 => sum_st3(2), c_in => sum_st3(3), sum => sum_st4(10), c_out => carry_st4(10));
	
	add_num11_st4 : fa port map (in1 => part_prod(5)(4), in2 => part_prod(6)(2), c_in => part_prod(7)(0), sum => sum_st4(11), c_out => carry_st4(11));
	
	add_num12_st4 : fa port map (in1 => carry_st3(2), in2 => carry_st3(3), c_in => sum_st3(4), sum => sum_st4(12), c_out => carry_st4(12));
	
	add_num13_st4 : fa port map (in1 => sum_st3(5), in2 => part_prod(5)(5), c_in => part_prod(6)(3), sum => sum_st4(13), c_out => carry_st4(13));
	
	add_num14_st4 : fa port map (in1 => carry_st3(4), in2 => carry_st3(5), c_in => sum_st3(6), sum => sum_st4(14), c_out => carry_st4(14));
	
	add_num15_st4 : fa port map (in1 => sum_st3(7), in2 => sum_st3(8), c_in => part_prod(8)(0), sum => sum_st4(15), c_out => carry_st4(15));
	
	add_num16_st4 : fa port map (in1 => carry_st3(6), in2 => carry_st3(7), c_in => carry_st3(8), sum => sum_st4(16), c_out => carry_st4(16));
	
	add_num17_st4 : fa port map (in1 => sum_st3(9), in2 => sum_st3(10), c_in => sum_st3(11), sum => sum_st4(17), c_out => carry_st4(17));
	
	add_num18_st4 : fa port map (in1 => carry_st3(9), in2 => carry_st3(10), c_in => carry_st3(11), sum => sum_st4(18), c_out => carry_st4(18));
	
	add_num19_st4 : fa port map (in1 => sum_st3(12), in2 => sum_st3(13), c_in => sum_st3(14), sum => sum_st4(19), c_out => carry_st4(19));
	
	add_num20_st4 : fa port map (in1 => carry_st3(12), in2 => carry_st3(13), c_in => carry_st3(14), sum => sum_st4(20), c_out => carry_st4(20));
	
	add_num21_st4 : fa port map (in1 => sum_st3(15), in2 => sum_st3(16), c_in => sum_st3(17), sum => sum_st4(21), c_out => carry_st4(21));
	
	add_num22_st4 : fa port map (in1 => carry_st3(15), in2 => carry_st3(16), c_in => carry_st3(17), sum => sum_st4(22), c_out => carry_st4(22));
	
	add_num23_st4 : fa port map (in1 => sum_st3(18), in2 => sum_st3(19), c_in => sum_st3(20), sum => sum_st4(23), c_out => carry_st4(23));
	
	add_num24_st4 : fa port map (in1 => carry_st3(18), in2 => carry_st3(19), c_in => carry_st3(20), sum => sum_st4(24), c_out => carry_st4(24));
	
	add_num25_st4 : fa port map (in1 => sum_st3(21), in2 => sum_st3(22), c_in => sum_st3(23), sum => sum_st4(25), c_out => carry_st4(25));
	
	add_num26_st4 : fa port map (in1 => carry_st3(21), in2 => carry_st3(22), c_in => carry_st3(23), sum => sum_st4(26), c_out => carry_st4(26));
	
	add_num27_st4 : fa port map (in1 => sum_st3(24), in2 => sum_st3(25), c_in => sum_st3(26), sum => sum_st4(27), c_out => carry_st4(27));
	
	add_num28_st4 : fa port map (in1 => carry_st3(24), in2 => carry_st3(25), c_in => carry_st3(26), sum => sum_st4(28), c_out => carry_st4(28));
	
	add_num29_st4 : fa port map (in1 => sum_st3(27), in2 => sum_st3(28), c_in => sum_st3(29), sum => sum_st4(29), c_out => carry_st4(29));
	
	add_num30_st4 : fa port map (in1 => carry_st3(27), in2 => carry_st3(28), c_in => carry_st3(29), sum => sum_st4(30), c_out => carry_st4(30));
	
	add_num31_st4 : fa port map (in1 => sum_st3(30), in2 => sum_st3(31), c_in => sum_st3(32), sum => sum_st4(31), c_out => carry_st4(31));
	
	add_num32_st4 : fa port map (in1 => carry_st3(30), in2 => carry_st3(31), c_in => carry_st3(32), sum => sum_st4(32), c_out => carry_st4(32));
	
	add_num33_st4 : fa port map (in1 => sum_st3(33), in2 => sum_st3(34), c_in => sum_st3(35), sum => sum_st4(33), c_out => carry_st4(33));
	
	add_num34_st4 : fa port map (in1 => carry_st3(33), in2 => carry_st3(34), c_in => carry_st3(35), sum => sum_st4(34), c_out => carry_st4(34));
	
	add_num35_st4 : fa port map (in1 => sum_st3(36), in2 => sum_st3(37), c_in => sum_st3(38), sum => sum_st4(35), c_out => carry_st4(35));
	
	add_num36_st4 : fa port map (in1 => carry_st3(36), in2 => carry_st3(37), c_in => carry_st3(38), sum => sum_st4(36), c_out => carry_st4(36));
	
	add_num37_st4 : fa port map (in1 => sum_st3(39), in2 => sum_st3(40), c_in => sum_st3(41), sum => sum_st4(37), c_out => carry_st4(37));
	
	add_num38_st4 : fa port map (in1 => carry_st3(39), in2 => carry_st3(40), c_in => carry_st3(41), sum => sum_st4(38), c_out => carry_st4(38));
	
	add_num39_st4 : fa port map (in1 => sum_st3(42), in2 => sum_st3(43), c_in => sum_st3(44), sum => sum_st4(39), c_out => carry_st4(39));
	
	add_num40_st4 : fa port map (in1 => carry_st3(42), in2 => carry_st3(43), c_in => carry_st3(44), sum => sum_st4(40), c_out => carry_st4(40));
	
	add_num41_st4 : fa port map (in1 => sum_st3(45), in2 => sum_st3(46), c_in => sum_st3(47), sum => sum_st4(41), c_out => carry_st4(41));
	
	add_num42_st4 : fa port map (in1 => carry_st3(45), in2 => carry_st3(46), c_in => carry_st3(47), sum => sum_st4(42), c_out => carry_st4(42));
	
	add_num43_st4 : fa port map (in1 => sum_st3(48), in2 => sum_st3(49), c_in => sum_st3(50), sum => sum_st4(43), c_out => carry_st4(43));
	
	add_num44_st4 : fa port map (in1 => carry_st3(48), in2 => carry_st3(49), c_in => carry_st3(50), sum => sum_st4(44), c_out => carry_st4(44));
	
	add_num45_st4 : fa port map (in1 => sum_st3(51), in2 => sum_st3(52), c_in => sum_st3(53), sum => sum_st4(45), c_out => carry_st4(45));
	
	add_num46_st4 : fa port map (in1 => carry_st3(51), in2 => carry_st3(52), c_in => carry_st3(53), sum => sum_st4(46), c_out => carry_st4(46));
	
	add_num47_st4 : fa port map (in1 => sum_st3(54), in2 => sum_st3(55), c_in => sum_st3(56), sum => sum_st4(47), c_out => carry_st4(47));
	
	add_num48_st4 : fa port map (in1 => carry_st3(54), in2 => carry_st3(55), c_in => carry_st3(56), sum => sum_st4(48), c_out => carry_st4(48));
	
	add_num49_st4 : fa port map (in1 => sum_st3(57), in2 => sum_st3(58), c_in => sum_st3(59), sum => sum_st4(49), c_out => carry_st4(49));
	
	add_num50_st4 : fa port map (in1 => carry_st3(57), in2 => carry_st3(58), c_in => carry_st3(59), sum => sum_st4(50), c_out => carry_st4(50));
	
	add_num51_st4 : fa port map (in1 => sum_st3(60), in2 => sum_st3(61), c_in => sum_st3(62), sum => sum_st4(51), c_out => carry_st4(51));
	
	add_num52_st4 : fa port map (in1 => carry_st3(60), in2 => carry_st3(61), c_in => carry_st3(62), sum => sum_st4(52), c_out => carry_st4(52));
	
	add_num53_st4 : fa port map (in1 => sum_st3(63), in2 => sum_st3(64), c_in => sum_st3(65), sum => sum_st4(53), c_out => carry_st4(53));
	
	add_num54_st4 : fa port map (in1 => carry_st3(63), in2 => carry_st3(64), c_in => carry_st3(65), sum => sum_st4(54), c_out => carry_st4(54));
	
	add_num55_st4 : fa port map (in1 => sum_st3(66), in2 => sum_st3(67), c_in => sum_st3(68), sum => sum_st4(55), c_out => carry_st4(55));
	
	add_num56_st4 : fa port map (in1 => carry_st3(66), in2 => carry_st3(67), c_in => carry_st3(68), sum => sum_st4(56), c_out => carry_st4(56));
	
	add_num57_st4 : fa port map (in1 => sum_st3(69), in2 => sum_st3(70), c_in => sum_st3(71), sum => sum_st4(57), c_out => carry_st4(57));
	
	add_num58_st4 : fa port map (in1 => carry_st3(69), in2 => carry_st3(70), c_in => carry_st3(71), sum => sum_st4(58), c_out => carry_st4(58));
	
	add_num59_st4 : fa port map (in1 => sum_st3(72), in2 => sum_st3(73), c_in => sum_st3(74), sum => sum_st4(59), c_out => carry_st4(59));
	
	add_num60_st4 : fa port map (in1 => carry_st3(72), in2 => carry_st3(73), c_in => carry_st3(74), sum => sum_st4(60), c_out => carry_st4(60));
	
	add_num61_st4 : fa port map (in1 => sum_st3(75), in2 => sum_st3(76), c_in => sum_st3(77), sum => sum_st4(61), c_out => carry_st4(61));
	
	add_num62_st4 : fa port map (in1 => carry_st3(75), in2 => carry_st3(76), c_in => carry_st3(77), sum => sum_st4(62), c_out => carry_st4(62));
	
	add_num63_st4 : fa port map (in1 => sum_st3(78), in2 => sum_st3(79), c_in => sum_st3(80), sum => sum_st4(63), c_out => carry_st4(63));
	
	add_num64_st4 : fa port map (in1 => carry_st3(78), in2 => carry_st3(79), c_in => carry_st3(80), sum => sum_st4(64), c_out => carry_st4(64));
	
	add_num65_st4 : fa port map (in1 => sum_st3(81), in2 => sum_st3(82), c_in => sum_st3(83), sum => sum_st4(65), c_out => carry_st4(65));
	
	add_num66_st4 : fa port map (in1 => carry_st3(81), in2 => carry_st3(82), c_in => carry_st3(83), sum => sum_st4(66), c_out => carry_st4(66));
	
	add_num67_st4 : fa port map (in1 => sum_st3(84), in2 => sum_st3(85), c_in => sum_st3(86), sum => sum_st4(67), c_out => carry_st4(67));
	
	add_num68_st4 : fa port map (in1 => carry_st3(84), in2 => carry_st3(85), c_in => carry_st3(86), sum => sum_st4(68), c_out => carry_st4(68));
	
	add_num69_st4 : fa port map (in1 => sum_st3(87), in2 => sum_st3(88), c_in => sum_st3(89), sum => sum_st4(69), c_out => carry_st4(69));
	
	add_num70_st4 : fa port map (in1 => carry_st3(87), in2 => carry_st3(88), c_in => carry_st3(89), sum => sum_st4(70), c_out => carry_st4(70));
	
	add_num71_st4 : fa port map (in1 => sum_st3(90), in2 => sum_st3(91), c_in => sum_st3(92), sum => sum_st4(71), c_out => carry_st4(71));
	
	add_num72_st4 : fa port map (in1 => carry_st3(90), in2 => carry_st3(91), c_in => carry_st3(92), sum => sum_st4(72), c_out => carry_st4(72));
	
	add_num73_st4 : fa port map (in1 => sum_st3(93), in2 => sum_st3(94), c_in => sum_st3(95), sum => sum_st4(73), c_out => carry_st4(73));
	
	add_num74_st4 : fa port map (in1 => carry_st3(93), in2 => carry_st3(94), c_in => carry_st3(95), sum => sum_st4(74), c_out => carry_st4(74));
	
	add_num75_st4 : fa port map (in1 => sum_st3(96), in2 => sum_st3(97), c_in => sum_st3(98), sum => sum_st4(75), c_out => carry_st4(75));
	
	add_num76_st4 : fa port map (in1 => carry_st3(96), in2 => carry_st3(97), c_in => carry_st3(98), sum => sum_st4(76), c_out => carry_st4(76));
	
	add_num77_st4 : fa port map (in1 => sum_st3(99), in2 => sum_st3(100), c_in => sum_st3(101), sum => sum_st4(77), c_out => carry_st4(77));
	
	add_num78_st4 : fa port map (in1 => carry_st3(99), in2 => carry_st3(100), c_in => carry_st3(101), sum => sum_st4(78), c_out => carry_st4(78));
	
	add_num79_st4 : fa port map (in1 => sum_st3(102), in2 => sum_st3(103), c_in => sum_st3(104), sum => sum_st4(79), c_out => carry_st4(79));
	
	add_num80_st4 : fa port map (in1 => carry_st3(102), in2 => carry_st3(103), c_in => carry_st3(104), sum => sum_st4(80), c_out => carry_st4(80));
	
	add_num81_st4 : fa port map (in1 => sum_st3(105), in2 => sum_st3(106), c_in => sum_st3(107), sum => sum_st4(81), c_out => carry_st4(81));
	
	add_num82_st4 : fa port map (in1 => carry_st3(105), in2 => carry_st3(106), c_in => carry_st3(107), sum => sum_st4(82), c_out => carry_st4(82));
	
	add_num83_st4 : fa port map (in1 => sum_st3(108), in2 => sum_st3(109), c_in => sum_st3(110), sum => sum_st4(83), c_out => carry_st4(83));
	
	add_num84_st4 : fa port map (in1 => carry_st3(108), in2 => carry_st3(109), c_in => carry_st3(110), sum => sum_st4(84), c_out => carry_st4(84));
	
	add_num85_st4 : fa port map (in1 => sum_st3(111), in2 => sum_st3(112), c_in => sum_st3(113), sum => sum_st4(85), c_out => carry_st4(85));
	
	add_num86_st4 : fa port map (in1 => carry_st3(111), in2 => carry_st3(112), c_in => carry_st3(113), sum => sum_st4(86), c_out => carry_st4(86));
	
	add_num87_st4 : fa port map (in1 => sum_st3(114), in2 => sum_st3(115), c_in => sum_st3(116), sum => sum_st4(87), c_out => carry_st4(87));
	
	add_num88_st4 : fa port map (in1 => carry_st3(114), in2 => carry_st3(115), c_in => carry_st3(116), sum => sum_st4(88), c_out => carry_st4(88));
	
	add_num89_st4 : fa port map (in1 => sum_st3(117), in2 => sum_st3(118), c_in => sum_st3(119), sum => sum_st4(89), c_out => carry_st4(89));
	
	add_num90_st4 : fa port map (in1 => carry_st3(117), in2 => carry_st3(118), c_in => carry_st3(119), sum => sum_st4(90), c_out => carry_st4(90));
	
	add_num91_st4 : fa port map (in1 => sum_st3(120), in2 => sum_st3(121), c_in => sum_st3(122), sum => sum_st4(91), c_out => carry_st4(91));
	
	add_num92_st4 : fa port map (in1 => carry_st3(120), in2 => carry_st3(121), c_in => carry_st3(122), sum => sum_st4(92), c_out => carry_st4(92));
	
	add_num93_st4 : fa port map (in1 => sum_st3(123), in2 => sum_st3(124), c_in => part_prod(16)(23), sum => sum_st4(93), c_out => carry_st4(93));
	
	add_num94_st4 : fa port map (in1 => carry_st3(123), in2 => carry_st3(124), c_in => sum_st3(125), sum => sum_st4(94), c_out => carry_st4(94));
	
	add_num95_st4 : fa port map (in1 => sum_st3(126), in2 => part_prod(15)(26), c_in => part_prod(16)(24), sum => sum_st4(95), c_out => carry_st4(95));
	
	add_num96_st4 : fa port map (in1 => carry_st3(125), in2 => carry_st3(126), c_in => sum_st3(127), sum => sum_st4(96), c_out => carry_st4(96));
	
	add_num97_st4 : fa port map (in1 => part_prod(14)(29), in2 => part_prod(15)(27), c_in => part_prod(16)(25), sum => sum_st4(97), c_out => carry_st4(97));
	
	add_num98_st4 : fa port map (in1 => carry_st3(127), in2 => sum_st3(128), c_in => part_prod(13)(32), sum => sum_st4(98), c_out => carry_st4(98));
	
	add_num99_st4 : fa port map (in1 => part_prod(14)(30), in2 => part_prod(15)(28), c_in => part_prod(16)(26), sum => sum_st4(99), c_out => carry_st4(99));
	
	add_num100_st4 : fa port map (in1 => carry_st3(128), in2 => part_prod(12)(35), c_in => part_prod(13)(33), sum => sum_st4(100), c_out => carry_st4(100));
	
	add_num101_st4 : fa port map (in1 => part_prod(14)(31), in2 => part_prod(15)(29), c_in => part_prod(16)(27), sum => sum_st4(101), c_out => carry_st4(101));
	
	add_num102_st4 : fa port map (in1 => part_prod(12)(36), in2 => part_prod(13)(34), c_in => part_prod(14)(32), sum => sum_st4(102), c_out => carry_st4(102));
	
	add_num103_st4 : ha port map (in1 => part_prod(15)(30), in2 => part_prod(16)(28), sum => sum_st4(103), c_out => carry_st4(103));
	
	add_num104_st4 : fa port map (in1 => part_prod(13)(35), in2 => part_prod(14)(33), c_in => part_prod(15)(31), sum => sum_st4(104), c_out => carry_st4(104));
	
	add_num105_st4 : ha port map (in1 => part_prod(13)(36), in2 => part_prod(14)(34), sum => sum_st4(105), c_out => carry_st4(105));
	
	add_num0_st5 : ha port map (in1 => part_prod(0)(4), in2 => part_prod(1)(4), sum => sum_st5(0), c_out => carry_st5(0));
	
	add_num1_st5 : ha port map (in1 => part_prod(0)(5), in2 => part_prod(1)(5), sum => sum_st5(1), c_out => carry_st5(1));
	
	add_num2_st5 : fa port map (in1 => sum_st4(0), in2 => part_prod(2)(4), c_in => part_prod(3)(2), sum => sum_st5(2), c_out => carry_st5(2));
	
	add_num3_st5 : fa port map (in1 => carry_st4(0), in2 => sum_st4(1), c_in => part_prod(2)(5), sum => sum_st5(3), c_out => carry_st5(3));
	
	add_num4_st5 : fa port map (in1 => carry_st4(1), in2 => sum_st4(2), c_in => sum_st4(3), sum => sum_st5(4), c_out => carry_st5(4));
	
	add_num5_st5 : fa port map (in1 => carry_st4(2), in2 => carry_st4(3), c_in => sum_st4(4), sum => sum_st5(5), c_out => carry_st5(5));
	
	add_num6_st5 : fa port map (in1 => carry_st4(4), in2 => carry_st4(5), c_in => sum_st4(6), sum => sum_st5(6), c_out => carry_st5(6));
	
	add_num7_st5 : fa port map (in1 => carry_st4(6), in2 => carry_st4(7), c_in => sum_st4(8), sum => sum_st5(7), c_out => carry_st5(7));
	
	add_num8_st5 : fa port map (in1 => carry_st4(8), in2 => carry_st4(9), c_in => sum_st4(10), sum => sum_st5(8), c_out => carry_st5(8));
	
	add_num9_st5 : fa port map (in1 => carry_st4(10), in2 => carry_st4(11), c_in => sum_st4(12), sum => sum_st5(9), c_out => carry_st5(9));
	
	add_num10_st5 : fa port map (in1 => carry_st4(12), in2 => carry_st4(13), c_in => sum_st4(14), sum => sum_st5(10), c_out => carry_st5(10));
	
	add_num11_st5 : fa port map (in1 => carry_st4(14), in2 => carry_st4(15), c_in => sum_st4(16), sum => sum_st5(11), c_out => carry_st5(11));
	
	add_num12_st5 : fa port map (in1 => carry_st4(16), in2 => carry_st4(17), c_in => sum_st4(18), sum => sum_st5(12), c_out => carry_st5(12));
	
	add_num13_st5 : fa port map (in1 => carry_st4(18), in2 => carry_st4(19), c_in => sum_st4(20), sum => sum_st5(13), c_out => carry_st5(13));
	
	add_num14_st5 : fa port map (in1 => carry_st4(20), in2 => carry_st4(21), c_in => sum_st4(22), sum => sum_st5(14), c_out => carry_st5(14));
	
	add_num15_st5 : fa port map (in1 => carry_st4(22), in2 => carry_st4(23), c_in => sum_st4(24), sum => sum_st5(15), c_out => carry_st5(15));
	
	add_num16_st5 : fa port map (in1 => carry_st4(24), in2 => carry_st4(25), c_in => sum_st4(26), sum => sum_st5(16), c_out => carry_st5(16));
	
	add_num17_st5 : fa port map (in1 => carry_st4(26), in2 => carry_st4(27), c_in => sum_st4(28), sum => sum_st5(17), c_out => carry_st5(17));
	
	add_num18_st5 : fa port map (in1 => carry_st4(28), in2 => carry_st4(29), c_in => sum_st4(30), sum => sum_st5(18), c_out => carry_st5(18));
	
	add_num19_st5 : fa port map (in1 => carry_st4(30), in2 => carry_st4(31), c_in => sum_st4(32), sum => sum_st5(19), c_out => carry_st5(19));
	
	add_num20_st5 : fa port map (in1 => carry_st4(32), in2 => carry_st4(33), c_in => sum_st4(34), sum => sum_st5(20), c_out => carry_st5(20));
	
	add_num21_st5 : fa port map (in1 => carry_st4(34), in2 => carry_st4(35), c_in => sum_st4(36), sum => sum_st5(21), c_out => carry_st5(21));
	
	add_num22_st5 : fa port map (in1 => carry_st4(36), in2 => carry_st4(37), c_in => sum_st4(38), sum => sum_st5(22), c_out => carry_st5(22));
	
	add_num23_st5 : fa port map (in1 => carry_st4(38), in2 => carry_st4(39), c_in => sum_st4(40), sum => sum_st5(23), c_out => carry_st5(23));
	
	add_num24_st5 : fa port map (in1 => carry_st4(40), in2 => carry_st4(41), c_in => sum_st4(42), sum => sum_st5(24), c_out => carry_st5(24));
	
	add_num25_st5 : fa port map (in1 => carry_st4(42), in2 => carry_st4(43), c_in => sum_st4(44), sum => sum_st5(25), c_out => carry_st5(25));
	
	add_num26_st5 : fa port map (in1 => carry_st4(44), in2 => carry_st4(45), c_in => sum_st4(46), sum => sum_st5(26), c_out => carry_st5(26));
	
	add_num27_st5 : fa port map (in1 => carry_st4(46), in2 => carry_st4(47), c_in => sum_st4(48), sum => sum_st5(27), c_out => carry_st5(27));
	
	add_num28_st5 : fa port map (in1 => carry_st4(48), in2 => carry_st4(49), c_in => sum_st4(50), sum => sum_st5(28), c_out => carry_st5(28));
	
	add_num29_st5 : fa port map (in1 => carry_st4(50), in2 => carry_st4(51), c_in => sum_st4(52), sum => sum_st5(29), c_out => carry_st5(29));
	
	add_num30_st5 : fa port map (in1 => carry_st4(52), in2 => carry_st4(53), c_in => sum_st4(54), sum => sum_st5(30), c_out => carry_st5(30));
	
	add_num31_st5 : fa port map (in1 => carry_st4(54), in2 => carry_st4(55), c_in => sum_st4(56), sum => sum_st5(31), c_out => carry_st5(31));
	
	add_num32_st5 : fa port map (in1 => carry_st4(56), in2 => carry_st4(57), c_in => sum_st4(58), sum => sum_st5(32), c_out => carry_st5(32));
	
	add_num33_st5 : fa port map (in1 => carry_st4(58), in2 => carry_st4(59), c_in => sum_st4(60), sum => sum_st5(33), c_out => carry_st5(33));
	
	add_num34_st5 : fa port map (in1 => carry_st4(60), in2 => carry_st4(61), c_in => sum_st4(62), sum => sum_st5(34), c_out => carry_st5(34));
	
	add_num35_st5 : fa port map (in1 => carry_st4(62), in2 => carry_st4(63), c_in => sum_st4(64), sum => sum_st5(35), c_out => carry_st5(35));
	
	add_num36_st5 : fa port map (in1 => carry_st4(64), in2 => carry_st4(65), c_in => sum_st4(66), sum => sum_st5(36), c_out => carry_st5(36));
	
	add_num37_st5 : fa port map (in1 => carry_st4(66), in2 => carry_st4(67), c_in => sum_st4(68), sum => sum_st5(37), c_out => carry_st5(37));
	
	add_num38_st5 : fa port map (in1 => carry_st4(68), in2 => carry_st4(69), c_in => sum_st4(70), sum => sum_st5(38), c_out => carry_st5(38));
	
	add_num39_st5 : fa port map (in1 => carry_st4(70), in2 => carry_st4(71), c_in => sum_st4(72), sum => sum_st5(39), c_out => carry_st5(39));
	
	add_num40_st5 : fa port map (in1 => carry_st4(72), in2 => carry_st4(73), c_in => sum_st4(74), sum => sum_st5(40), c_out => carry_st5(40));
	
	add_num41_st5 : fa port map (in1 => carry_st4(74), in2 => carry_st4(75), c_in => sum_st4(76), sum => sum_st5(41), c_out => carry_st5(41));
	
	add_num42_st5 : fa port map (in1 => carry_st4(76), in2 => carry_st4(77), c_in => sum_st4(78), sum => sum_st5(42), c_out => carry_st5(42));
	
	add_num43_st5 : fa port map (in1 => carry_st4(78), in2 => carry_st4(79), c_in => sum_st4(80), sum => sum_st5(43), c_out => carry_st5(43));
	
	add_num44_st5 : fa port map (in1 => carry_st4(80), in2 => carry_st4(81), c_in => sum_st4(82), sum => sum_st5(44), c_out => carry_st5(44));
	
	add_num45_st5 : fa port map (in1 => carry_st4(82), in2 => carry_st4(83), c_in => sum_st4(84), sum => sum_st5(45), c_out => carry_st5(45));
	
	add_num46_st5 : fa port map (in1 => carry_st4(84), in2 => carry_st4(85), c_in => sum_st4(86), sum => sum_st5(46), c_out => carry_st5(46));
	
	add_num47_st5 : fa port map (in1 => carry_st4(86), in2 => carry_st4(87), c_in => sum_st4(88), sum => sum_st5(47), c_out => carry_st5(47));
	
	add_num48_st5 : fa port map (in1 => carry_st4(88), in2 => carry_st4(89), c_in => sum_st4(90), sum => sum_st5(48), c_out => carry_st5(48));
	
	add_num49_st5 : fa port map (in1 => carry_st4(90), in2 => carry_st4(91), c_in => sum_st4(92), sum => sum_st5(49), c_out => carry_st5(49));
	
	add_num50_st5 : fa port map (in1 => carry_st4(92), in2 => carry_st4(93), c_in => sum_st4(94), sum => sum_st5(50), c_out => carry_st5(50));
	
	add_num51_st5 : fa port map (in1 => carry_st4(94), in2 => carry_st4(95), c_in => sum_st4(96), sum => sum_st5(51), c_out => carry_st5(51));
	
	add_num52_st5 : fa port map (in1 => carry_st4(96), in2 => carry_st4(97), c_in => sum_st4(98), sum => sum_st5(52), c_out => carry_st5(52));
	
	add_num53_st5 : fa port map (in1 => carry_st4(98), in2 => carry_st4(99), c_in => sum_st4(100), sum => sum_st5(53), c_out => carry_st5(53));
	
	add_num54_st5 : fa port map (in1 => carry_st4(100), in2 => carry_st4(101), c_in => sum_st4(102), sum => sum_st5(54), c_out => carry_st5(54));
	
	add_num55_st5 : fa port map (in1 => carry_st4(102), in2 => carry_st4(103), c_in => sum_st4(104), sum => sum_st5(55), c_out => carry_st5(55));
	
	add_num56_st5 : fa port map (in1 => carry_st4(104), in2 => sum_st4(105), c_in => part_prod(15)(32), sum => sum_st5(56), c_out => carry_st5(56));
	
	add_num57_st5 : fa port map (in1 => carry_st4(105), in2 => part_prod(14)(35), c_in => part_prod(15)(33), sum => sum_st5(57), c_out => carry_st5(57));
	
	add_num58_st5 : ha port map (in1 => part_prod(14)(36), in2 => part_prod(15)(34), sum => sum_st5(58), c_out => carry_st5(58));
	
	add_num0_st6 : ha port map (in1 => part_prod(0)(2), in2 => part_prod(1)(2), sum => sum_st6(0), c_out => carry_st6(0));
	
	add_num1_st6 : ha port map (in1 => part_prod(0)(3), in2 => part_prod(1)(3), sum => sum_st6(1), c_out => carry_st6(1));
	
	add_num2_st6 : fa port map (in1 => sum_st5(0), in2 => part_prod(2)(2), c_in => part_prod(3)(0), sum => sum_st6(2), c_out => carry_st6(2));
	
	add_num3_st6 : fa port map (in1 => carry_st5(0), in2 => sum_st5(1), c_in => part_prod(2)(3), sum => sum_st6(3), c_out => carry_st6(3));
	
	add_num4_st6 : fa port map (in1 => carry_st5(1), in2 => sum_st5(2), c_in => part_prod(4)(0), sum => sum_st6(4), c_out => carry_st6(4));
	
	add_num5_st6 : fa port map (in1 => carry_st5(2), in2 => sum_st5(3), c_in => part_prod(3)(3), sum => sum_st6(5), c_out => carry_st6(5));
	
	add_num6_st6 : fa port map (in1 => carry_st5(3), in2 => sum_st5(4), c_in => part_prod(5)(0), sum => sum_st6(6), c_out => carry_st6(6));
	
	add_num7_st6 : fa port map (in1 => carry_st5(4), in2 => sum_st5(5), c_in => sum_st4(5), sum => sum_st6(7), c_out => carry_st6(7));
	
	add_num8_st6 : fa port map (in1 => carry_st5(5), in2 => sum_st5(6), c_in => sum_st4(7), sum => sum_st6(8), c_out => carry_st6(8));
	
	add_num9_st6 : fa port map (in1 => carry_st5(6), in2 => sum_st5(7), c_in => sum_st4(9), sum => sum_st6(9), c_out => carry_st6(9));
	
	add_num10_st6 : fa port map (in1 => carry_st5(7), in2 => sum_st5(8), c_in => sum_st4(11), sum => sum_st6(10), c_out => carry_st6(10));
	
	add_num11_st6 : fa port map (in1 => carry_st5(8), in2 => sum_st5(9), c_in => sum_st4(13), sum => sum_st6(11), c_out => carry_st6(11));
	
	add_num12_st6 : fa port map (in1 => carry_st5(9), in2 => sum_st5(10), c_in => sum_st4(15), sum => sum_st6(12), c_out => carry_st6(12));
	
	add_num13_st6 : fa port map (in1 => carry_st5(10), in2 => sum_st5(11), c_in => sum_st4(17), sum => sum_st6(13), c_out => carry_st6(13));
	
	add_num14_st6 : fa port map (in1 => carry_st5(11), in2 => sum_st5(12), c_in => sum_st4(19), sum => sum_st6(14), c_out => carry_st6(14));
	
	add_num15_st6 : fa port map (in1 => carry_st5(12), in2 => sum_st5(13), c_in => sum_st4(21), sum => sum_st6(15), c_out => carry_st6(15));
	
	add_num16_st6 : fa port map (in1 => carry_st5(13), in2 => sum_st5(14), c_in => sum_st4(23), sum => sum_st6(16), c_out => carry_st6(16));
	
	add_num17_st6 : fa port map (in1 => carry_st5(14), in2 => sum_st5(15), c_in => sum_st4(25), sum => sum_st6(17), c_out => carry_st6(17));
	
	add_num18_st6 : fa port map (in1 => carry_st5(15), in2 => sum_st5(16), c_in => sum_st4(27), sum => sum_st6(18), c_out => carry_st6(18));
	
	add_num19_st6 : fa port map (in1 => carry_st5(16), in2 => sum_st5(17), c_in => sum_st4(29), sum => sum_st6(19), c_out => carry_st6(19));
	
	add_num20_st6 : fa port map (in1 => carry_st5(17), in2 => sum_st5(18), c_in => sum_st4(31), sum => sum_st6(20), c_out => carry_st6(20));
	
	add_num21_st6 : fa port map (in1 => carry_st5(18), in2 => sum_st5(19), c_in => sum_st4(33), sum => sum_st6(21), c_out => carry_st6(21));
	
	add_num22_st6 : fa port map (in1 => carry_st5(19), in2 => sum_st5(20), c_in => sum_st4(35), sum => sum_st6(22), c_out => carry_st6(22));
	
	add_num23_st6 : fa port map (in1 => carry_st5(20), in2 => sum_st5(21), c_in => sum_st4(37), sum => sum_st6(23), c_out => carry_st6(23));
	
	add_num24_st6 : fa port map (in1 => carry_st5(21), in2 => sum_st5(22), c_in => sum_st4(39), sum => sum_st6(24), c_out => carry_st6(24));
	
	add_num25_st6 : fa port map (in1 => carry_st5(22), in2 => sum_st5(23), c_in => sum_st4(41), sum => sum_st6(25), c_out => carry_st6(25));
	
	add_num26_st6 : fa port map (in1 => carry_st5(23), in2 => sum_st5(24), c_in => sum_st4(43), sum => sum_st6(26), c_out => carry_st6(26));
	
	add_num27_st6 : fa port map (in1 => carry_st5(24), in2 => sum_st5(25), c_in => sum_st4(45), sum => sum_st6(27), c_out => carry_st6(27));
	
	add_num28_st6 : fa port map (in1 => carry_st5(25), in2 => sum_st5(26), c_in => sum_st4(47), sum => sum_st6(28), c_out => carry_st6(28));
	
	add_num29_st6 : fa port map (in1 => carry_st5(26), in2 => sum_st5(27), c_in => sum_st4(49), sum => sum_st6(29), c_out => carry_st6(29));
	
	add_num30_st6 : fa port map (in1 => carry_st5(27), in2 => sum_st5(28), c_in => sum_st4(51), sum => sum_st6(30), c_out => carry_st6(30));
	
	add_num31_st6 : fa port map (in1 => carry_st5(28), in2 => sum_st5(29), c_in => sum_st4(53), sum => sum_st6(31), c_out => carry_st6(31));
	
	add_num32_st6 : fa port map (in1 => carry_st5(29), in2 => sum_st5(30), c_in => sum_st4(55), sum => sum_st6(32), c_out => carry_st6(32));
	
	add_num33_st6 : fa port map (in1 => carry_st5(30), in2 => sum_st5(31), c_in => sum_st4(57), sum => sum_st6(33), c_out => carry_st6(33));
	
	add_num34_st6 : fa port map (in1 => carry_st5(31), in2 => sum_st5(32), c_in => sum_st4(59), sum => sum_st6(34), c_out => carry_st6(34));
	
	add_num35_st6 : fa port map (in1 => carry_st5(32), in2 => sum_st5(33), c_in => sum_st4(61), sum => sum_st6(35), c_out => carry_st6(35));
	
	add_num36_st6 : fa port map (in1 => carry_st5(33), in2 => sum_st5(34), c_in => sum_st4(63), sum => sum_st6(36), c_out => carry_st6(36));
	
	add_num37_st6 : fa port map (in1 => carry_st5(34), in2 => sum_st5(35), c_in => sum_st4(65), sum => sum_st6(37), c_out => carry_st6(37));
	
	add_num38_st6 : fa port map (in1 => carry_st5(35), in2 => sum_st5(36), c_in => sum_st4(67), sum => sum_st6(38), c_out => carry_st6(38));
	
	add_num39_st6 : fa port map (in1 => carry_st5(36), in2 => sum_st5(37), c_in => sum_st4(69), sum => sum_st6(39), c_out => carry_st6(39));
	
	add_num40_st6 : fa port map (in1 => carry_st5(37), in2 => sum_st5(38), c_in => sum_st4(71), sum => sum_st6(40), c_out => carry_st6(40));
	
	add_num41_st6 : fa port map (in1 => carry_st5(38), in2 => sum_st5(39), c_in => sum_st4(73), sum => sum_st6(41), c_out => carry_st6(41));
	
	add_num42_st6 : fa port map (in1 => carry_st5(39), in2 => sum_st5(40), c_in => sum_st4(75), sum => sum_st6(42), c_out => carry_st6(42));
	
	add_num43_st6 : fa port map (in1 => carry_st5(40), in2 => sum_st5(41), c_in => sum_st4(77), sum => sum_st6(43), c_out => carry_st6(43));
	
	add_num44_st6 : fa port map (in1 => carry_st5(41), in2 => sum_st5(42), c_in => sum_st4(79), sum => sum_st6(44), c_out => carry_st6(44));
	
	add_num45_st6 : fa port map (in1 => carry_st5(42), in2 => sum_st5(43), c_in => sum_st4(81), sum => sum_st6(45), c_out => carry_st6(45));
	
	add_num46_st6 : fa port map (in1 => carry_st5(43), in2 => sum_st5(44), c_in => sum_st4(83), sum => sum_st6(46), c_out => carry_st6(46));
	
	add_num47_st6 : fa port map (in1 => carry_st5(44), in2 => sum_st5(45), c_in => sum_st4(85), sum => sum_st6(47), c_out => carry_st6(47));
	
	add_num48_st6 : fa port map (in1 => carry_st5(45), in2 => sum_st5(46), c_in => sum_st4(87), sum => sum_st6(48), c_out => carry_st6(48));
	
	add_num49_st6 : fa port map (in1 => carry_st5(46), in2 => sum_st5(47), c_in => sum_st4(89), sum => sum_st6(49), c_out => carry_st6(49));
	
	add_num50_st6 : fa port map (in1 => carry_st5(47), in2 => sum_st5(48), c_in => sum_st4(91), sum => sum_st6(50), c_out => carry_st6(50));
	
	add_num51_st6 : fa port map (in1 => carry_st5(48), in2 => sum_st5(49), c_in => sum_st4(93), sum => sum_st6(51), c_out => carry_st6(51));
	
	add_num52_st6 : fa port map (in1 => carry_st5(49), in2 => sum_st5(50), c_in => sum_st4(95), sum => sum_st6(52), c_out => carry_st6(52));
	
	add_num53_st6 : fa port map (in1 => carry_st5(50), in2 => sum_st5(51), c_in => sum_st4(97), sum => sum_st6(53), c_out => carry_st6(53));
	
	add_num54_st6 : fa port map (in1 => carry_st5(51), in2 => sum_st5(52), c_in => sum_st4(99), sum => sum_st6(54), c_out => carry_st6(54));
	
	add_num55_st6 : fa port map (in1 => carry_st5(52), in2 => sum_st5(53), c_in => sum_st4(101), sum => sum_st6(55), c_out => carry_st6(55));
	
	add_num56_st6 : fa port map (in1 => carry_st5(53), in2 => sum_st5(54), c_in => sum_st4(103), sum => sum_st6(56), c_out => carry_st6(56));
	
	add_num57_st6 : fa port map (in1 => carry_st5(54), in2 => sum_st5(55), c_in => part_prod(16)(29), sum => sum_st6(57), c_out => carry_st6(57));
	
	add_num58_st6 : fa port map (in1 => carry_st5(55), in2 => sum_st5(56), c_in => part_prod(16)(30), sum => sum_st6(58), c_out => carry_st6(58));
	
	add_num59_st6 : fa port map (in1 => carry_st5(56), in2 => sum_st5(57), c_in => part_prod(16)(31), sum => sum_st6(59), c_out => carry_st6(59));
	
	add_num60_st6 : fa port map (in1 => carry_st5(57), in2 => sum_st5(58), c_in => part_prod(16)(32), sum => sum_st6(60), c_out => carry_st6(60));
	
	add_num61_st6 : fa port map (in1 => carry_st5(58), in2 => part_prod(15)(35), c_in => part_prod(16)(33), sum => sum_st6(61), c_out => carry_st6(61));
	
	add_num0_st7 : ha port map (in1 => part_prod(0)(0), in2 => part_prod(1)(0), sum => result(0), c_out => carry_st7(0));
	
	add_num1_st7 : fa port map (in1 => part_prod(0)(1), in2 => '0', c_in => carry_st7(0), sum => result(1), c_out => carry_st7(1));
	
	add_num2_st7 : fa port map (in1 => sum_st6(0), in2 => part_prod(2)(0), c_in => carry_st7(1), sum => result(2), c_out => carry_st7(2));
	
	add_num3_st7 : fa port map (in1 => carry_st6(0), in2 => sum_st6(1), c_in => carry_st7(2), sum => result(3), c_out => carry_st7(3));
	
	add_num4_st7 : fa port map (in1 => carry_st6(1), in2 => sum_st6(2), c_in => carry_st7(3), sum => result(4), c_out => carry_st7(4));
	
	add_num5_st7 : fa port map (in1 => carry_st6(2), in2 => sum_st6(3), c_in => carry_st7(4), sum => result(5), c_out => carry_st7(5));
	
	add_num6_st7 : fa port map (in1 => carry_st6(3), in2 => sum_st6(4), c_in => carry_st7(5), sum => result(6), c_out => carry_st7(6));
	
	add_num7_st7 : fa port map (in1 => carry_st6(4), in2 => sum_st6(5), c_in => carry_st7(6), sum => result(7), c_out => carry_st7(7));
	
	add_num8_st7 : fa port map (in1 => carry_st6(5), in2 => sum_st6(6), c_in => carry_st7(7), sum => result(8), c_out => carry_st7(8));
	
	add_num9_st7 : fa port map (in1 => carry_st6(6), in2 => sum_st6(7), c_in => carry_st7(8), sum => result(9), c_out => carry_st7(9));
	
	add_num10_st7 : fa port map (in1 => carry_st6(7), in2 => sum_st6(8), c_in => carry_st7(9), sum => result(10), c_out => carry_st7(10));
	
	add_num11_st7 : fa port map (in1 => carry_st6(8), in2 => sum_st6(9), c_in => carry_st7(10), sum => result(11), c_out => carry_st7(11));
	
	add_num12_st7 : fa port map (in1 => carry_st6(9), in2 => sum_st6(10), c_in => carry_st7(11), sum => result(12), c_out => carry_st7(12));
	
	add_num13_st7 : fa port map (in1 => carry_st6(10), in2 => sum_st6(11), c_in => carry_st7(12), sum => result(13), c_out => carry_st7(13));
	
	add_num14_st7 : fa port map (in1 => carry_st6(11), in2 => sum_st6(12), c_in => carry_st7(13), sum => result(14), c_out => carry_st7(14));
	
	add_num15_st7 : fa port map (in1 => carry_st6(12), in2 => sum_st6(13), c_in => carry_st7(14), sum => result(15), c_out => carry_st7(15));
	
	add_num16_st7 : fa port map (in1 => carry_st6(13), in2 => sum_st6(14), c_in => carry_st7(15), sum => result(16), c_out => carry_st7(16));
	
	add_num17_st7 : fa port map (in1 => carry_st6(14), in2 => sum_st6(15), c_in => carry_st7(16), sum => result(17), c_out => carry_st7(17));
	
	add_num18_st7 : fa port map (in1 => carry_st6(15), in2 => sum_st6(16), c_in => carry_st7(17), sum => result(18), c_out => carry_st7(18));
	
	add_num19_st7 : fa port map (in1 => carry_st6(16), in2 => sum_st6(17), c_in => carry_st7(18), sum => result(19), c_out => carry_st7(19));
	
	add_num20_st7 : fa port map (in1 => carry_st6(17), in2 => sum_st6(18), c_in => carry_st7(19), sum => result(20), c_out => carry_st7(20));
	
	add_num21_st7 : fa port map (in1 => carry_st6(18), in2 => sum_st6(19), c_in => carry_st7(20), sum => result(21), c_out => carry_st7(21));
	
	add_num22_st7 : fa port map (in1 => carry_st6(19), in2 => sum_st6(20), c_in => carry_st7(21), sum => result(22), c_out => carry_st7(22));
	
	add_num23_st7 : fa port map (in1 => carry_st6(20), in2 => sum_st6(21), c_in => carry_st7(22), sum => result(23), c_out => carry_st7(23));
	
	add_num24_st7 : fa port map (in1 => carry_st6(21), in2 => sum_st6(22), c_in => carry_st7(23), sum => result(24), c_out => carry_st7(24));
	
	add_num25_st7 : fa port map (in1 => carry_st6(22), in2 => sum_st6(23), c_in => carry_st7(24), sum => result(25), c_out => carry_st7(25));
	
	add_num26_st7 : fa port map (in1 => carry_st6(23), in2 => sum_st6(24), c_in => carry_st7(25), sum => result(26), c_out => carry_st7(26));
	
	add_num27_st7 : fa port map (in1 => carry_st6(24), in2 => sum_st6(25), c_in => carry_st7(26), sum => result(27), c_out => carry_st7(27));
	
	add_num28_st7 : fa port map (in1 => carry_st6(25), in2 => sum_st6(26), c_in => carry_st7(27), sum => result(28), c_out => carry_st7(28));
	
	add_num29_st7 : fa port map (in1 => carry_st6(26), in2 => sum_st6(27), c_in => carry_st7(28), sum => result(29), c_out => carry_st7(29));
	
	add_num30_st7 : fa port map (in1 => carry_st6(27), in2 => sum_st6(28), c_in => carry_st7(29), sum => result(30), c_out => carry_st7(30));
	
	add_num31_st7 : fa port map (in1 => carry_st6(28), in2 => sum_st6(29), c_in => carry_st7(30), sum => result(31), c_out => carry_st7(31));
	
	add_num32_st7 : fa port map (in1 => carry_st6(29), in2 => sum_st6(30), c_in => carry_st7(31), sum => result(32), c_out => carry_st7(32));
	
	add_num33_st7 : fa port map (in1 => carry_st6(30), in2 => sum_st6(31), c_in => carry_st7(32), sum => result(33), c_out => carry_st7(33));
	
	add_num34_st7 : fa port map (in1 => carry_st6(31), in2 => sum_st6(32), c_in => carry_st7(33), sum => result(34), c_out => carry_st7(34));
	
	add_num35_st7 : fa port map (in1 => carry_st6(32), in2 => sum_st6(33), c_in => carry_st7(34), sum => result(35), c_out => carry_st7(35));
	
	add_num36_st7 : fa port map (in1 => carry_st6(33), in2 => sum_st6(34), c_in => carry_st7(35), sum => result(36), c_out => carry_st7(36));
	
	add_num37_st7 : fa port map (in1 => carry_st6(34), in2 => sum_st6(35), c_in => carry_st7(36), sum => result(37), c_out => carry_st7(37));
	
	add_num38_st7 : fa port map (in1 => carry_st6(35), in2 => sum_st6(36), c_in => carry_st7(37), sum => result(38), c_out => carry_st7(38));
	
	add_num39_st7 : fa port map (in1 => carry_st6(36), in2 => sum_st6(37), c_in => carry_st7(38), sum => result(39), c_out => carry_st7(39));
	
	add_num40_st7 : fa port map (in1 => carry_st6(37), in2 => sum_st6(38), c_in => carry_st7(39), sum => result(40), c_out => carry_st7(40));
	
	add_num41_st7 : fa port map (in1 => carry_st6(38), in2 => sum_st6(39), c_in => carry_st7(40), sum => result(41), c_out => carry_st7(41));
	
	add_num42_st7 : fa port map (in1 => carry_st6(39), in2 => sum_st6(40), c_in => carry_st7(41), sum => result(42), c_out => carry_st7(42));
	
	add_num43_st7 : fa port map (in1 => carry_st6(40), in2 => sum_st6(41), c_in => carry_st7(42), sum => result(43), c_out => carry_st7(43));
	
	add_num44_st7 : fa port map (in1 => carry_st6(41), in2 => sum_st6(42), c_in => carry_st7(43), sum => result(44), c_out => carry_st7(44));
	
	add_num45_st7 : fa port map (in1 => carry_st6(42), in2 => sum_st6(43), c_in => carry_st7(44), sum => result(45), c_out => carry_st7(45));
	
	add_num46_st7 : fa port map (in1 => carry_st6(43), in2 => sum_st6(44), c_in => carry_st7(45), sum => result(46), c_out => carry_st7(46));
	
	add_num47_st7 : fa port map (in1 => carry_st6(44), in2 => sum_st6(45), c_in => carry_st7(46), sum => result(47), c_out => carry_st7(47));
	
	add_num48_st7 : fa port map (in1 => carry_st6(45), in2 => sum_st6(46), c_in => carry_st7(47), sum => result(48), c_out => carry_st7(48));
	
	add_num49_st7 : fa port map (in1 => carry_st6(46), in2 => sum_st6(47), c_in => carry_st7(48), sum => result(49), c_out => carry_st7(49));
	
	add_num50_st7 : fa port map (in1 => carry_st6(47), in2 => sum_st6(48), c_in => carry_st7(49), sum => result(50), c_out => carry_st7(50));
	
	add_num51_st7 : fa port map (in1 => carry_st6(48), in2 => sum_st6(49), c_in => carry_st7(50), sum => result(51), c_out => carry_st7(51));
	
	add_num52_st7 : fa port map (in1 => carry_st6(49), in2 => sum_st6(50), c_in => carry_st7(51), sum => result(52), c_out => carry_st7(52));
	
	add_num53_st7 : fa port map (in1 => carry_st6(50), in2 => sum_st6(51), c_in => carry_st7(52), sum => result(53), c_out => carry_st7(53));
	
	add_num54_st7 : fa port map (in1 => carry_st6(51), in2 => sum_st6(52), c_in => carry_st7(53), sum => result(54), c_out => carry_st7(54));
	
	add_num55_st7 : fa port map (in1 => carry_st6(52), in2 => sum_st6(53), c_in => carry_st7(54), sum => result(55), c_out => carry_st7(55));
	
	add_num56_st7 : fa port map (in1 => carry_st6(53), in2 => sum_st6(54), c_in => carry_st7(55), sum => result(56), c_out => carry_st7(56));
	
	add_num57_st7 : fa port map (in1 => carry_st6(54), in2 => sum_st6(55), c_in => carry_st7(56), sum => result(57), c_out => carry_st7(57));
	
	add_num58_st7 : fa port map (in1 => carry_st6(55), in2 => sum_st6(56), c_in => carry_st7(57), sum => result(58), c_out => carry_st7(58));
	
	add_num59_st7 : fa port map (in1 => carry_st6(56), in2 => sum_st6(57), c_in => carry_st7(58), sum => result(59), c_out => carry_st7(59));
	
	add_num60_st7 : fa port map (in1 => carry_st6(57), in2 => sum_st6(58), c_in => carry_st7(59), sum => result(60), c_out => carry_st7(60));
	
	add_num61_st7 : fa port map (in1 => carry_st6(58), in2 => sum_st6(59), c_in => carry_st7(60), sum => result(61), c_out => carry_st7(61));
	
	add_num62_st7 : fa port map (in1 => carry_st6(59), in2 => sum_st6(60), c_in => carry_st7(61), sum => result(62), c_out => carry_st7(62));
	
	add_num63_st7 : fa port map (in1 => carry_st6(60), in2 => sum_st6(61), c_in => carry_st7(62), sum => result(63), c_out => carry_st7(63));
	
	add_num64_st7 : fa port map (in1 => carry_st6(61), in2 => '0', c_in => carry_st7(63), sum => result(64), c_out => result(65));

	sig_out<=unsigned(result(63 downto 0));
	
end architecture behavioral;
