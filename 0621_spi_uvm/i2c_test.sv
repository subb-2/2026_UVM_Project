`ifndef I2C_SUF_UP___SV
`define I2C_SUF_UP___SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_SUF__ extends uvm_test;

    `uvm_component_utils(i2c_SUF__)

    function new(string name="i2c_SUF__", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask

    virtual function void report_phase(uvm_phase phase);
    endfunction

endclass

`endif
