`ifndef SCCB_AGENT_SV
`define SCCB_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sccb_seq_item.sv"
`include "sccb_driver.sv"
`include "sccb_monitor.sv"

typedef uvm_sequencer#(sccb_seq_item) sccb_sequencer;

class sccb_agent extends uvm_agent;
    `uvm_component_utils(sccb_agent)

    sccb_driver drv;
    sccb_monitor mon;
    sccb_sequencer sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        drv = sccb_driver::type_id::create("drv", this);
        mon = sccb_monitor::type_id::create("mon", this);
        sqr = sccb_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);    
        super.connect_phase(phase);    
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass //component 

`endif 