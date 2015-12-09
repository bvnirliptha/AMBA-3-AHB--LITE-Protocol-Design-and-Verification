/*****************************************************************************************/
///////////Project  : 	ECE 571 - Verification of AHBLITE protocol///
///////////Team 	: 	Arjun Gopal, Sri Krishna, Nirliptha Bangalore, Udit Kulshreshta///
///////////Module	:	Package Module //////////////
/*****************************************************************************************/



package definesPkg;

/****************SLAVE******************/

parameter 	ADDRESS_DEPTH   = 1024;
parameter	READ_ONLY_START_ADDRESS = 32'h00000000;
parameter	READ_ONLY_END_ADDRESS	= 32'h00000003;
parameter 	WAIT_ADDRESS	= 32'h00000005;


/**************INTERFACE****************/

//parameter BEATS = 4;
parameter ADDRESS_WIDTH	= 32;
parameter DATA_WIDTH	= 32;
parameter HSIZE_WIDTH	= 3;	
parameter BURST_SIZE	= 3;	
parameter TRANSFER_TYPE	= 2;	
parameter IDLE			= 2'b00; 
parameter BUSY			= 2'b01;
parameter NON_SEQ		= 2'b10;
parameter SEQ			= 2'b11;

endpackage