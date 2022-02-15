-- ************************************* --
-- * Integrated Systems Architecture   * --
-- * Lab 03: RISC-V                    * --  
-- * DESIGN ELEMENT: top-entity RISC-V * --   
-- * Authors:                          * --
-- *  FIORAVANTI Simone S292612        * --
-- *  MOLINA Ottavio    S292527        * --
-- *  OTTINO Lorenzo    S281571        * --
-- ************************************* --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RISC_V is
    port (
        instr_mem_addr : out std_logic_vector(31 downto 0);
        instr_mem_read : in std_logic_vector(31 downto 0);
        data_mem_addr : out std_logic_vector(31 downto 0);
        data_mem_read : in std_logic_vector(31 downto 0);
        data_mem_write : out std_logic_vector(31 downto 0);
        data_mem_wr: out std_logic;
        clk, rst : in std_logic);
end entity RISC_V;


architecture behavior of RISC_V is

    component FWD_U is
        generic(N_bit : integer:=5;
                N_bit_sel: integer := 2);
        port(r1, r2, rd_WB, rd_OS: in std_logic_vector(N_bit -1 downto 0);
             opcode: in std_logic_vector(6 downto 0);
             func3: in std_logic_vector(2 downto 0);
             reg_wr_OS, reg_wr_WB, clk, rst: in std_logic;
             sel_frw_imm: out std_logic_vector(2 downto 0);
             sel_fwd, sel_r1: out std_logic_vector(N_bit_sel-1 downto 0));
    end component;

    component CU is
        generic(N_bit: integer := 7);
        port(opcode: in std_logic_vector(N_bit-1 downto 0);
             func3: in std_logic_vector(2 downto 0);
             sel_reg_src, alu_cotrol: out std_logic_vector(2 downto 0);
             sel_cu, sel_pc_res, branch, reg_wr, mem_rd, mem_wr: out std_logic;
             en_pc, sel_mux_instr, jal_flag : out std_logic;   
             sel_result : out std_logic; 
             clk, rst: in std_logic);
    end component;
    
    component mux_2to1 is
        generic (N_bit : integer := 32);
        port (sel : in std_logic;
            in0, in1 : in std_logic_vector(N_bit-1 downto 0);
            sig_out : out std_logic_vector(N_bit-1 downto 0));
    end component;

    component register_file is
        generic ( 
            N_bit_addr : integer := 32;
            N_bit_data : integer := 32);
        port (
            addr_read1, addr_read2, addr_wr : in std_logic_vector(N_bit_addr-1 downto 0);
            data_wr : in std_logic_vector(N_bit_data-1 downto 0);
            clk, rst, en_write : in std_logic;
            data_read1, data_read2 : out std_logic_vector(N_bit_data-1 downto 0));
    end component;

    component alu is
        generic( N_bit_data : integer := 8;
                 N_bit_mode : integer := 2);
        port (
            in1, in2 : in signed(N_bit_data-1 downto 0);
            mode : in std_logic_vector(N_bit_mode-1 downto 0) := std_logic_vector(to_unsigned(0,N_bit_mode));
            result : out signed(N_bit_data-1 downto 0);
            zero : out std_logic);
    end component;

    component ffd is
        generic(N_bit : integer := 1);
        port(
            data_in : in std_logic_vector(N_bit-1 downto 0);
            data_out : out std_logic_vector (N_bit-1 downto 0);
            clk, rst, cs: in std_logic);
    end component;

    component ffd_std is
        port(
            data_in : in std_logic;
            data_out : out std_logic;
            clk, rst, cs: in std_logic);
    end component;

    component mux_3to1 is
        generic ( 
            N_bit : integer := 32);
        port (
            sel : in std_logic_vector(1 downto 0);
            in0, in1, in2 : in std_logic_vector(N_bit-1 downto 0);
            sig_out : out std_logic_vector(N_bit-1 downto 0));
    end component mux_3to1;

    component mux_5to1 is
        generic ( 
            N_bit : integer := 32);
        port (sel : in std_logic_vector(2 downto 0);
            in0, in1, in2, in3, in4 : in std_logic_vector(N_bit-1 downto 0);
            sig_out : out std_logic_vector(N_bit-1 downto 0));
    end component mux_5to1;

    component adder is
        generic (N_bit : integer := 32);
        port (
            in1, in2 : in signed (N_bit-1 downto 0);
            c_in : in std_logic;
            result : out signed(N_bit-1 downto 0);
            c_out : out std_logic);
    end component;

    component imm_generator is
        generic(N_bit : integer := 32);
        port( instr : in std_logic_vector(N_bit-1 downto 0);
        func3: in std_logic_vector(2 downto 0);
            immediate : out std_logic_vector(N_bit-1 downto 0));
    end component;

    component abs_calculator is
        generic(N_bit : integer := 32);
        port (
            data_in : in std_logic_vector(N_bit-1 downto 0);
            abs_out : out std_logic_vector(N_bit-1 downto 0));
    end component;

    signal instruction_ID : std_logic_vector(31 downto 0);
    signal read_r1 : std_logic_vector(31 downto 0);
    signal read_r2 : std_logic_vector(31 downto 0);
	signal read_r1_EX : std_logic_vector(31 downto 0);
    signal read_r2_EX : std_logic_vector(31 downto 0);
    signal read_r2_OS : std_logic_vector(31 downto 0);
    signal read_addr_r1_ID : std_logic_vector(4 downto 0); 
    signal read_addr_r2_ID : std_logic_vector(4 downto 0);
    signal read_addr_r1_EX : std_logic_vector(4 downto 0);
    signal read_addr_r2_EX : std_logic_vector(4 downto 0);

	 
    signal rf_addr_wr_WB, rf_addr_wr_OS, rf_addr_wr_EX, rf_addr_wr_ID : std_logic_vector(4 downto 0);
	signal rf_data_wr : std_logic_vector(31 downto 0);

    signal pc: std_logic_vector(31 downto 0); 
    signal pc_ID: std_logic_vector(31 downto 0); 
    signal pc_Ex: std_logic_vector(31 downto 0); 
    signal pc_next: std_logic_vector(31 downto 0); 
    signal pc_next_ID: std_logic_vector(31 downto 0); 
    signal pc_next_EX: std_logic_vector(31 downto 0); 
    signal pc_next_OS: std_logic_vector(31 downto 0); 
    signal pc_next_WB: std_logic_vector(31 downto 0); 
    signal pc_sequence: std_logic_vector(31 downto 0); 
    signal pc_calculated_EX: std_logic_vector(31 downto 0); 

    signal immediate_ID: std_logic_vector(31 downto 0);
    signal immediate_EX: std_logic_vector(31 downto 0);

    signal pc_calc_imm_EX: std_logic_vector(31 downto 0);
    signal pc_calc_imm_OS: std_logic_vector(31 downto 0);
    signal pc_calc_imm_WB: std_logic_vector(31 downto 0);

    signal jal_flag_ID : std_logic;
    signal jal_flag_EX : std_logic;
    signal jal_flag_OS : std_logic;

    signal sel_mux_instr : std_logic;
    signal sel_result_EX : std_logic;
    signal sel_result_ID : std_logic;
    signal en_pc : std_logic;
    signal alu_in1_EX: std_logic_vector(31 downto 0);
    signal alu_in2_EX: std_logic_vector(31 downto 0);
    signal r2_imm_EX: std_logic_vector(31 downto 0);
    signal alu_result_EX: std_logic_vector(31 downto 0);
    signal abs_result_EX: std_logic_vector(31 downto 0);
    signal calc_result_EX: std_logic_vector(31 downto 0);
    signal calc_result_OS: std_logic_vector(31 downto 0);
    signal calc_result_WB: std_logic_vector(31 downto 0);
    signal instruction_IF: std_logic_vector(31 downto 0);
    signal forward_OS : std_logic_vector(31 downto 0);
    constant NOP : std_logic_vector(31 downto 0) := "00000000000000000000000000010011";
    signal zero_EX: std_logic;
    signal zero_OS: std_logic;
    signal zero_WB: std_logic;
	signal en_pc_jump: std_logic;

    signal data_mem_read_WB, data_mem_read_OS: std_logic_vector(31 downto 0);
	 
    signal condition_result_SLT, condition_result_SLT_OS: std_logic_vector(31 downto 0);
    
    --control signals
    signal reg_wr_ID, reg_wr_EX, reg_wr_OS, reg_wr_WB : std_logic;      --write in register file
    signal sel_pc_src : std_logic;      --program counter source selector
    signal sel_pc_res_ID, sel_pc_res_EX : std_logic;  --selector output pc adder on EX stage
    signal sel_cu_ID, sel_cu_EX : std_logic;      --selector output pc adder on EX stage
    signal sel_r1_ID, sel_r1_EX : std_logic_vector(1 downto 0);  		--selector alu in1 fwd mux
    signal sel_frw_ID, sel_frw_EX : std_logic_vector(1 downto 0);  	--selector alu in2 fwd mux
    signal sel_frw_imm : std_logic_vector(2 downto 0);
	signal sel_reg_src_ID, sel_reg_src_EX, sel_reg_src_OS, sel_reg_src_WB : std_logic_vector(2 downto 0); 	--selector rf write data
    signal data_mem_wr_ID, data_mem_wr_EX, data_mem_wr_OS : std_logic;      --write in data memory
    signal alu_op_EX, alu_op_ID : std_logic_vector(2 downto 0);
    signal branch : std_logic;

