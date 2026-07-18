`ifndef SPI_SEQUENCE_SV
`define SPI_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_seq_item.sv"

class spi_seq extends uvm_sequence#(spi_seq_item);
    `uvm_object_utils(spi_seq)

    function new(string name = "spi_seq");
        super.new(name);
    endfunction //new()

    virtual task body ();
        
    endtask //body

endclass //component 

class spi_rand_data_seq extends spi_seq;
    `uvm_object_utils(spi_rand_data_seq)

    int num_loop = 0;

    function new(string name = "spi_rand_data_seq");
        super.new(name);
    endfunction  //new()

    virtual task body ();
        repeat(num_loop) begin
            spi_seq_item item = spi_seq_item::type_id::create("item");
            start_item(item);
                if(!item.randomize()) 
                `uvm_fatal(get_type_name(), "Randomize() Fail!")
            finish_item(item);
        end     
    endtask //body

endclass 

`endif 