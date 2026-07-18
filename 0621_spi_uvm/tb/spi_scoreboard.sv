`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_seq_item.sv"
`include "spi_env.sv"

`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp_exp #(spi_seq_item, spi_scoreboard) exp_imp;
    uvm_analysis_imp_act #(spi_seq_item, spi_scoreboard) act_imp;

    spi_seq_item exp_queue[$];
    spi_seq_item expected;

    int num_transactions = 0;
    int num_errors = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_imp = new("exp_imp", this);
        act_imp = new("act_imp", this);
    endfunction

    function void write_exp(spi_seq_item item);
        exp_queue.push_back(item);
        `uvm_info("SCB_EXP", $sformatf("원본 데이터 도착 및 저장: m_tx_data = %0h, s_tx_data = %0h", item.m_tx_data, item.s_tx_data), UVM_HIGH)
    endfunction

    function void write_act (spi_seq_item act);
        
        if (exp_queue.size() == 0) begin
            `uvm_error("SCB_FAIL", "정답지 없음!!!!")
            return;
        end

        expected = exp_queue.pop_front();
        num_transactions++;

        if (expected.m_tx_data !== act.mosi_data) begin
            `uvm_error(get_type_name(), $sformatf("MOSI TX FAIL!! expected = %0h, mosi = %0h", expected.m_tx_data, act.mosi_data))
            num_errors++;
        end else if (act.mosi_data != act.s_rx_data) begin
            `uvm_error(get_type_name(), $sformatf("MOSI RX FAIL!! mosi = %0h, s_rx_data = %0h", act.mosi_data, act.s_rx_data))
            num_errors++;
        end else begin
            `uvm_info(get_type_name(), $sformatf("PASS MOSI!! expected_tx = %0h, mosi = %0h, s_rx_data = %0h", expected.m_tx_data, act.mosi_data, act.s_rx_data), UVM_MEDIUM)
        end
        
        if (expected.s_tx_data !== act.miso_data) begin
            `uvm_error(get_type_name(), $sformatf("MISO TX FAIL!! expected = %0h, miso = %0h", expected.s_tx_data, act.miso_data))
            num_errors++;
        end else if (act.miso_data != act.m_rx_data) begin
            `uvm_error(get_type_name(), $sformatf("MISO RX FAIL!! miso = %0h, m_rx_data = %0h", act.miso_data, act.m_rx_data))
            num_errors++;
        end else begin
            `uvm_info(get_type_name(), $sformatf("PASS MISO!! expected_tx = %0h, miso = %0h, m_rx_data = %0h", expected.s_tx_data, act.miso_data, act.m_rx_data), UVM_MEDIUM)
        end
        

    endfunction

virtual function void report_phase(uvm_phase phase);
        string result = (num_errors == 0) ? "** PASS **" : "** FAIL **";
        `uvm_info(get_type_name(), "************* SCB report ***************", UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Result : %s", result), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Total Transactions : %0d", num_transactions), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Total Errors : %0d", num_errors), UVM_MEDIUM)
        `uvm_info(get_type_name(), "*****************************************", UVM_MEDIUM)
    endfunction

endclass  //component 

`endif
