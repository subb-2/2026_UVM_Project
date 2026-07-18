`ifndef COVERAGE_SV
`define COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sccb_seq_item.sv"

class sccb_coverage extends uvm_subscriber #(sccb_seq_item);
    `uvm_component_utils(sccb_coverage)

    logic [7:0] cov_tx_data_m, cov_tx_data_s;

    covergroup sccb_cg_drv;
        cp_tx_data_m: coverpoint cov_tx_data_m {
            bins zero = {8'h00};
            bins alt_01 = {8'h55};
            bins alt_10 = {8'haa};
            bins lsb_only = {8'h01};
            bins msb_only = {8'h80};
            bins range0 = {[8'h00 : 8'h0f]};
            bins range1 = {[8'h10 : 8'h1f]};
            bins range2 = {[8'h20 : 8'h2f]};
            bins range3 = {[8'h30 : 8'h3f]};
            bins range4 = {[8'h40 : 8'h4f]};
            bins range5 = {[8'h50 : 8'h5f]};
            bins range6 = {[8'h60 : 8'h6f]};
            bins range7 = {[8'h70 : 8'h7f]};
            bins range8 = {[8'h80 : 8'h8f]};
            bins range9 = {[8'h90 : 8'h9f]};
            bins rangea = {[8'ha0 : 8'haf]};
            bins rangeb = {[8'hb0 : 8'hbf]};
            bins rangec = {[8'hc0 : 8'hcf]};
            bins ranged = {[8'hd0 : 8'hdf]};
            bins rangee = {[8'he0 : 8'hef]};
            bins rangef = {[8'hf0 : 8'hff]};
        }
        cp_tx_data_s: coverpoint cov_tx_data_s {
            bins zero = {8'h00};
            bins alt_01 = {8'h55};
            bins alt_10 = {8'haa};
            bins lsb_only = {8'h01};
            bins msb_only = {8'h80};
            bins range0 = {[8'h00 : 8'h0f]};
            bins range1 = {[8'h10 : 8'h1f]};
            bins range2 = {[8'h20 : 8'h2f]};
            bins range3 = {[8'h30 : 8'h3f]};
            bins range4 = {[8'h40 : 8'h4f]};
            bins range5 = {[8'h50 : 8'h5f]};
            bins range6 = {[8'h60 : 8'h6f]};
            bins range7 = {[8'h70 : 8'h7f]};
            bins range8 = {[8'h80 : 8'h8f]};
            bins range9 = {[8'h90 : 8'h9f]};
            bins rangea = {[8'ha0 : 8'haf]};
            bins rangeb = {[8'hb0 : 8'hbf]};
            bins rangec = {[8'hc0 : 8'hcf]};
            bins ranged = {[8'hd0 : 8'hdf]};
            bins rangee = {[8'he0 : 8'hef]};
            bins rangef = {[8'hf0 : 8'hff]};
        }
    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        sccb_cg_drv = new();
    endfunction  //new()

    function void write(sccb_seq_item t);
        cov_tx_data_m = t.tx_data_m;
        cov_tx_data_s = t.tx_data_s;
        sccb_cg_drv.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "    Overall : %.1f%%", sccb_cg_drv.get_coverage()), UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "    tx_data_m : %.1f%%", sccb_cg_drv.cp_tx_data_m.get_coverage()),
            UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "    tx_data_s : %.1f%%", sccb_cg_drv.cp_tx_data_s.get_coverage()),
            UVM_LOW);
        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW);

    endfunction

endclass  //component 

`endif
