`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sccb_seq_item.sv"

class sccb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(sccb_scoreboard)

    uvm_analysis_imp #(sccb_seq_item, sccb_scoreboard) ap_imp;

    int pass_cnt = 0, fail_cnt = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(sccb_seq_item item);
        if ((item.tx_data_m == item.rx_data_s) &&
            (item.tx_data_s == item.rx_data_m)) begin
            `uvm_info("SCB", $sformatf("[PASS] %s", item.convert2string()), UVM_MEDIUM)
            pass_cnt++;
        end else begin
            `uvm_error("SCB", $sformatf("[FAIL] %s", item.convert2string()))
            fail_cnt++;
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        string result = (fail_cnt == 0) ? "** PASS **" : "** FAIL **";
        `uvm_info(get_type_name(), "************* SCB report ***************", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result : %s", result), UVM_MEDIUM)
        `uvm_info("SCB", $sformatf(" PASS: %0d", pass_cnt), UVM_NONE)
        `uvm_info("SCB", $sformatf(" FAIL: %0d", fail_cnt), UVM_NONE)
        `uvm_info(get_type_name(), "*****************************************", UVM_MEDIUM)
    endfunction

endclass

`endif