begin
----------------------------------STAGE1--------------------------------------------------------------------------------------
    --program counter
    pc_comp: ffd generic map (N_bit => 32)
        port map(data_in => pc_next, data_out => pc, clk => clk, rst => rst, cs => en_pc_jump);

    --program counter sequence calculator
    pc_seq_adder_comp : adder generic map(N_bit => 32)
        port map(in1 => signed(pc), in2 => to_signed(4, 32), c_in => '0', c_out => open, std_logic_vector(result) => pc_sequence);

    --program counter source mux
    pc_src_mux_comp : mux_2to1 generic map(N_bit => 32)
        port map(in0 => pc_sequence, in1 => pc_calc_imm_OS, sel => sel_pc_src, sig_out => pc_next);

    --instruntion selection mux
    instr_mux_comp : mux_2to1 generic map(N_bit => 32)
        port map (in0 => instr_mem_read, in1 => NOP, sel => sel_mux_instr, sig_out => instruction_IF);

    instr_mem_addr <= pc;
    sel_pc_src <= branch and (jal_flag_OS or zero_OS);
    en_pc_jump <= en_pc and (branch nand (not sel_pc_src));

---------------------------------PIPE IF/ID-----------------------------------------------------------------------------------

    --pipe of pc+4
    pc_next_ID_comp: ffd generic map (N_bit => 32)
        port map(data_in => pc_next, data_out => pc_next_ID, clk => clk, rst => rst, cs => '1');

    --pipe of pc
    pc_ID_comp: ffd generic map (N_bit => 32)
        port map(data_in => pc, data_out => pc_ID, clk => clk, rst => rst, cs => '1');

    --pipe of the instruction read from the isntruction memory
    instr_mem_read_ID_comp: ffd generic map(N_bit => 32)
        port map(data_in => instruction_IF, data_out => instruction_ID, clk => clk, rst => rst, cs => '1');

    --pipe write address of the register file
    rf_addr_wr_ID_comp : ffd generic map (N_bit => 5)
        port map(data_in => instruction_ID(11 downto 7), data_out => rf_addr_wr_ID, clk => clk, rst => rst, cs => '1');
    
