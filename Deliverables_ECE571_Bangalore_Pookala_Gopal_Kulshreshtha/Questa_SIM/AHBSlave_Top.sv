/*****************************************************************************************/
///////////Project  : 	ECE 571 - Verification of AHBLITE protocol///
///////////Team 	: 	Arjun Gopal, Sri Krishna, Nirliptha Bangalore, Udit Kulshreshta///
///////////Module	:	Slave Top Module //////////////
/*****************************************************************************************/


//	let NoOfSlaves = 2;
`define NoOfSlaves 2
	parameter AddrBusWidth = 32; // addr bus width
	parameter AddrSpace = 10; //Addr space of Slave memory

module AHBSlaveTop(AHBInterface SlaveInterface,input wait_slave_to_master);
	
	logic [`NoOfSlaves-1:0]		HSEL;	//select line to the slaves
	logic [`NoOfSlaves-1:0][31:0] 	HRDATA_BUS;
	logic [`NoOfSlaves-1:0]		HRESP_BUS;
	logic [`NoOfSlaves-1:0]		HREADY_BUS;
	logic [`NoOfSlaves-1:0]		decode_address;

	assign decode_address = SlaveInterface.HADDR[AddrSpace+$clog2(`NoOfSlaves)-1:AddrSpace];
	//Instantiation of decoder
	decoder AHB_DEC (.Decode_address(decode_address),
			 .HSEL(HSEL));
	genvar i;
	generate
		for (i=0;i<`NoOfSlaves;i++) begin
			AHBSlaveMemory AHBMemi (.HCLK(SlaveInterface.HCLK),
						.HRESETn(SlaveInterface.HRESETn),
						.HADDR(SlaveInterface.HADDR[AddrSpace-1:0]),
						.HWDATA(SlaveInterface.HWDATA),
						.HTRANS(SlaveInterface.HTRANS),
						.HWRITE(SlaveInterface.HWRITE),
						.HSEL(HSEL[i]),
						.wait_slave_to_master(wait_slave_to_master),
						.HRDATA(HRDATA_BUS[i]),
						.HRESP(HRESP_BUS[i]),
						.HREADY(HREADY_BUS[i]));
		end
	endgenerate
	
	//assign 
	//default slave response incorporated

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
	//initial $monitor ("%m -- HRDATA: %h \tSlaveInterface.HADDR:%h",HRDATA_BUS[decode_address],SlaveInterface.HADDR);
	
endmodule


module decoder(input logic [`NoOfSlaves-1:0] Decode_address,output logic [`NoOfSlaves-1:0] HSEL );
	//logic [`NoOfSlaves-1:0] HSEL;
	assign HSEL = (`NoOfSlaves'b01) << Decode_address;
//	initial $monitor ("%m--decoded address is %h \t HSEL is %b",Decode_address,HSEL);
	
endmodule

//source: http://ece224web.groups.et.byu.net/lectures/A2%20VERILOG.pdf