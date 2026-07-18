`ifndef DRIVER_SV
`define DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "i2c_seq_item.sv"

class i2c_driver extends uvm_driver #(i2c_seq_item);
    `uvm_component_utils(i2c_driver)

    uvm_analysis_port #(i2c_seq_item) ap;
    virtual i2c_if i2c_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual i2c_if)::get(
                this, "", "i2c_if", i2c_if
            )) begin
            `uvm_fatal(get_type_name(),
                       "Driver에서 uvm_config_db 에러 발생.")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        i2c_init();
        wait (i2c_if.rst == 0);
        `uvm_info(get_type_name(),
                  "리셋 해제 확인, 트랜젝션 대기 중...",
                  UVM_MEDIUM)

        // run_phase
        forever begin
            i2c_seq_item tx;
            seq_item_port.get_next_item(tx);
            // write 데이터 커맨드만 ap.write
            if (tx.cmd_write && tx.m_tx_data != 8'h24 && tx.m_tx_data != 8'h25) begin
                tx.rw = 1'b0;
                ap.write(tx);
            end else if (tx.cmd_read) begin
                tx.rw = 1'b1;
                ap.write(tx);
            end
            drive_i2c(tx);
            seq_item_port.item_done();
        end

    endtask  //run_phase

    task i2c_init();
        i2c_if.drv_cb.cmd_start <= 0;
        i2c_if.drv_cb.cmd_write <= 0;
        i2c_if.drv_cb.cmd_read  <= 0;
        i2c_if.drv_cb.cmd_stop  <= 0;
        i2c_if.drv_cb.m_tx_data <= 0;
        i2c_if.drv_cb.s_tx_data <= 0;
    endtask  //i2c_init


    task drive_i2c(i2c_seq_item tx);
        @(i2c_if.drv_cb);
        i2c_if.drv_cb.cmd_start <= tx.cmd_start;
        i2c_if.drv_cb.cmd_write <= tx.cmd_write;
        i2c_if.drv_cb.cmd_read  <= tx.cmd_read;
        i2c_if.drv_cb.cmd_stop  <= tx.cmd_stop;
        i2c_if.drv_cb.m_tx_data <= tx.m_tx_data;
        i2c_if.drv_cb.s_tx_data <= tx.s_tx_data;

        
        @(i2c_if.drv_cb);
        i2c_if.drv_cb.cmd_start <= 1'b0;
        i2c_if.drv_cb.cmd_write <= 1'b0;
        i2c_if.drv_cb.cmd_read  <= 1'b0;
        i2c_if.drv_cb.cmd_stop  <= 1'b0;

        // 이제 편안하게 하드웨어가 동작을 끝내길(m_done == 1) 기다립니다.
        @(i2c_if.drv_cb iff i2c_if.drv_cb.m_done == 1'b1);
        
        // 전송 완료 후 결과값 읽어서 tx에 저장
        tx.m_rx_data = i2c_if.drv_cb.m_rx_data;
        tx.s_rx_data = i2c_if.drv_cb.s_rx_data;

        `uvm_info(get_type_name(), $sformatf("drv i2c 구동 완료 : %s", tx.convert2string()), UVM_MEDIUM)
    endtask


endclass  //component 

`endif
