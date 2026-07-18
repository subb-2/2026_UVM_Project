`ifndef I2C_SEQ_ITEM_SV
`define I2C_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_seq_item extends uvm_sequence_item;

    rand bit [7:0] data;

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="i2c_seq_item");
        super.new(name);
    endfunction

endclass

`endif
