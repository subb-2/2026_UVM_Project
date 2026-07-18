`ifndef COVERAGE_SV
`define COVERAGE_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "i2c_seq_item.sv"

// ──────────────────────────────────────────
// 1. 드라이버 expected 값 커버리지 (송신 기준)
// ──────────────────────────────────────────
class i2c_coverage_sim extends uvm_subscriber #(i2c_seq_item);
    `uvm_component_utils(i2c_coverage_sim)

    i2c_seq_item item;

    covergroup cg_driver;
        // m_tx_data 전체 범위 0x00~0xFF
        cp_m_tx_data: coverpoint item.m_tx_data {
            bins low  = {[8'h00 : 8'h3F]};
            bins mid  = {[8'h40 : 8'h7F]};
            bins high = {[8'h80 : 8'hBF]};
            bins full = {[8'hC0 : 8'hFF]};
        }
        // s_tx_data 전체 범위 0x00~0xFF
        cp_s_tx_data: coverpoint item.s_tx_data {
            bins low  = {[8'h00 : 8'h3F]};
            bins mid  = {[8'h40 : 8'h7F]};
            bins high = {[8'h80 : 8'hBF]};
            bins full = {[8'hC0 : 8'hFF]};
        }
        // write / read 커맨드 (우리가 추가했던 rw 플래그 사용)
        cp_rw: coverpoint item.rw {
            bins write = {1'b0}; 
            bins read  = {1'b1};
        }
        // 어떤 데이터를 Read/Write 했는지 교차 검증
        cx_m_tx_rw: cross cp_m_tx_data, cp_rw;
        cx_s_tx_rw: cross cp_s_tx_data, cp_rw;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_driver = new();
    endfunction

    virtual function void write(i2c_seq_item t);
        item = t;
        cg_driver.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Driver Coverage Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    Overall    : %.1f%%", cg_driver.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    m_tx_data  : %.1f%%", cg_driver.cp_m_tx_data.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    s_tx_data  : %.1f%%", cg_driver.cp_s_tx_data.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    rw         : %.1f%%", cg_driver.cp_rw.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), "===================================\n", UVM_LOW)
    endfunction

endclass

// ──────────────────────────────────────────
// 2. 모니터 actual 값 커버리지 (수신 기준)
// ──────────────────────────────────────────
class i2c_coverage_data extends uvm_subscriber #(i2c_seq_item);
    `uvm_component_utils(i2c_coverage_data)

    i2c_seq_item item;

    covergroup cg_monitor;
        // Master가 수신한 실제 데이터 (Read 시)
        cp_m_rx_data: coverpoint item.m_rx_data {
            bins low  = {[8'h00 : 8'h3F]};
            bins mid  = {[8'h40 : 8'h7F]};
            bins high = {[8'h80 : 8'hBF]};
            bins full = {[8'hC0 : 8'hFF]};
        }
        // Slave가 수신한 실제 데이터 (Write 시)
        cp_s_rx_data: coverpoint item.s_rx_data {
            bins low  = {[8'h00 : 8'h3F]};
            bins mid  = {[8'h40 : 8'h7F]};
            bins high = {[8'h80 : 8'hBF]};
            bins full = {[8'hC0 : 8'hFF]};
        }
        // write / read 방향
        cp_rw: coverpoint item.rw {
            bins write = {1'b0}; 
            bins read  = {1'b1};
        }
        // Slave가 모든 구간의 데이터를 잘 받았는지 (Write)
        cx_s_rx_rw: cross cp_s_rx_data, cp_rw {
            ignore_bins read_ignore = binsof(cp_rw.read); // Read일 때는 s_rx_data를 무시
        }
        // Master가 모든 구간의 데이터를 잘 받았는지 (Read)
        cx_m_rx_rw: cross cp_m_rx_data, cp_rw {
            ignore_bins write_ignore = binsof(cp_rw.write); // Write일 때는 m_rx_data를 무시
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_monitor = new();
    endfunction

    virtual function void write(i2c_seq_item t);
        item = t;
        cg_monitor.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Monitor Coverage Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    Overall    : %.1f%%", cg_monitor.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    m_rx_data  : %.1f%%", cg_monitor.cp_m_rx_data.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    s_rx_data  : %.1f%%", cg_monitor.cp_s_rx_data.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    rw         : %.1f%%", cg_monitor.cp_rw.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    s_rx(W) cx : %.1f%%", cg_monitor.cx_s_rx_rw.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("    m_rx(R) cx : %.1f%%", cg_monitor.cx_m_rx_rw.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), "====================================\n", UVM_LOW)
    endfunction
endclass

`endif