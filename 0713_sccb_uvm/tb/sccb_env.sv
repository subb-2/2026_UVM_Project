`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sccb_agent.sv"
`include "sccb_scoreboard.sv"
`include "sccb_coverage.sv"

class sccb_env extends uvm_env;
    `uvm_component_utils(sccb_env)

    sccb_agent      agt;
    sccb_scoreboard scb;
    sccb_coverage   cov; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = sccb_agent::type_id::create("agt", this);
        scb = sccb_scoreboard::type_id::create("scb", this);
        cov = sccb_coverage::type_id::create("cov", this); 
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cov.analysis_export); 
    endfunction

endclass

`endif