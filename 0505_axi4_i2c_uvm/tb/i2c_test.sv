`ifndef TEST_SV
`define TEST_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "i2c_env.sv"
`include "i2c_sequence.sv"

// ──────────────────────────────────────────
// base test
// ──────────────────────────────────────────
class i2c_base_test extends uvm_test;
    `uvm_component_utils(i2c_base_test)

    i2c_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = i2c_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

endclass

// ──────────────────────────────────────────
// write test
// ──────────────────────────────────────────
class i2c_write_test extends i2c_base_test;
    `uvm_component_utils(i2c_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        i2c_master_write_seq seq;
        seq = i2c_master_write_seq::type_id::create("seq");

        phase.raise_objection(this);
        seq.num_loop = 10;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

endclass

// ──────────────────────────────────────────
// read test
// ──────────────────────────────────────────
class i2c_read_test extends i2c_base_test;
    `uvm_component_utils(i2c_read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        i2c_master_read_seq seq;
        seq = i2c_master_read_seq::type_id::create("seq");

        phase.raise_objection(this);
        seq.num_loop = 10;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

endclass

// ──────────────────────────────────────────
// write + read 같이 도는 test
// ──────────────────────────────────────────
class i2c_full_test extends i2c_base_test;
    `uvm_component_utils(i2c_full_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        i2c_master_write_seq write_seq;
        i2c_master_read_seq  read_seq;
        write_seq = i2c_master_write_seq::type_id::create("write_seq");
        read_seq  = i2c_master_read_seq::type_id::create("read_seq");

        phase.raise_objection(this);
        write_seq.num_loop = 10;
        write_seq.start(env.agt.sqr);
        read_seq.num_loop = 10;
        read_seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

endclass

`endif