`ifndef TEST_SV
`define TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "sccb_env.sv"
`include "sccb_sequence.sv"

class sccb_test extends uvm_test;
    `uvm_component_utils(sccb_test)

    sccb_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);    
        env = sccb_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== SCCB 계층 구조 =====", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase (uvm_phase phase);
        
    endtask //run_phase

endclass //component 

class sccb_data_rand_test extends sccb_test;
    `uvm_component_utils(sccb_data_rand_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual task run_phase (uvm_phase phase);
        sccb_rand_data_seq seq;
        //seq 
        phase.raise_objection(this);
        seq = sccb_rand_data_seq::type_id::create("seq");
        seq.num_loop = 2560;
        seq.start(env.agt.sqr);
        #500;
        phase.drop_objection(this);
    endtask //run_phase
endclass //data_rand_test

`endif 