`ifndef I2C_SEQUENCE_SV
`define I2C_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_sequence extends uvm_sequence #(i2c_seq_item);

    `uvm_object_utils(i2c_sequence)

    function new(string name="i2c_sequence");
        super.new(name);
    endfunction

    virtual task body();
        i2c_seq_item req;

        repeat (10) begin
            req = i2c_seq_item::type_id::create("req");
            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("i2c_sequence", "Randomization failed")
            end

            finish_item(req);
        end
    endtask

endclass

`endif