----------------------------------STAGE2--------------------------------------------------------------------------------------

    --regiter file
    register_file_comp : register_file generic map(N_bit_addr => 5, N_bit_data => 32)
        port map(addr_read1 => instruction_ID(19 downto 15), addr_read2 => instruction_ID(24 downto 20), data_read1 => read_r1_EX, data_read2 => read_r2_EX, 
                addr_wr => rf_addr_wr_WB, data_wr => rf_data_wr, en_write => reg_wr_WB, clk => clk, rst => rst);

    --immediate generator
    immediate_generator_comp : imm_generator generic map (N_bit => 32)
        port map(instr => instruction_ID, func3 => instruction_ID(14 downto 12), immediate => immediate_ID);

    --control unit
    control_unit_comp: CU port map(clk => clk, opcode => instruction_IF(6 downto 0), func3 => instruction_IF(14 downto 12), sel_reg_src => sel_reg_src_ID, alu_cotrol => alu_op_ID, 
        sel_cu => sel_cu_ID, sel_pc_res => sel_pc_res_ID, branch => branch, reg_wr => reg_wr_ID, mem_rd => open, mem_wr => data_mem_wr_ID, rst => rst, en_pc => en_pc, 
        jal_flag => jal_flag_ID, sel_mux_instr => sel_mux_instr, sel_result => sel_result_ID);

