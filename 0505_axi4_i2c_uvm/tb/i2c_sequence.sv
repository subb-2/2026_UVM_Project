`ifndef I2C_SEQUENCE_SV
`define I2C_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "i2c_seq_item.sv"

class i2c_seq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_seq)

    function new(string name = "i2c_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();

    endtask  //body

endclass  //component 

class i2c_master_write_seq extends i2c_seq;
    `uvm_object_utils(i2c_master_write_seq)

    int num_loop = 0;

    function new(string name = "i2c_master_write_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        repeat (num_loop) begin
            i2c_seq_item item = i2c_seq_item::type_id::create("item");
            start_item(item);
            // start 신호
            if (!item.randomize() with {
                    cmd_start == 1'b1;
                    cmd_write == 1'b0;
                    cmd_read == 1'b0;
                    cmd_stop == 1'b0;
                })
                `uvm_fatal("SEQ", "Rand Fail!")
            finish_item(item);

            // Addr 신호 (7'h12 주소와 Write비트 0 전송)
            // 7'h12 << 1 = 8'h24
            start_item(item);
            if (!item.randomize() with {
                    cmd_start == 1'b0;
                    cmd_write == 1'b1;
                    cmd_read == 1'b0;
                    cmd_stop == 1'b0;
                    m_tx_data == 8'h24;
                })
                `uvm_fatal("SEQ", "Rand Fail!")
            finish_item(item);

            // Data 신호
            repeat ($urandom_range(
                1, 5
            )) begin
                start_item(item);
                if (!item.randomize() with {
                        cmd_start == 1'b0;
                        cmd_write == 1'b1;
                        cmd_read == 1'b0;
                        cmd_stop == 1'b0;
                    })
                    `uvm_fatal("SEQ", "Rand Fail!")
                finish_item(item);
            end

            // Stop 신호 
            start_item(item);
            if (!item.randomize() with {
                    cmd_start == 1'b0;
                    cmd_write == 1'b0;
                    cmd_read == 1'b0;
                    cmd_stop == 1'b1;
                })
                `uvm_fatal("SEQ", "Rand Fail!")
            finish_item(item);
        end
    endtask  //body


endclass  //i2c_master_write_seq

class i2c_master_read_seq extends i2c_seq;
    `uvm_object_utils(i2c_master_read_seq)

    int num_loop = 0;

    function new(string name = "i2c_master_read_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        repeat (num_loop) begin
            i2c_seq_item item = i2c_seq_item::type_id::create("item");
            start_item(item);
            // start 신호
            if (!item.randomize() with {
                    cmd_start == 1'b1;
                    cmd_write == 1'b0;
                    cmd_read == 1'b0;
                    cmd_stop == 1'b0;
                })
                `uvm_fatal("SEQ", "Rand Fail!")
            finish_item(item);

            // Addr 신호 (7'h12 주소와 Write비트 1 전송)
            // 7'h12 << 1 = 8'h25
            start_item(item);
            if (!item.randomize() with {
                    cmd_start == 1'b0;
                    cmd_write == 1'b1;
                    cmd_read == 1'b0;
                    cmd_stop == 1'b0;
                    m_tx_data == 8'h25;
                })
                `uvm_fatal("SEQ", "Rand Fail!")
            finish_item(item);

            // Data 신호
            repeat ($urandom_range(
                1, 5
            )) begin
                start_item(item);
                if (!item.randomize() with {
                        cmd_start == 1'b0;
                        cmd_write == 1'b0;
                        cmd_read == 1'b1;
                        cmd_stop == 1'b0;
                    })
                    `uvm_fatal("SEQ", "Rand Fail!")
                finish_item(item);
            end

            // Stop 신호 
            start_item(item);
            if (!item.randomize() with {
                    cmd_start == 1'b0;
                    cmd_write == 1'b0;
                    cmd_read == 1'b0;
                    cmd_stop == 1'b1;
                })
                `uvm_fatal("SEQ", "Rand Fail!")
            finish_item(item);
        end
    endtask  //body


endclass  //i2c_master_read_seq

`endif
