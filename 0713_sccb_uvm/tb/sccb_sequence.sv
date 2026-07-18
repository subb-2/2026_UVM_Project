`ifndef SCCB_SEQUENCE_SV
`define SCCB_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sccb_seq_item.sv"

class sccb_seq extends uvm_sequence#(sccb_seq_item);
    `uvm_object_utils(sccb_seq)

    function new(string name = "sccb_seq");
        super.new(name);
    endfunction //new()

    virtual task body ();
        
    endtask //body

endclass //component 

class sccb_rand_data_seq extends sccb_seq;
    `uvm_object_utils(sccb_rand_data_seq)

    int num_loop = 10;

    function new(string name = "sccb_rand_data_seq");
        super.new(name);
    endfunction  //new()

    virtual task body ();
        repeat(num_loop) begin
            sccb_seq_item item = sccb_seq_item::type_id::create("item");
            start_item(item);
                if(!item.randomize()) 
                `uvm_fatal(get_type_name(), "Randomize() Fail!")
            finish_item(item);
        end     
    endtask //body

endclass 

`endif 