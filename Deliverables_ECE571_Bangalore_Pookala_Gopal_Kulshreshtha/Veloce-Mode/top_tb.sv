/////////////////////////////////////////////////////////////////////////////
//Module	: top_tb
//Author	: Shrikrishna Pookala <spookala@pdx.edu>
//Description	: This file resides on Veloce Solo Host/Server and drives the
//		  BFM+Design that resides on Veloce Solo. This files references
//		  the tasks in the BFM hierarchically
//
//
//////////////////////////////////////////////////////////////////////////////

module top_tb;

// Packed Array to read data from burst
bit[3:0] [31:0] data_burst_read ;

// Packed Array to hold data to be written in burst
bit [3:0] [31:0]data_burst = '{32'h59, 32'h61, 32'h63, 32'h65};





/*Packet Class*/
class PacketClass;
	rand bit [31:0] Address_rand_slave1,Address_rand_slave2,Data_rand;
	//constrained address to the read/write locations of first slave
	constraint c1 {	Address_rand_slave1 >  32'h00000003;
 			Address_rand_slave1    <  32'h00000400;
	}
	//constrained address to the read/write locations of second slave
	constraint c2 {	Address_rand_slave2 >  32'h00000403;
 			Address_rand_slave2    <  32'h00000800;
	}
endclass


//Program block to drive the BFM+Design

program test();

	PacketClass pktCls; 	// Class handle

        int rd;
	int basicReadCount1,basicWriteCount1,basicReadCount2,basicWriteCount2;
	int burstReadCount1,burstWriteCount1,burstReadCount2,burstWriteCount2;
	initial begin
	pktCls = new();		// Object created
	$display("----------------------");
	$display("First Slave operations");
	$display("----------------------");
	$display("Basic operations:");
	$display("\n");
	repeat(10) begin
		assert(pktCls.randomize());
		top_hdl.AHB_BFM.write(pktCls.Address_rand_slave1,pktCls.Data_rand);
		basicWriteCount1++;
		top_hdl.AHB_BFM.read(pktCls.Address_rand_slave1, rd);
		basicReadCount1++;
		check(pktCls.Address_rand_slave1,pktCls.Data_rand,rd);
	end
	$display("----------------------");
	$display("First Slave Burst operations");
	$display("----------------------");
	top_hdl.AHB_BFM.burst_write(32'h00000006, data_burst);
	burstWriteCount1++;	
	top_hdl.AHB_BFM.burst_read(32'h00000006,data_burst_read);
        burstReadCount1++;
	check_burst(32'h00000006,data_burst,data_burst_read);	
	$display("--------------------------");
	$display("--------------------------");
	$display("Second Slave operations");
	$display("--------------------------");
	repeat(10) begin
		assert(pktCls.randomize());
		top_hdl.AHB_BFM.write(pktCls.Address_rand_slave2,pktCls.Data_rand);
		basicWriteCount2++;
		top_hdl.AHB_BFM.read(pktCls.Address_rand_slave2, rd);
		basicReadCount2++;
		check(pktCls.Address_rand_slave2,pktCls.Data_rand,rd);
	end
	$display("---------------------\n Burst operations on Slave 2");
	top_hdl.AHB_BFM.burst_write(32'h00000706, data_burst);
	burstWriteCount2++;
	top_hdl.AHB_BFM.burst_read(32'h00000706,data_burst_read);
	burstReadCount2++;
	check_burst(32'h00000706,data_burst,data_burst_read);	
	$display("--------------------------");
	$display("--------------------------");
	$stop;
		
	end
	
	//final block to display Transaction Stats
	final begin
		$display("\n**************END OF SIMULATION**********\n");
		$display ("Basic Reads on Slave 1:\t%d",basicReadCount1);
		$display ("Basic Writes on Slave 1:\t%d",basicWriteCount1);

		$display ("Basic Reads on Slave 2:\t%d",basicReadCount2);
		$display ("Basic Writes on Slave 2:\t%d",basicWriteCount2);

		$display ("Pass count:\t\t\t%d",check.pass_count);
		$display ("Fail count:\t\t\t%d",check.fail_count);
		$display ("----------------------------------------");
		$display ("Burst Reads on Slave 1:\t%d",burstReadCount1);
		$display ("Burst Writes on Slave 1:\t%d",burstWriteCount1);
		$display ("Burst Reads on Slave 2:\t%d",burstReadCount2);
		$display ("Burst Writes on Slave 2:\t%d",burstWriteCount2);
		$display ("Pass count:\t\t\t%d",check_burst.pass_count);
		$display ("Fail count:\t\t\t%d",check_burst.fail_count);
		$display("\n****************************************\n");
	end	

endprogram

test T1();

//task to check reads-writes
task check(logic [31:0] Address, logic [31:0] Data_written, logic [31:0] Data_read);
	int pass_count,fail_count;
	string CHECK;
	if(Data_written == Data_read) begin
		pass_count++;
		CHECK = "PASS";
	end
	else begin
		fail_count++;
		CHECK = "FAIL";
	end
	$display("Address:%h \t DataWritten:%h \t Data Read:%h ----- %s",Address,Data_written,Data_read,CHECK);
	
endtask

//task to check burst reads-writes
task check_burst(logic [31:0] Address, logic[3:0][31:0]Data_burst,logic[3:0][31:0]Data_burst_read);
	int pass_count,fail_count;
	string CHECK_BURST;
	logic [31:0] addr;
	addr = Address;
	if(Data_burst == Data_burst_read) begin
		pass_count++;
		CHECK_BURST = "PASS";
	end
	else begin
		fail_count++;
		CHECK_BURST = "FAIL";
	end
	$display("-----------------\n%s",CHECK_BURST);
	foreach (Data_burst[i]) begin
		$display("Address:%h \t Data written:%h \t Data Read:%h ",addr,Data_burst[i],Data_burst_read[i]);
		addr++;
	end
endtask

endmodule: top_tb
