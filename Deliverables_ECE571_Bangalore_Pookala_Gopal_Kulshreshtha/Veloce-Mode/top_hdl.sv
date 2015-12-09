///////////////////////////////////////////////////////
// Module		: top_hdl
// Author		: Shrikrishna Pookala <spookala@pdx.edu>
// Description		: This file is a wrapper enclosing BFM & DUT
//////////////////////////////////////////////////////

module top_hdl;
//pragma attribute top_hdl partition_module_xrtl

bit clk,reset;

//instantiate AHB interface
AHBInterface AHB_BFM(.HCLK(clk),.HRESETn(reset));


//instantiate Slave 
AHBSlaveTop AHB_Slave_Top(.SlaveInterface(AHB_BFM.Slave));
	
// tbx clkgen
initial begin
	clk = 0;
	forever begin
	  #10 clk = ~clk;
	end
end

// tbx clkgen
initial begin
	reset = 1;
end

endmodule:top_hdl
