/*****************************************************************************************/
///////////Project  : 	ECE 571 - Verification of AHBLITE protocol///
///////////Team 	: 	Arjun Gopal, Sri Krishna, Nirliptha Bangalore, Udit Kulshreshta///
///////////Module	:	Interface Module //////////////
/*****************************************************************************************/


//`include "definesPkg.sv"			// including Package definition
import definesPkg::* ;				// Wildcard Import

module monitor(AHBInterface Bus,
               input reset
              );
			
//Counters to check the assertions

`define NoOfSlaves 2
int error_check_Pass,error_check_Fail;
int read_only_error_check_Pass,read_only_error_check_Fail;
int basic_write_error_check_Pass,basic_write_error_check_Fail;
int basic_read_error_check_Pass,basic_read_error_check_Fail;
int basic_burst_write_check_Pass,basic_burst_write_check_Fail;
int basic_burst_read_check_Pass,basic_burst_read_check_Fail;
int seq_check_Pass,seq_check_Fail;
int HREADY_check_Pass,HREADY_check_Fail;
int idle_check_Pass,idle_check_Fail;
int bursts_count_check4_Pass,bursts_count_check4_Fail;
int bursts_count_check8_Pass,bursts_count_check8_Fail;
int bursts_count_check16_Pass,bursts_count_check16_Fail;
int bursts_count_check_single_Pass,bursts_count_check_single_Fail;
int wait_check_Pass,wait_check_Fail;
int address_change4_Pass,address_change4_Fail;
int address_change8_Pass,address_change8_Fail;
int address_change16_Pass,address_change16_Fail;


//Property Definitions & Verification by using the assertions for AHB protocol
//this will be asserted when the slave address exceeds the limit,also applies for configuarable slaves.(Note for Krsihna:This is working,could introduce errors)
property error_check;
@(posedge Bus.HCLK) disable iff (Bus.HTRANS == BUSY || Bus.HTRANS == IDLE)
(Bus.HADDR > ((2**10)* `NoOfSlaves))|-> (Bus.HRESP == 1'b1); 
endproperty

//Checks whether the address is in the Read only Memory of Slave,in our case we have considered 1st three address as ROM (Note for Krsihna:This is working,could introduce errors)
property  read_only_error_check;
@(posedge Bus.HCLK) disable iff ( (Bus.HADDR[9:0] > 9'd3))
 (Bus.HWRITE == 1'b1) |=> (Bus.HRESP == 1);
endproperty

//assertion- for basic write -> hwrite is detected high at the 2nd clk,at the third clk,hready goes high
property basic_write;
	@(posedge Bus.HCLK) disable iff ((Bus.HTRANS==IDLE || Bus.HTRANS==BUSY) && Bus.HBURST>'0) $rose(Bus.HWRITE) |=> Bus.HREADY;
endproperty

//assertion- for basic read -> hwrite is detected low at the 2nd clk,at the third clk,hready goes high
property basic_read;
	@(posedge Bus.HCLK) disable iff ((Bus.HTRANS==IDLE || Bus.HTRANS==BUSY) && Bus.HBURST>'0 || (Bus.HADDR > ((2**10)* `NoOfSlaves))) $fell(Bus.HWRITE) |=> Bus.HREADY;
endproperty

// assertion- for burst write -> hwrite is detected high & htrans is in non sequential state at the 2nd clk,at the third clk,hready goes high,disabled if it is busy in state.
property basic_burst_write;
@(posedge Bus.HCLK)
disable iff (Bus.HTRANS == BUSY)
((Bus.HWRITE==1)&&(Bus.HTRANS == NON_SEQ) )|=>	(Bus.HREADY=='1) ;
endproperty	

// assertion- for burst write -> hwrite is detected low & htrans is in non sequential state at the 2nd clk,at the third clk,hready goes high,disabled if it is busy in busy state.
property basic_burst_read;
@(posedge Bus.HCLK)
disable iff (Bus.HTRANS == BUSY || (Bus.HADDR > ((2**10)* `NoOfSlaves)))
((Bus.HWRITE=='0)&&(Bus.HTRANS == NON_SEQ) )|=>	(Bus.HREADY=='1) ;
endproperty	

// assertion for - non_seq to seq transition
property seq_check;
@(posedge Bus.HCLK)
(( (Bus.HWRITE=='1) || (Bus.HWRITE=='0) ) && (Bus.HTRANS==NON_SEQ) ) |=> (Bus.HTRANS == SEQ);
endproperty

//assertion for HREADY -if HREADY is low then HADDR and HWRITE and HWDATA should remain in the same state until it HREADY goes high.
property HREADY_check;
@(posedge Bus.HCLK) (Bus.HREADY == 1'b0) |=> $stable (Bus.HADDR && Bus.HWRITE && Bus.HWDATA) ;
endproperty

//idle check is not implemented(Note for Krishna: Shall I remove this?)
property idle_check;
@(posedge Bus.HCLK) (Bus.HTRANS ==IDLE) |=> (Bus.HREADY == 1'b1 && Bus.HRESP == 1'b0);  // In idle state in the next clock edge hready and hresp must be 1 
endproperty                                                                           // indicating that the slave is ready for the next transfer.
  
//checks for 4 incrementing bursts whether the state transitions is going on properly,i.e. non-sequential followed by 3 sequential states
property bursts_count_check4;                                     
@(posedge Bus.HCLK) disable iff(Bus.HTRANS == BUSY || Bus.HBURST !=3'b011)  
(Bus.HTRANS == 2'b10) |=> (Bus.HTRANS == SEQ)|=> (Bus.HTRANS == SEQ)[*2];
endproperty

//checks for 8 incrementing bursts whether the state transitions is going on properly,i.e. non-sequential followed by 7 sequential states
property bursts_count_check8;                                
@(posedge Bus.HCLK)disable iff(Bus.HTRANS == BUSY || Bus.HBURST !=3'b101) 
 (Bus.HTRANS == NON_SEQ) |=> (Bus.HTRANS == SEQ)|=> (Bus.HTRANS == SEQ)[*7];
endproperty

//checks for 16 incrementing bursts whether the state transitions is going on properly,i.e. non-sequential followed by 15 sequential states
property bursts_count_check16;      
@(posedge Bus.HCLK)disable iff(Bus.HTRANS == BUSY  || Bus.HBURST !=3'b111) 
 (Bus.HTRANS == NON_SEQ) |=> (Bus.HTRANS == SEQ) |=> (Bus.HTRANS == SEQ)[*14];
endproperty

//checks for 4 incrementing bursts whether the address change is happening over period of next 3 clock cycles 
property address_change4;
@(posedge Bus.HCLK) disable iff (Bus.HBURST!=3'b011)
(Bus.HTRANS == NON_SEQ) |=> not ($stable(Bus.HADDR)[*3]);
endproperty
 
//checks for 8 incrementing bursts whether the address change is happening over period of next 7 clock cycles 
property address_change8;
@(posedge Bus.HCLK) disable iff (Bus.HBURST!=3'b101)
(Bus.HTRANS == NON_SEQ) |=> not ($stable(Bus.HADDR)[*7]); 
endproperty
 
//checks for 16 incrementing bursts whether the address change is happening over period of next 3 clock cycles 
property address_change16;
@(posedge Bus.HCLK) disable iff (Bus.HBURST!=3'b111)
(Bus.HTRANS == NON_SEQ) |=> not ($stable(Bus.HADDR)[*15]); 
 endproperty




//Assert properties and Counters to check Pass and Fail
assert property(error_check)
error_check_Pass++;
else
error_check_Fail++;

assert property(read_only_error_check)
read_only_error_check_Pass++;
else
read_only_error_check_Fail++;

assert property(basic_write)
basic_write_error_check_Pass++; 
else 
basic_write_error_check_Fail++;

assert property(basic_read) begin
basic_read_error_check_Pass++; 
end
else  begin
basic_read_error_check_Fail++;
end

assert property(basic_burst_write) begin
basic_burst_write_check_Pass++; 
end
else  begin
basic_burst_write_check_Fail++;
end

assert property(basic_burst_read) begin
basic_burst_read_check_Pass++; 
end
else  begin
basic_burst_read_check_Fail++;
end

assert property(HREADY_check)
HREADY_check_Pass++;
else
HREADY_check_Fail++;

assert property(idle_check) 
idle_check_Pass++;
else
idle_check_Fail++;


assert property(bursts_count_check4)
bursts_count_check4_Pass++;
else
bursts_count_check4_Fail++;

assert property(bursts_count_check8)
bursts_count_check8_Pass++;
else
bursts_count_check8_Fail++;

assert property(bursts_count_check16)
bursts_count_check16_Pass++;
else
bursts_count_check16_Fail++;

assert property(address_change4)
address_change4_Pass++;
else
address_change4_Fail++;

assert property(address_change8)
address_change8_Pass++;
else
address_change8_Fail++;

assert property(address_change16)
address_change16_Pass++;
else
address_change16_Fail++;




//SCorebard for Assertions.
final
begin
$display( "------------------------------------------------------------------------------------------------------");
$display( "----------------------------------------ASSERTION SCOREBOARD------------------------------------------");
$display("******************************************************************************************************");
$display(  "TYPE OF CHECK \t\t\t\tTOTAL COUNT\t\tPASS COUNT\t\t FAIL COUNT ");
$display( "------------------------------------------------------------------------------------------------------");
$display( " error_check            \t\t%d\t\t%d\t\t%d      ", (error_check_Pass+error_check_Fail),error_check_Pass,error_check_Fail);
$display( " read_only_error_check  \t\t%d\t\t%d\t\t%d      ", (read_only_error_check_Pass+read_only_error_check_Fail),read_only_error_check_Pass,read_only_error_check_Fail);
$display( " basic_write_error      \t\t%d\t\t%d\t\t%d      ", (basic_write_error_check_Pass+basic_write_error_check_Fail),basic_write_error_check_Pass,basic_write_error_check_Fail);
$display( " basic_read_error_check \t\t%d\t\t%d\t\t%d      ", (basic_read_error_check_Pass+basic_read_error_check_Fail),basic_read_error_check_Pass,basic_read_error_check_Fail);
$display( " basic_burst_write_check\t\t%d\t\t%d\t\t%d      ", (basic_burst_write_check_Pass+basic_burst_write_check_Fail),basic_burst_write_check_Pass,basic_burst_write_check_Fail);
$display( " basic_burst_read_check \t\t%d\t\t%d\t\t%d      ", (basic_burst_read_check_Pass+basic_burst_read_check_Fail),basic_burst_read_check_Pass,basic_burst_read_check_Fail);
$display( " HREADY_check           \t\t%d\t\t%d\t\t%d      ", (HREADY_check_Pass+HREADY_check_Fail),HREADY_check_Pass,HREADY_check_Fail);
$display( " bursts_count_check4    \t\t%d\t\t%d\t\t%d      ", (bursts_count_check4_Pass+bursts_count_check4_Fail),bursts_count_check4_Pass,bursts_count_check4_Fail);
$display( " bursts_count_check8    \t\t%d\t\t%d\t\t%d      ", (bursts_count_check8_Pass+bursts_count_check8_Fail),bursts_count_check8_Pass,bursts_count_check8_Fail);
$display( " bursts_count_check16   \t\t%d\t\t%d\t\t%d      ", (bursts_count_check16_Pass+bursts_count_check16_Fail),bursts_count_check16_Pass,bursts_count_check16_Fail);
$display( " address_change4        \t\t%d\t\t%d\t\t%d      ",(address_change4_Pass+address_change4_Fail),address_change4_Pass,address_change4_Fail);
$display( " address_change8        \t\t%d\t\t%d\t\t%d      ",(address_change8_Pass+address_change8_Fail),address_change8_Pass,address_change8_Fail);
$display( " address_change16       \t\t%d\t\t%d\t\t%d      ",(address_change16_Pass+address_change16_Fail),address_change16_Pass,address_change16_Fail);
end

endmodule