----------------------------------PIPE ID/EX----------------------------------------------------------------------------------

    --pipe for the address of r1
    read_addr_r1_EX_comp: ffd generic map (N_bit => 5)
        port map(data_in => instruction_ID(19 downto 15), data_out => read_addr_r1_EX, clk => clk, rst => rst, cs => '1');
    
    --pipe for the address of r2
    read_addr_r2_EX_comp: ffd generic map (N_bit => 5)
        port map(data_in => instruction_ID(24 downto 20), data_out => read_addr_r2_EX, clk => clk, rst => rst, cs => '1');

    --pipe immediate
    immediate_EX_comp: ffd generic map (N_bit => 32)
        port map(data_in => immediate_ID, data_out => immediate_EX, clk => clk, rst => rst, cs => '1');

    --pipe of pc+4
    pc_next_EX_comp: ffd generic map (N_bit => 32)
        port map(data_in => pc_next_ID, data_out => pc_next_EX, clk => clk, rst => rst, cs => '1');

    --pipe of pc
    pc_EX_comp: ffd generic map (N_bit => 32)
        port map(data_in => pc_ID, data_out => pc_EX, clk => clk, rst => rst, cs => '1');

    --CONTROLS
    rf_addr_wr_EX_comp : ffd generic map (N_bit => 5)
        port map(data_in => instruction_ID(11 downto 7), data_out => rf_addr_wr_EX, clk => clk, rst => rst, cs => '1');

    sel_pc_res_EX_comp: ffd_std port map (data_in => sel_pc_res_ID, clk => clk, rst => rst, cs => '1', data_out => sel_pc_res_EX);

    reg_wr_EX_comp: ffd_std port map (data_in => reg_wr_ID, clk => clk, rst => rst, cs => '1', data_out => reg_wr_EX);

    sel_cu_EX_comp: ffd_std port map (data_in => sel_cu_ID, clk => clk, rst => rst, cs => '1', data_out => sel_cu_EX);

    sel_result_EX_comp: ffd_std port map (data_in => sel_result_ID, clk => clk, rst => rst, cs => '1', data_out => sel_result_EX);

    jal_flag_EX_comp: ffd_std port map (data_in => jal_flag_ID, clk => clk, rst => rst, cs => '1', data_out => jal_flag_EX);

    sel_reg_src_EX_comp: ffd generic map(N_bit => 3)
			port map (data_in => sel_reg_src_ID, clk => clk, rst => rst, cs => '1', data_out => sel_reg_src_EX);

    data_mem_wr_EX_comp: ffd_std port map (data_in => data_mem_wr_ID, clk => clk, rst => rst, cs => '1', data_out => data_mem_wr_EX);

    alu_op_EX_comp : ffd generic map (N_bit => 3)
        port map(data_in => alu_op_ID, data_out => alu_op_EX, clk => clk, rst => rst, cs => '1');
    

