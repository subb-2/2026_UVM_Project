`ifndef MONITOR_SV
`define MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_seq_item.sv"

class spi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_monitor)

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
                       "monitor에서 uvm_config_db 에러 발생.")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "SPI 모니터링 시작 ...", UVM_MEDIUM)

        forever begin
            collect_transaction();
        end
    endtask  //run_phase

    task collect_transaction();

        spi_seq_item item;

        logic [7:0] shift_mosi = 8'h00;
        logic [7:0] shift_miso = 8'h00;

        wait (spi_if.mon_cb.cs_n == 1'b0);
        //@(spi_if.mon_cb);

        for (int i = 0; i < 8; i++) begin
            if (spi_if.mon_cb.sclk == 1'b1) begin
                wait (spi_if.mon_cb.sclk == 1'b0);
            end

            wait (spi_if.mon_cb.sclk == 1'b1);
            @(spi_if.mon_cb);

            shift_mosi = {shift_mosi[6:0], spi_if.mon_cb.mosi};
            shift_miso = {shift_miso[6:0], spi_if.mon_cb.miso};

        end

        wait (spi_if.mon_cb.cs_n == 1'b1);
        @(spi_if.mon_cb);

        item           = spi_seq_item::type_id::create("mon_item");

        item.clk_div   = spi_if.mon_cb.clk_div;

        item.m_tx_data = spi_if.mon_cb.m_tx_data;
        item.s_tx_data = spi_if.mon_cb.s_tx_data;
        item.m_rx_data = spi_if.mon_cb.m_rx_data;
        item.s_rx_data = spi_if.mon_cb.s_rx_data;

        item.mosi_data = shift_mosi;
        item.miso_data = shift_miso;

        `uvm_info(get_type_name(),
                  $sformatf("mon item: %s", item.convert2string()), UVM_MEDIUM)

        ap.write(item);

        //wait(spi_if.mon_cb.m_done == 0);

        `uvm_info(get_type_name(), $sformatf("mon spi 수집 완료 : %s",
                                             item.convert2string()), UVM_MEDIUM)

    endtask  //collect_transaction

endclass  //component 

`endif
