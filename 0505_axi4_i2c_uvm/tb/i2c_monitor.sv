`ifndef MONITOR_SV
`define MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "i2c_seq_item.sv"

class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)

    uvm_analysis_port #(i2c_seq_item) ap;
    virtual i2c_if i2c_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "i2c_if", i2c_if)) begin
            `uvm_fatal(get_type_name(), "monitor에서 uvm_config_db 에러 발생.")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        i2c_seq_item item;
        logic is_write = 0;
        logic is_read  = 0;
        logic [7:0] tx_data_cap = 0;
        logic [7:0] s_tx_cap = 0;

        `uvm_info(get_type_name(), "I2C 모니터링 시작 ...", UVM_MEDIUM)

        forever begin
            // 매 클럭마다 빈틈없이 버스 감시
            @(i2c_if.mon_cb);

            // 1. 드라이버가 1클럭만 쏜 짧은 명령도 무조건 낚아챔
            if (i2c_if.mon_cb.cmd_write) begin
                is_write    = 1'b1;
                is_read     = 1'b0;
                tx_data_cap = i2c_if.mon_cb.m_tx_data;
                s_tx_cap    = i2c_if.mon_cb.s_tx_data;
            end else if (i2c_if.mon_cb.cmd_read) begin
                is_write    = 1'b0;
                is_read     = 1'b1;
                tx_data_cap = i2c_if.mon_cb.m_tx_data;
                s_tx_cap    = i2c_if.mon_cb.s_tx_data;
            end

            // 2. 통신 완료 (m_done == 1) 시점에 맞춰 Scoreboard로 즉시 전송
            if (i2c_if.mon_cb.m_done) begin
                if (is_write && tx_data_cap != 8'h24 && tx_data_cap != 8'h25) begin
                    item           = i2c_seq_item::type_id::create("mon_item");
                    item.m_tx_data = tx_data_cap;
                    item.s_tx_data = s_tx_cap;
                    item.m_rx_data = i2c_if.mon_cb.m_rx_data;
                    item.s_rx_data = i2c_if.mon_cb.s_rx_data;
                    item.rw        = 1'b0;
                    
                    `uvm_info(get_type_name(), $sformatf("mon item: %s", item.convert2string()), UVM_MEDIUM)
                    ap.write(item);

                end else if (is_read) begin
                    item           = i2c_seq_item::type_id::create("mon_item");
                    item.m_tx_data = tx_data_cap;
                    item.s_tx_data = s_tx_cap;
                    item.m_rx_data = i2c_if.mon_cb.m_rx_data;
                    item.s_rx_data = i2c_if.mon_cb.s_rx_data;
                    item.rw        = 1'b1;
                    
                    `uvm_info(get_type_name(), $sformatf("mon item: %s", item.convert2string()), UVM_MEDIUM)
                    ap.write(item);
                end

                // 3. 전송 후 변수 초기화 (중복 수집 방지)
                is_write = 1'b0;
                is_read  = 1'b0;
            end
        end
    endtask

endclass
`endif