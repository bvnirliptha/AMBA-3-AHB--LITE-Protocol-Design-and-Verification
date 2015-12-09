/*****************************************************************************************/
///////////Project  : 	ECE 571 - Verification of AHBLITE protocol///
///////////Team 	: 	Arjun Gopal, Sri Krishna, Nirliptha Bangalore, Udit Kulshreshta///
///////////Module	:	Slave Module //////////////
/*****************************************************************************************/



/*Module for AHB Slave*/
/*Synthesizable memory module*/
/***This slave has read only addresses from 00h to 03h. It uses HTRANS to see if master sends valid data**/
module AHBSlaveMemory(
	input logic HCLK,
	input logic HRESETn,
	input logic[9:0] HADDR,
	input logic [31:0] HWDATA, 
	input logic [1:0] HTRANS,
	input logic HWRITE,
	input logic HSEL,
	input logic wait_slave_to_master,
	output logic [31:0] HRDATA,
	output logic HRESP,
	output logic HREADY);

	parameter 	ADDR_SPACE    = 10;
	parameter   hsize_width   = 3;
	parameter	read_only_start_address = 10'h00;
	parameter	read_only_end_address	= 10'h03;
	//parameter 	wait_address	= 32'h00000005;
	logic		[9:0]	addr;

	
	logic	[31:0]	MemoryArray	[2**ADDR_SPACE-1:0];
	always_ff@(posedge HCLK) begin
		if(!HRESETn) begin
			HREADY <= 1'b1;
			`ifndef ERROR_INJECT
				HRESP  <= 1'b0;
			`else
				HRESP  <= 1'b1;		// ERROR INJECTION
			`endif
			
		end
		else if(HSEL) begin
			//Slave sends a zero wait state okay response and ignores the transfer if the Master is Idle or Busy
			if(HTRANS == 2'b00 || HTRANS == 2'b01) begin
				HREADY	<= 1'b1;
				HRESP	<= 1'b0;
			end
			else begin
				//make the master wait as long as wait signal is asserted
				if(wait_slave_to_master) begin
					HREADY <= 1'b0;	
					HRESP  <= 1'b0;
				end
				else begin
									

						MemoryArray[addr] <= HWDATA;
						if(HWRITE) begin
							if(HADDR >= 32'h0000_0000 && HADDR <= 32'h0000_0003) begin
								HREADY <= 1'b1;
								`ifndef ERROR_INJECT
									HRESP <= 1'b1;
								`else
									HRESP <= 1'b0;		// ERROR INJECTION
								`endif
							end
							else begin
								addr		      <= HADDR;
								`ifndef ERROR_INJECT
									HREADY <= 1'b1;
								`else
									HREADY <= 1'b0;		// ERROR INJECTION
								`endif
								HRESP  <= 1'b0;
							end
						end
						else begin
							addr		      <= HADDR;
							HRDATA <= MemoryArray[addr];
							HREADY <= 1'b1;
							HRESP  <= 1'b0;
						end
					end
//				end
			end
		end
	end
	
	
endmodule


