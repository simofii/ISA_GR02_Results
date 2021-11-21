//`timescale 1ns

module tb_fir ();

   wire CLK_i;
   wire RST_n_i;
   wire [13:0] DIN_i;
   wire [13:0] DOUT_i;
   wire VIN_i;
   wire VOUT_i;


   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   //data_maker_prova_DIN SM(.CLK(CLK_i),
   data_maker SM(.CLK(CLK_i),
	     .RST_n
         (RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .END_SIM(END_SIM_i));

   //IIR_filter UUT(.clk(CLK_i),
   //IIR_filter_reduced UUT(.clk(CLK_i),
   //IIR_filter_mask_in UUT(.clk(CLK_i),
   //IIR_filter_std_pipe UUT(.clk(CLK_i),
   IIR_filter_reduced_pipe UUT(.clk(CLK_i),
	     .rst(RST_n_i),
	     .DIN(DIN_i),
         .Vin(VIN_i),
         .DOUT(DOUT_i),
         .Vout(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));   

endmodule

		   
