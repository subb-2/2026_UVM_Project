`ifndef DRIVER_SV
`define DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_seq_item.sv"

class spi_driver extends uvm_driver #(spi_seq_item);
    `uvm_component_utils(spi_driver)

    uvm_analysis_port #(spi_seq_item) ap;
    virtual spi_if spi_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual spi_if)::get(
                this, "", "spi_if", spi_if
            )) begin
            `uvm_fatal(get_type_name(),
                       "Driver에서 uvm_config_db 에러 발생.")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        spi_init();
        wait (spi_if.rst == 0);
        `uvm_info(get_type_name(),
                  "리셋 해제 확인, 트랜젝션 대기 중...",
                  UVM_MEDIUM)

        forever begin
            spi_seq_item req;
            seq_item_port.get_next_item(req);
            drive_spi(req);
            ap.write(req);
            seq_item_port.item_done();
            `uvm_info("D_CHECK", $sformatf(
                      "%s / m_done = 1", req.convert2string()), UVM_DEBUG)
        end
    endtask  //run_phase

    task spi_init();
        spi_if.drv_cb.cpol <= 0;
        spi_if.drv_cb.cpha <= 0;
        spi_if.drv_cb.clk_div <= 8'd4;
        spi_if.drv_cb.m_start <= 0;
        spi_if.drv_cb.m_tx_data <= 0;
        spi_if.drv_cb.s_tx_data <= 0;
    endtask  //uart_init

    task drive_spi(spi_seq_item req);

        @(spi_if.drv_cb);

        spi_if.drv_cb.clk_div   <= req.clk_div;
        spi_if.drv_cb.m_tx_data <= req.m_tx_data;
        spi_if.drv_cb.s_tx_data <= req.s_tx_data;

        spi_if.drv_cb.m_start   <= 1'b1;
        @(spi_if.drv_cb);
        spi_if.drv_cb.m_start <= 1'b0;
        @(spi_if.drv_cb);
        wait (spi_if.drv_cb.m_done == 1'b1);
        @(spi_if.drv_cb);

        `uvm_info(get_type_name(), $sformatf("drv spi 구동 완료 : %s",
                                             req.convert2string()), UVM_MEDIUM)

    endtask  //drive_spi

endclass  //component 

`endif