----------------------------------STAGE 3------------------------------------------------------------------------------------

    --forwarding unit
    forwarding_unit_EX_comp: FWD_U generic map (N_bit => 5, N_bit_sel => 2)
        port map(r1 => read_addr_r1_EX, r2=> read_addr_r2_EX, rd_WB => rf_addr_wr_WB, rd_OS => rf_addr_wr_OS, reg_wr_OS => reg_wr_OS, reg_wr_WB => reg_wr_WB, 
            opcode => instruction_ID(6 downto 0), clk => clk, rst => rst, sel_fwd => sel_frw_EX, sel_r1 => sel_r1_EX, sel_frw_imm => sel_frw_imm, func3=>instruction_ID(14 downto 12));

    --adder of pc in EX stage
    add_pc_EX_comp: adder generic map(N_bit => 32)
        port map(in1 => signed(pc_EX), in2 => signed(immediate_EX), c_in => '0', c_out => open, std_logic_vector(result) => pc_calculated_EX);

    --calculated pc or immediate mux
    mux_calculated_pc_EX_comp: mux_2to1 generic map(N_bit => 32)
        port map(in1=> pc_calculated_EX, in0=> immediate_EX, sel => sel_pc_res_EX, sig_out => pc_calc_imm_EX);

    --forwarding mux, in1 of ALU
    forward_mux_in1_comp: mux_3to1 generic map (N_bit => 32)
        port map(in0 => read_r1_EX, in1 => forward_OS, in2 => rf_data_wr, sel => sel_r1_EX, sig_out => alu_in1_EX);
        
    --forwarding mux, in2 of ALU
    forward_mux_in2_comp: mux_3to1 generic map (N_bit => 32)
        port map(in0 => r2_imm_EX, in1 => forward_OS, in2 => rf_data_wr, sel => sel_frw_EX, sig_out => alu_in2_EX);

    --data selector, in2 of alu
    data_mux_in2_comp: mux_2to1 generic map (N_bit => 32)
        port map(in1 => read_r2_EX, in0 => immediate_EX, sel => sel_cu_EX, sig_out => r2_imm_EX);

    --ALU
    ALU_comp: alu generic map (N_bit_data => 32, N_bit_mode =>3)
        port map(in1 => signed(alu_in1_EX), in2 => signed(alu_in2_EX), zero => zero_EX, std_logic_vector(result) => alu_result_EX, mode => alu_op_EX);
        
    --ABS
    ABS_comp: abs_calculator generic map(N_bit => 32)
        port map (data_in => alu_in1_EX, abs_out => abs_result_EX);

    --calc result mux
    result_mux_EX_comp : mux_2to1 generic map(N_bit => 32)
        port map( in0 => alu_result_EX, in1 => abs_result_EX, sel => sel_result_EX, sig_out => calc_result_EX);

----------------------------------PIPE EX/OS------------------------------------------------------------------------------------

    --pipe of alu result
    alu_result_OS_comp : ffd generic map (N_bit => 32)
        port map(data_in => calc_result_EX, data_out => calc_result_OS, clk => clk, rst => rst, cs => '1');

    --pipe of calculated pc/immediate
    pc_calc_imm_OS_comp : ffd generic map (N_bit => 32)
        port map(data_in => pc_calc_imm_EX, data_out => pc_calc_imm_OS, clk => clk, rst => rst, cs => '1');

    --pipe of pc+4
    pc_next_OS_comp: ffd generic map (N_bit => 32)
        port map(data_in => pc_next_EX, data_out => pc_next_OS, clk => clk, rst => rst, cs => '1');

    --pipe of r2 readed value
    read_r2_OS_comp: ffd generic map (N_bit => 32)
        port map(data_in => read_r2_EX, data_out => read_r2_OS, clk => clk, rst => rst, cs => '1');

    --pipe of alu zero signal
    zero_OS_comp: ffd_std port map (data_in => zero_EX, clk => clk, rst => rst, cs => '1', data_out => zero_OS);

    --CONTROLS
    rf_addr_wr_OS_comp : ffd generic map (N_bit => 5)
        port map(data_in => rf_addr_wr_EX, data_out => rf_addr_wr_OS, clk => clk, rst => rst, cs => '1');

    reg_wr_OS_comp: ffd_std port map (data_in => reg_wr_EX, clk => clk, rst => rst, cs => '1', data_out => reg_wr_OS);

    sel_reg_src_OS_comp: ffd generic map(N_bit => 3)
        port map (data_in => sel_reg_src_EX, clk => clk, rst => rst, cs => '1', data_out => sel_reg_src_OS);

    data_mem_wr_OS_comp: ffd_std port map (data_in => data_mem_wr_EX, clk => clk, rst => rst, cs => '1', data_out => data_mem_wr_OS);

    jal_flag_OS_comp: ffd_std port map (data_in => jal_flag_EX, clk => clk, rst => rst, cs => '1', data_out => jal_flag_OS);

