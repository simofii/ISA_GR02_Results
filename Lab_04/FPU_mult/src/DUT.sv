module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,SEND} state);
    
    
    FPmul FPmul_under_test(.FP_A(in_inter.A),.FP_B(in_inter.B),.clk(in_inter.clk),.FP_Z(out_inter.data));   

	shortreal A_shReal;
	shortreal B_shReal;
	shortreal out_shReal;
   
    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    state <= WAIT;
                end
                
                WAIT: begin
                    if(in_inter.valid) begin
                        in_inter.ready <= 0;
                        //out_inter.data <= in_inter.A + in_inter.B;
		        		//out_inter.data <= in_inter.A * in_inter.B;

				A_shReal = $bitstoshortreal({in_inter.A[31], in_inter.A[30:23], in_inter.A[22:0]});
				B_shReal = $bitstoshortreal({in_inter.B[31], in_inter.B[30:23], in_inter.B[22:0]});
				out_shReal = $bitstoshortreal({out_inter.data[31], out_inter.data[30:23], out_inter.data[22:0]});
		        
                $display("FPmultiplier: input A = %f, input B = %f, output OUT = %f", A_shReal, B_shReal, out_shReal);            
				$display("FPmultiplier: input A = %b, input B = %b, output OUT = %b", in_inter.A, in_inter.B, out_inter.data);
                        
			out_inter.valid <= 1;
                        state <= SEND;
                    end
                end
                
                SEND: begin
                    if(out_inter.ready) begin
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        state <= WAIT;
                    end
                end
        endcase
    end
endmodule: DUT
