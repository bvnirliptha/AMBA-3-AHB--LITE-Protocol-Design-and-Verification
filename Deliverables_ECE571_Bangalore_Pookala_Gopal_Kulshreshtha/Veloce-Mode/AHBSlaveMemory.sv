/*Module for AHB Slave*/
/*Module :Synthesizable memory module*/
/*Description: This slave has read only addresses from 00h to 03h. It uses HTRANS to see if master sends valid data**/

//Parameter Declaration
parameter 	ADDR_SPACE    = 10;
parameter	DATABUS_WIDTH = 32;
parameter 	HTRANS_WIDTH  = 2;
parameter       hsize_width   = 3;
parameter	read_only_start_address = 10'h00;
parameter	read_only_end_address	= 10'h03;

module AHBSlaveMemory(
	//Signals  to be connected to the Interface signals in AHB Slave Top module
	input logic HCLK,
	input logic HRESETn,
	input logic [ADDR_SPACE-1 :0] HADDR,
	input logic [DATABUS_WIDTH-1:0] HWDATA, 
	input logic [HTRANS_WIDTH-1:0] HTRANS,
	input logic HWRITE,
	input logic HSEL,
	output logic [DATABUS_WIDTH-1:0] HRDATA,
	output logic HRESP,
	output logic HREADY);

	logic		[ADDR_SPACE-1:0]	addr;

	// Memory Structure of the Slave	
	logic	[DATABUS_WIDTH-1:0]	MemoryArray	[2**ADDR_SPACE-1:0];
	always_ff@(posedge HCLK) begin
		if(!HRESETn) begin
			HREADY <= 1'b1;
			HRESP  <= 1'b0;
		end
		else if(HSEL) begin
			//Slave sends a zero wait state okay response and ignores the transfer if the Master is Idle or Busy
			if(HTRANS == 2'b00 || HTRANS == 2'b01) begin
				HREADY	<= 1'b1;
				HRESP	<= 1'b0;
			end
			else begin
					

						MemoryArray[addr] <= HWDATA;
						if(HWRITE) begin
						// Address 0 to 3 are considered read-only address.If Master tries to write, send an error response
							if(HADDR >= read_only_start_address && HADDR <= read_only_end_address) begin
								HRESP <= 1'b1;
								HREADY<= 1'b1;
							end
							else begin
						// address pipelined; OK response sent in case of valid write address
								addr		      <= HADDR;
								HREADY <= 1'b1;
								HRESP  <= 1'b0;
							end
						end
						else begin
						// address pipelined; OK response sent in case of valid read address
							addr		      <= HADDR;
							HRDATA <= MemoryArray[addr];
							HREADY <= 1'b1;
							HRESP  <= 1'b0;
						end
			end
		end
	end
	
	
endmodule


