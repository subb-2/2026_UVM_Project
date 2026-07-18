`ifndef SCCB_COMPONENT_SV
`define SCCB_COMPONENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class sccb_component extends uvm_component;
    `uvm_component_utils(sccb_component)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        
    endfunction

    virtual function void connect_phase(uvm_phase phase);    
        super.build_phase(phase);    

    endfunction

    virtual task run_phase (uvm_phase phase);
        
    endtask //run_phase

    virtual function void report_phase (uvm_phase phase);
        
    endfunction

endclass //sccb_component

`endif 
