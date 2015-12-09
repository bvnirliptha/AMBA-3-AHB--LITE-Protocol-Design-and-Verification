
// Directive to define No of Slaves
`define NoOfSlaves 2

//Parameters declared
	parameter AddrBusWidth = 32; // addr bus width
	parameter DataBusWidth = 32; // Data bus width
	parameter AddrSpace = 10; //Addr space of Slave memory

// Top module for AHB Slave. Instantiates instances of Slave Memory, Decoder & Mux.

module AHBSlaveTop(AHBInterface SlaveInterface);
	
	logic [`NoOfSlaves-1:0]		HSEL;	//select line to the slaves
	logic [`NoOfSlaves-1:0][DataBusWidth-1:0] 	HRDATA_BUS;
	logic [`NoOfSlaves-1:0]		HRESP_BUS;
	logic [`NoOfSlaves-1:0]		HREADY_BUS;
	logic [`NoOfSlaves-1:0]		decode_address;

	//Address Decoder - Limit imposed on no of Slaves to 4 
	assign decode_address = SlaveInterface.HADDR[11:10];

	//Instantiation of decoder
	decoder AHB_DEC (.Decode_address(decode_address),
			 .HSEL(HSEL));
	genvar i;

	//Generate block to generate configurable No. of Slaves
	generate
		for (i=0;i<`NoOfSlaves;i++) begin
			AHBSlaveMemory AHBMemi (.HCLK(SlaveInterface.HCLK),
						.HRESETn(SlaveInterface.HRESETn),
						.HADDR(SlaveInterface.HADDR[AddrSpace-1:0]),
						.HWDATA(SlaveInterface.HWDATA),
						.HTRANS(SlaveInterface.HTRANS),
						.HWRITE(SlaveInterface.HWRITE),
						.HSEL(HSEL[i]),
						.HRDATA(HRDATA_BUS[i]),
						.HRESP(HRESP_BUS[i]),
						.HREADY(HREADY_BUS[i]));
		end
	endgenerate
	

//Parameterized Mux
//Mux channels - HRDATA,HRESP,HREADY
	always_comb begin	
		SlaveInterface.HRDATA = HRDATA_BUS[decode_address];
		if(SlaveInterface.HADDR > (`NoOfSlaves * (2** AddrSpace))) begin
			if(SlaveInterface.HTRANS ==  2'b10 || SlaveInterface.HTRANS == 2'b11) begin
				SlaveInterface.HRESP  = 1'b1;
				SlaveInterface.HREADY =	1'b0;
			end
			else begin
				SlaveInterface.HRESP  = 1'b0;
				SlaveInterface.HREADY =	1'b1;
			end
		end
		else begin
			SlaveInterface.HRESP  = HRESP_BUS[decode_address];
			SlaveInterface.HREADY = HREADY_BUS[decode_address];	
		end
	end	
	
endmodule

// Parameterized Decoder
module decoder(input logic [`NoOfSlaves-1:0] Decode_address,output logic [`NoOfSlaves-1:0] HSEL );
	assign HSEL = (`NoOfSlaves'b01) << Decode_address;
	
endmodule

