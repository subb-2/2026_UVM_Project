`ifndef COVERAGE_SV
`define COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_seq_item.sv"

class spi_coverage_exp extends uvm_subscriber #(spi_seq_item);
    `uvm_component_utils(spi_coverage_exp)

    spi_seq_item tx;

    covergroup spi_cg_drv;
        cp_clk_div: coverpoint tx.clk_div {
            bins clk_10M = {4};
            bins clk_1M = {49};
        }

        cp_m_tx_data: coverpoint tx.m_tx_data {
            bins low_half = {[8'h00 : 8'h7F]};
            bins high_half = {[8'h80 : 8'hFF]};
        }

        cp_s_tx_data: coverpoint tx.s_tx_data {
            bins low_half = {[8'h00 : 8'h7F]};
            bins high_half = {[8'h80 : 8'hFF]};
        }
    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        spi_cg_drv = new();
    endfunction  //new()

    function void write(spi_seq_item t);
        tx = t;
        spi_cg_drv.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    Overall : %.1f%%", spi_cg_drv.get_coverage()), UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "    clk_div : %.1f%%", spi_cg_drv.cp_clk_div.get_coverage()),
            UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "    m_tx_data : %.1f%%", spi_cg_drv.cp_m_tx_data.get_coverage()),
            UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "    s_tx_data : %.1f%%", spi_cg_drv.cp_s_tx_data.get_coverage()),
            UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);

    endfunction

endclass  //component 

class spi_coverage_act extends uvm_subscriber #(spi_seq_item);
    `uvm_component_utils(spi_coverage_act)

    spi_seq_item tx;

    covergroup spi_cg_mon;
        // mosi_data
        cp_mosi_data: coverpoint tx.mosi_data {
            bins data_low       = {[8'h00 : 8'h3F]};
            bins data_mid_low   = {[8'h40 : 8'h7F]};
            bins data_mid_high  = {[8'h80 : 8'hBF]};
            bins data_high      = {[8'hC0 : 8'hFF]};
            bins data_all_zero  = {8'h00};
            bins data_all_ones  = {8'hFF};
            bins data_toggle_AA = {8'hAA}; 
            bins data_toggle_55 = {8'h55}; 
        }

        // miso_data
        cp_miso_data: coverpoint tx.miso_data {
            bins data_low       = {[8'h00 : 8'h3F]};
            bins data_mid_low   = {[8'h40 : 8'h7F]};
            bins data_mid_high  = {[8'h80 : 8'hBF]};
            bins data_high      = {[8'hC0 : 8'hFF]};
            bins data_all_zero  = {8'h00};
            bins data_all_ones  = {8'hFF};
            bins data_toggle_AA = {8'hAA};
            bins data_toggle_55 = {8'h55};
        }
    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        spi_cg_mon = new();
    endfunction  //new()

    function void write(spi_seq_item t);
        tx = t;
        spi_cg_mon.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    Overall : %.1f%%", spi_cg_mon.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    MOSI data : %.1f%%", spi_cg_mon.cp_mosi_data.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
        "    MISO data : %.1f%%", spi_cg_mon.cp_miso_data.get_coverage()),
        UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);

    endfunction

endclass  //component

`endif
