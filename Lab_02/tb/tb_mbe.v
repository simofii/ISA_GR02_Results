//`timescale 1ns

module tb_mbe ();

   wire CLK_i;
   wire RST_n_i;
   wire [31:0] DIN_i;  
   wire [63:0] DOUT_i;

   clk_gen CG(
  	   .CLK(CLK_i),
	   .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	   .RST_n (RST_n_i),
		.DATA(DIN_i));

   MBE_molt UUT(
         .sig_out(DOUT_i),
	      .in1(DIN_i),
         .in2(DIN_i));
         

   data_sink DS(
      .CLK(CLK_i),
		.RST_n(RST_n_i),
		.DIN(DOUT_i));   

endmodule

		   
