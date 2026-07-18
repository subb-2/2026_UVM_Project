`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "i2c_seq_item.sv"

// Driver와 Monitor로부터 각각 데이터를 받기 위해 Macro 선언
`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    // 두 개의 Analysis Imp 선언
    uvm_analysis_imp_drv #(i2c_seq_item, i2c_scoreboard) drv_imp;
    uvm_analysis_imp_mon #(i2c_seq_item, i2c_scoreboard) mon_imp;

    // 기대값을 저장할 Queue 선언
    i2c_seq_item exp_queue[$];

    int pass_cnt = 0;
    int fail_cnt = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_imp = new("drv_imp", this);
        mon_imp = new("mon_imp", this);
    endfunction

    // 1. Driver에서 받은 데이터를 Queue에 저장 (Expected)
    virtual function void write_drv(i2c_seq_item item);
        i2c_seq_item item;
        exp_queue.push_back(item);
    endfunction

    // 2. Monitor에서 받은 데이터와 Queue의 데이터 비교 (Actual)
    virtual function void write_mon(i2c_seq_item item);
        i2c_seq_item exp_item;

        if (exp_queue.size() > 0) begin
            exp_item = exp_queue.pop_front(); // 먼저 들어온 기대값 꺼내기

            // WRITE 커맨드 비교: Master TX == Slave RX
            if (exp_item.rw == 1'b0) begin
                if (exp_item.m_tx_data === item.s_rx_data) begin
                    pass_cnt++;
                    `uvm_info(get_type_name(),
                              $sformatf("[PASS] WRITE: m_tx=%h s_rx=%h",
                                        exp_item.m_tx_data, item.s_rx_data),
                              UVM_MEDIUM)
                end else begin
                    fail_cnt++;
                    `uvm_error(get_type_name(), $sformatf(
                               "[FAIL] WRITE: Exp(m_tx)=%h Act(s_rx)=%h",
                               exp_item.m_tx_data,
                               item.s_rx_data
                               ))
                end
            end  // READ 커맨드 비교: Slave TX == Master RX
            else begin
                if (exp_item.s_tx_data === item.m_rx_data) begin
                    pass_cnt++;
                    `uvm_info(get_type_name(),
                              $sformatf("[PASS] READ: s_tx=%h m_rx=%h",
                                        exp_item.s_tx_data, item.m_rx_data),
                              UVM_MEDIUM)
                end else begin
                    fail_cnt++;
                    `uvm_error(get_type_name(), $sformatf(
                               "[FAIL] READ: Exp(s_tx)=%h Act(m_rx)=%h",
                               exp_item.s_tx_data,
                               item.m_rx_data
                               ))
                end
            end
        end else begin
            `uvm_error(get_type_name(),
                       "Received monitor data but expected queue is EMPTY!")
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf(
                  "===== RESULT: PASS=%0d FAIL=%0d =====", pass_cnt, fail_cnt),
                  UVM_LOW)
        if (exp_queue.size() > 0) begin
            `uvm_error(get_type_name(),
                       $sformatf("Queue not empty! %0d items remaining.",
                                 exp_queue.size()))
        end
    endfunction

endclass
`endif
