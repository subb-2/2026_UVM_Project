`ifndef SPI_AGENT_SV
`define SPI_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_seq_item.sv"
`include "spi_driver.sv"
`include "spi_monitor.sv"

typedef uvm_sequencer#(spi_seq_item) spi_sequencer;

class spi_agent extends uvm_agent;
    `uvm_component_utils(spi_agent)

    spi_driver drv;
    spi_monitor mon;
    spi_sequencer sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        drv = spi_driver::type_id::create("drv", this);
        mon = spi_monitor::type_id::create("mon", this);
        sqr = spi_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);    
        super.connect_phase(phase);    
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass //component 

`endif 