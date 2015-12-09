## Source: Makefile ccnstructed keeping Sameer Ghewari's Makefile as reference

#Specify the mode- could be either puresim or veloce
#Always make sure that everything works fine in puresim before changing to veloce

MODE ?= veloce

#make all does everything
all: work build run

#Create respective work libs and map them 
work:
	vlib work.$(MODE)
	vmap work work.$(MODE)
	
#Compile/synthesize the environment
build:
	vlog top_tb.sv			#Compile the testbench 
ifeq ($(MODE),puresim)		#If mode is puresim, compile everything else
	vlog AHBInterface.sv				#Compile the interface
	vlog AHBSlaveMemory.sv				#Compile the AHBSlaveMemory module
	vlog AHBSlave_Top.sv				#Compile the Slave Top module
	vlog top_hdl.sv				#Compule the HDL top 
	velhvl -sim $(MODE)
else						#else, synthesize!
	velanalyze -extract_hvl_info +define+QUESTA top_tb.sv	#Analyze the HVL for external task calls in BFM 
	velanalyze AHBInterface.sv			#Analyze the interface for synthesis
	velanalyze top_hdl.sv		#Analyze the HDL top for synthesis 
	velanalyze AHBSlaveMemory.sv			#AHBSlaveMemory - Individual Slave Unit instance in AHB Slave Top  
	velanalyze AHBSlave_Top.sv			#Analyze the DUT for synthesis 
	velcomp -top top_hdl  	#Synthesize!
	velhvl -sim $(MODE) 
endif

run:
	vsim -c top_hdl top_tb  -do "run -all; quit" +tbxrun -l output.log
	cp transcript transcript.$(MODE)		#Record transcript 

norun:	#No run lets you control stepping etc. 
	vsim -c +tbxrun+norun top_tb top_hdl -cpppath $(CPP_PATH)
	cp transcript transcript.$(MODE)

clean:
	rm -rf tbxbindings.h modelsim.ini transcript.veloce transcript.puresim work work.puresim work.veloce transcript *~ vsim.wlf *.log dgs.dbg dmslogdir veloce.med veloce.wave veloce.map velrunopts.ini edsenv 
	


