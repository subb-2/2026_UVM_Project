`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "i2c_scoreboard.sv"

class i2c_env extends uvm_env;
    `uvm_component_utils(i2c_env)

    i2c_agent agt;
    i2c_scoreboard scb;
    i2c_coverage_sim cov_exp;
    i2c_coverage_data cov_act;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        agt = i2c_agent::type_id::create("agt", this);
        scb = i2c_scoreboard::type_id::create("scb", this);
        cov_exp = i2c_coverage_sim::type_id::create("cov_exp", this);
        cov_act = i2c_coverage_data::type_id::create("cov_act", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);    
        super.connect_phase(phase);    
        agt.drv.ap.connect(scb.drv_imp);
        agt.mon.ap.connect(scb.mon_imp);
        agt.drv.ap.connect(cov_exp.analysis_export);
        agt.mon.ap.connect(cov_act.analysis_export);
    endfunction

endclass //component 

`endif 