----------------------------------STAGE 4-------------------------------------------------------------------------------------

    data_mem_addr <= calc_result_OS;
    data_mem_write <= read_r2_OS;
    data_mem_wr <= data_mem_wr_OS;

    condition_result_SLT_OS <= std_logic_vector(to_signed(0, 31)) & calc_result_OS(31);

    --mux OS forward source
    mux_fwd_OS_comp : mux_5to1 generic map(N_bit => 32)
        port map(in0 => calc_result_OS, in1 => pc_calc_imm_OS, in2 => pc_next_OS, in3 => data_mem_read, in4=>condition_result_SLT_OS, sel => sel_frw_imm, sig_out => forward_OS);

----------------------------------STAGE OS/WB---------------------------------------------------------------------------------

    --pipe of alu result
    alu_result_WB_comp : ffd generic map (N_bit => 32)
        port map(data_in => calc_result_OS, data_out => calc_result_WB, clk => clk, rst => rst, cs => '1');

    --pipe of calculated pc/immediate
    pc_calc_imm_WB_comp : ffd generic map (N_bit => 32)
        port map(data_in => pc_calc_imm_OS, data_out => pc_calc_imm_WB, clk => clk, rst => rst, cs => '1');

    --pipe of pc+4
    pc_next_WB_comp: ffd generic map (N_bit => 32)
        port map(data_in => pc_next_OS, data_out => pc_next_WB, clk => clk, rst => rst, cs => '1');

    --data_mem_read_WB
    data_mem_read_WB_comp: ffd generic map (N_bit => 32)
        port map(data_in => data_mem_read, data_out => data_mem_read_WB, clk => clk, rst => rst, cs => '1');

    --pipe of alu zero signal
    zero_WB_comp: ffd_std port map (data_in => zero_OS, clk => clk, rst => rst, cs => '1', data_out => zero_WB);

    --CONTROLS
    rf_addr_wr_WB_comp : ffd generic map (N_bit => 5)
        port map(data_in => rf_addr_wr_OS, data_out => rf_addr_wr_WB, clk => clk, rst => rst, cs => '1');

    reg_wr_WB_comp: ffd_std port map (data_in => reg_wr_OS, clk => clk, rst => rst, cs => '1', data_out => reg_wr_WB);

    sel_reg_src_WB_comp: ffd generic map (N_bit => 3)
        port map (data_in => sel_reg_src_OS, clk => clk, rst => rst, cs => '1', data_out => sel_reg_src_WB);


----------------------------------STAGE 5------------------------------------------------------------------------------------

condition_result_SLT <= std_logic_vector(to_signed(0, 31)) & calc_result_WB(31);

mux_rf_data_write_comp: mux_5to1 generic map(N_bit => 32)
    port map(in0 => calc_result_WB, in1 => data_mem_read_WB, in2 => condition_result_SLT, in3 => pc_calc_imm_WB, in4 => pc_next_WB, sel => sel_reg_src_WB, sig_out => rf_data_wr);

end architecture behavior;