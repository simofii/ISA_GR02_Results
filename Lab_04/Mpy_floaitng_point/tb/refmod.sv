class refmod extends uvm_component;
    `uvm_component_utils(refmod)
    
    packet_in tr_in;
    packet_out tr_out;
    uvm_get_port #(packet_in) in;
    uvm_put_port #(packet_out) out;
	shortreal A_shReal;
	shortreal B_shReal;
	shortreal data_shReal;
	bit[31:0] A_ret2;
	bit[31:0] B_ret2;
	bit[31:0] out_display;
    
    function new(string name = "refmod", uvm_component parent);
        super.new(name, parent);
        in = new("in", this);
        out = new("out", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr_out = packet_out::type_id::create("tr_out", this);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            in.get(tr_in);
	   
        /****************Pipe stages************/
		A_ret2 <= tr_in.A;
		B_ret2 <= tr_in.B;
		/***************************************/
		A_shReal = $bitstoshortreal({A_ret2[31], A_ret2[30:23], A_ret2[22:0]});
		B_shReal = $bitstoshortreal({B_ret2[31], B_ret2[30:23], B_ret2[22:0]});

		data_shReal = A_shReal * B_shReal;
		
		{tr_out.data[31], tr_out.data[30:23], tr_out.data[22:0]} = $shortrealtobits(data_shReal);
		out_display <= tr_out.data;

	    $display("refmod: input A = %b, input B = %b, output OUT = %b",tr_in.A, tr_in.B, out_display);
	    /****************************************/
           
			out.put(tr_out);
        end
    endtask: run_phase
endclass: refmod
