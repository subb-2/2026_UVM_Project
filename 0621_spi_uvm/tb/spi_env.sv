`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_agent.sv"
`include "spi_scoreboard.sv"
`include "spi_coverage.sv"

class spi_env extends uvm_env;
    `uvm_component_utils(spi_env)

    spi_agent      agt;
    spi_scoreboard scb;

    spi_coverage_exp cov_exp;
    spi_coverage_act cov_act;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = spi_agent::type_id::create("agt", this);
        scb = spi_scoreboard::type_id::create("scb", this);

        cov_exp = spi_coverage_exp::type_id::create("cov_exp", this);
        cov_act = spi_coverage_act::type_id::create("cov_act", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.drv.ap.connect(scb.exp_imp);
        agt.mon.ap.connect(scb.act_imp);

        agt.drv.ap.connect(cov_exp.analysis_export);
        agt.mon.ap.connect(cov_act.analysis_export);
    endfunction

endclass  //component 

`endif
