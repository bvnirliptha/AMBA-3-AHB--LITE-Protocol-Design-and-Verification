///////////////////////////////////////////////////////////////////////////////////
// Module: AHBInterface
// Author: Nirliptha Bangalore <nir2@pdx.edu>
//	   Shrikrishna Pookala <spookala@pdx.edu>
// Description: This is a BFM that mimics the AHB Lite Master.
// Operations implemented: Read, Write, Burst Read & Write for BEATS = 4 
//			   Wait state capability not implemented for Veloce version
///////////////////////////////////////////////////////////////////////////////////
interface AHBInterface(input HCLK,input HRESETn);
// pragma attribute AHBInterface partition_interface_xif
	parameter bus_width 	= 32;
	parameter burst_size	= 3;	
	parameter transfer_type	= 2;	
	parameter BEATS		= 4;
	parameter hsize_width   = 3;
	logic [bus_width-1:0] 		HADDR;
	logic 		  		HWRITE;
	logic [hsize_width-1:0]		HSIZE;
	logic [burst_size-1:0]		HBURST;
	logic [transfer_type-1:0]	HTRANS;
	logic [bus_width-1:0]		HWDATA;
	logic [bus_width-1:0]		HRDATA;
	logic				HREADY;
	logic				HRESP;
	bit [bus_width-1:0] 		ADDR;
	int	i,j,k,n,count;
	
	
	
	// READ TASKS//
	
//  Clocked Task to read data from AHB Slave Module	
task read(input bit [31:0] addr, output logic [bus_width-1:0] data);	//pragma tbx xtf
	@(posedge HCLK);
	HADDR 	= addr;									// Address put on the Address bus
	HWRITE 	= '0;									// indicates that this is a read operation
	HSIZE	= 3'b010;								// define HSIZE as a Parameter and change it in compile time, nitially lets start with 32 bits - halfword
	HTRANS	= 2'b10;
	HBURST 	= '0;									//	signifies that it is a single burst
	
	
	@(posedge HCLK);
	@(posedge HCLK);
	data = HRDATA;  								// Get the data from the slave(RAM)
				
endtask

//BURST READ - Veloce Only - Without Wait State insertion capability
task burst_read(bit [31:0] addr, output bit [3:0][bus_width-1:0] data_burst); // pragma tbx xtf
	@(posedge HCLK);
	HADDR = addr;
	HTRANS = 2'b10;
	HWRITE = 1'b0;
	HBURST = 3'b011;
	@(posedge HCLK);
	HADDR = addr + 1;
	HTRANS = 2'b11;
	i=0;
	repeat(2) begin
		@(posedge HCLK);
		HADDR = HADDR + 1;
		data_burst[i] = HRDATA;
		i=i+1;
	end
	@(posedge HCLK);
	data_burst[i] = HRDATA;
	i=i+1;
	@(posedge HCLK);
	data_burst[i] = HRDATA;
		
endtask



// WRITE TASKS //
	
// Basic Write task with and without wait states //
//  Clocked Task to write data from AHB Slave Module	

task write(input bit[31:0] addr, input logic[31:0] data); //pragma tbx xtf
	
	@(posedge HCLK);
	HADDR 	= addr;									// Address put on the Address bus
	HWRITE 	= '1;									// indicates that this is a write operation
	HSIZE	= 3'b010;	
	HTRANS	= 2'b10;						// define HSIZE as a Parameter and change it in compile time //	initially lets start with 32 bits - halfword
	HBURST 	= '0;									//	signifies that it is a single burst
						
	
	
	@(posedge HCLK);
	HWDATA	= data;
	@(posedge HCLK);
		
endtask	

// BURST WRITE - veloce Only -- With no wait state insertion capability

task burst_write(bit[31:0] addr, input bit[3:0][31:0] data); // pragma tbx xtf
	@(posedge HCLK);	
	HTRANS = 2'b10;
	HSIZE  = 3'b010;
	HBURST = 3'b011;
	HADDR  = addr;
	HWRITE = 1'b1;
	i=0;
		repeat(3) begin
			@(posedge HCLK);
			HTRANS = 2'b11;
			HADDR  = HADDR + 1;
			HWDATA = data[i];
			i=i+1;
		end
	@(posedge HCLK);
	HWDATA= data[i];
endtask


	//Modport to AHB Slave Top  -- unnecessary signals stripped down to make it work on Veloce

	modport Slave(
					output HREADY,
					output HRESP,
					output HRDATA,
					input HADDR,
					input HWRITE,
					input HTRANS,
					input HWDATA,
					input HCLK,
					input HRESETn
					);
					
endinterface:AHBInterface

