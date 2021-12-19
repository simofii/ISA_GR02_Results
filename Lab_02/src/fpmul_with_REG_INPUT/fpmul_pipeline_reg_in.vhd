-- VHDL Entity HAVOC.FPmul_reg_in.symbol
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FPmul_reg_in IS
   PORT( 
      FP_A : IN     std_logic_vector (31 DOWNTO 0);
      FP_B : IN     std_logic_vector (31 DOWNTO 0);
      clk  : IN     std_logic;
      FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END FPmul_reg_in ;

--
-- VHDL Architecture HAVOC.FPmul_reg_in.pipeline
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- Copyright 2003-2004. V1.0
--


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ARCHITECTURE pipeline OF FPmul_reg_in IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL A_EXP           : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIG           : std_logic_vector(31 DOWNTO 0);
   SIGNAL B_EXP           : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_SIG           : std_logic_vector(31 DOWNTO 0);
   SIGNAL EXP_in          : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_neg         : std_logic;
   SIGNAL EXP_neg_stage2  : std_logic;
   SIGNAL EXP_out_round   : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_pos         : std_logic;
   SIGNAL EXP_pos_stage2  : std_logic;
   SIGNAL SIGN_out        : std_logic;
   SIGNAL SIGN_out_stage1 : std_logic;
   SIGNAL SIGN_out_stage2 : std_logic;
   SIGNAL SIG_in          : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_out_round   : std_logic_vector(27 DOWNTO 0);
   SIGNAL isINF_stage1    : std_logic;
   SIGNAL isINF_stage2    : std_logic;
   SIGNAL isINF_tab       : std_logic;
   SIGNAL isNaN           : std_logic;
   SIGNAL isNaN_stage1    : std_logic;
   SIGNAL isNaN_stage2    : std_logic;
   SIGNAL isZ_tab         : std_logic;
   SIGNAL isZ_tab_stage1  : std_logic;
   SIGNAL isZ_tab_stage2  : std_logic;
   SIGNAL FP_A_pipe, FP_B_pipe : std_logic_vector (31 DOWNTO 0);


   -- Component Declarations
   COMPONENT FPmul_stage1
   PORT (
      FP_A            : IN     std_logic_vector (31 DOWNTO 0);
      FP_B            : IN     std_logic_vector (31 DOWNTO 0);
      clk             : IN     std_logic ;
      A_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      A_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      B_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      B_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : OUT    std_logic ;
      isINF_stage1    : OUT    std_logic ;
      isNaN_stage1    : OUT    std_logic ;
      isZ_tab_stage1  : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPmul_stage2
   PORT (
      A_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      A_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      B_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      B_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : IN     std_logic ;
      clk             : IN     std_logic ;
      isINF_stage1    : IN     std_logic ;
      isNaN_stage1    : IN     std_logic ;
      isZ_tab_stage1  : IN     std_logic ;
      EXP_in          : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : OUT    std_logic ;
      EXP_pos_stage2  : OUT    std_logic ;
      SIGN_out_stage2 : OUT    std_logic ;
      SIG_in          : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_stage2    : OUT    std_logic ;
      isNaN_stage2    : OUT    std_logic ;
      isZ_tab_stage2  : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPmul_stage3
   PORT (
      EXP_in          : IN     std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : IN     std_logic ;
      EXP_pos_stage2  : IN     std_logic ;
      SIGN_out_stage2 : IN     std_logic ;
      SIG_in          : IN     std_logic_vector (27 DOWNTO 0);
      clk             : IN     std_logic ;
      isINF_stage2    : IN     std_logic ;
      isNaN_stage2    : IN     std_logic ;
      isZ_tab_stage2  : IN     std_logic ;
      EXP_neg         : OUT    std_logic ;
      EXP_out_round   : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_pos         : OUT    std_logic ;
      SIGN_out        : OUT    std_logic ;
      SIG_out_round   : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_tab       : OUT    std_logic ;
      isNaN           : OUT    std_logic ;
      isZ_tab         : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPmul_stage4
   PORT (
      EXP_neg       : IN     std_logic ;
      EXP_out_round : IN     std_logic_vector (7 DOWNTO 0);
      EXP_pos       : IN     std_logic ;
      SIGN_out      : IN     std_logic ;
      SIG_out_round : IN     std_logic_vector (27 DOWNTO 0);
      clk           : IN     std_logic ;
      isINF_tab     : IN     std_logic ;
      isNaN         : IN     std_logic ;
      isZ_tab       : IN     std_logic ;
      FP_Z          : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;

   COMPONENT ffd is
    generic(N_bit : integer := 1);
    port(
        data_in : in std_logic_vector(N_bit-1 downto 0);
        data_out : out std_logic_vector (N_bit-1 downto 0);
        clk, rst, cs: in std_logic);
    end COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : FPmul_stage1 USE ENTITY work.FPmul_stage1;
   FOR ALL : FPmul_stage2 USE ENTITY work.FPmul_stage2;
   FOR ALL : FPmul_stage3 USE ENTITY work.FPmul_stage3;
   FOR ALL : FPmul_stage4 USE ENTITY work.FPmul_stage4;
   -- pragma synthesis_on


BEGIN

    pipe_in1 : ffd generic map(N_bit => 32)
        port map (data_in => FP_A, data_out => FP_A_pipe, clk => clk, rst => '1', cs => '1');

    pipe_in2 : ffd generic map(N_bit => 32)
        port map (data_in => FP_B, data_out => FP_B_pipe, clk => clk, rst => '1', cs => '1');


   -- Instance port mappings.
   I1 : FPmul_stage1
      PORT MAP (
         FP_A            => FP_A_pipe,
         FP_B            => FP_B_pipe,
         clk             => clk,
         A_EXP           => A_EXP,
         A_SIG           => A_SIG,
         B_EXP           => B_EXP,
         B_SIG           => B_SIG,
         SIGN_out_stage1 => SIGN_out_stage1,
         isINF_stage1    => isINF_stage1,
         isNaN_stage1    => isNaN_stage1,
         isZ_tab_stage1  => isZ_tab_stage1
      );
   I2 : FPmul_stage2
      PORT MAP (
         A_EXP           => A_EXP,
         A_SIG           => A_SIG,
         B_EXP           => B_EXP,
         B_SIG           => B_SIG,
         SIGN_out_stage1 => SIGN_out_stage1,
         clk             => clk,
         isINF_stage1    => isINF_stage1,
         isNaN_stage1    => isNaN_stage1,
         isZ_tab_stage1  => isZ_tab_stage1,
         EXP_in          => EXP_in,
         EXP_neg_stage2  => EXP_neg_stage2,
         EXP_pos_stage2  => EXP_pos_stage2,
         SIGN_out_stage2 => SIGN_out_stage2,
         SIG_in          => SIG_in,
         isINF_stage2    => isINF_stage2,
         isNaN_stage2    => isNaN_stage2,
         isZ_tab_stage2  => isZ_tab_stage2
      );
   I3 : FPmul_stage3
      PORT MAP (
         EXP_in          => EXP_in,
         EXP_neg_stage2  => EXP_neg_stage2,
         EXP_pos_stage2  => EXP_pos_stage2,
         SIGN_out_stage2 => SIGN_out_stage2,
         SIG_in          => SIG_in,
         clk             => clk,
         isINF_stage2    => isINF_stage2,
         isNaN_stage2    => isNaN_stage2,
         isZ_tab_stage2  => isZ_tab_stage2,
         EXP_neg         => EXP_neg,
         EXP_out_round   => EXP_out_round,
         EXP_pos         => EXP_pos,
         SIGN_out        => SIGN_out,
         SIG_out_round   => SIG_out_round,
         isINF_tab       => isINF_tab,
         isNaN           => isNaN,
         isZ_tab         => isZ_tab
      );
   I4 : FPmul_stage4
      PORT MAP (
         EXP_neg       => EXP_neg,
         EXP_out_round => EXP_out_round,
         EXP_pos       => EXP_pos,
         SIGN_out      => SIGN_out,
         SIG_out_round => SIG_out_round,
         clk           => clk,
         isINF_tab     => isINF_tab,
         isNaN         => isNaN,
         isZ_tab       => isZ_tab,
         FP_Z          => FP_Z
      );

END pipeline;
