`ifndef SPI_SEQ_ITEM_SV
`define SPI_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_seq_item extends uvm_sequence_item;

    rand logic [7:0] clk_div;
    rand logic [7:0] m_tx_data;
    rand logic [7:0] s_tx_data;

    logic            cpol       = 1'b0;
    logic            cpha       = 1'b0;
    logic            m_start;
    logic      [7:0] m_rx_data;
    logic            m_done;
    logic            m_busy;
    logic      [7:0] s_rx_data;
    logic            s_rx_done;
    logic      [7:0] mosi_data;
    logic      [7:0] miso_data;


    constraint clk_div_c {clk_div inside {8'd4, 8'd49};}

    `uvm_object_utils_begin(spi_seq_item)
        `uvm_field_int(clk_div, UVM_ALL_ON)
        `uvm_field_int(m_tx_data, UVM_ALL_ON)
        `uvm_field_int(s_tx_data, UVM_ALL_ON)
        `uvm_field_int(cpol, UVM_ALL_ON)
        `uvm_field_int(cpha, UVM_ALL_ON)
        `uvm_field_int(m_start, UVM_ALL_ON)
        `uvm_field_int(m_rx_data, UVM_ALL_ON)
        `uvm_field_int(m_done, UVM_ALL_ON)
        `uvm_field_int(m_busy, UVM_ALL_ON)
        `uvm_field_int(s_rx_data, UVM_ALL_ON)
        `uvm_field_int(s_rx_done, UVM_ALL_ON)
        `uvm_field_int(mosi_data, UVM_ALL_ON)
        `uvm_field_int(miso_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "spi_seq_item");
        super.new(name);
    endfunction  //new()

    function string convert2string;
        return $sformatf(
            "clk_div = %d, m_tx_data = %0h, s_tx_data = %0h, cpol = %0b, cpha = %0b, m_start = %0b, m_rx_data = %0h, m_done = %0b, m_busy = %0b, s_rx_data = %0h, s_rx_done = %0b, mosi_Data = %0h, miso_data = %0b",
            clk_div,
            m_tx_data,
            s_tx_data,
            cpol,
            cpha,
            m_start,
            m_rx_data,
            m_done,
            m_busy,
            s_rx_data,
            s_rx_done,
            mosi_data,
            miso_data
        );

    endfunction

endclass

`endif
