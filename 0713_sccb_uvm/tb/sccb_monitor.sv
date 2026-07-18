`ifndef MONITOR_SV
`define MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sccb_seq_item.sv"

class sccb_monitor extends uvm_monitor;
    `uvm_component_utils(sccb_monitor)

    uvm_analysis_port #(sccb_seq_item)       ap;
    virtual sccb_if                          sccb_if;

    logic                             [7:0] tx_m_tracker;
    logic                                   busy_prev;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual sccb_if)::get(
                this, "", "sccb_if", sccb_if
            )) begin
            `uvm_fatal(get_type_name(),
                       "monitor에서 uvm_config_db 에러 발생.")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "SCCB 모니터링 시작 ...", UVM_MEDIUM)

        busy_prev = 0;
        tx_m_tracker = 0;

        forever begin
            collect_transaction();
        end
    endtask  //run_phase

    task collect_transaction();
        logic current_busy;
        sccb_seq_item item;

        @(posedge sccb_if.clk);

        //axi 버스에서 tx 레지스터(0x04)에 쓰는 데이터 엿보기
        if (sccb_if.awvalid && sccb_if.awready && sccb_if.awaddr == 4'h4 && sccb_if.wvalid && sccb_if.wready) begin
            tx_m_tracker = sccb_if.wdata[7:0];
        end

        // rx 데이터 캡쳐 : busy가 1에서 0으로 떨어지는 순간을 감지
        if (sccb_if.rvalid && sccb_if.rready && sccb_if.araddr == 4'h8) begin
            current_busy = (sccb_if.rdata & (1 << 8)) ? 1 : 0;

            if (busy_prev == 1 && current_busy == 0) begin
                item = sccb_seq_item::type_id::create("item");
                item.tx_data_m = tx_m_tracker;
                item.tx_data_s = sccb_if.tx_data;
                item.rx_data_m = sccb_if.rdata[7:0];
                item.rx_data_s = sccb_if.rx_data;
                item.rx_done = sccb_if.rx_done;

                `uvm_info(get_type_name(), $sformatf("mon item: %s",
                                                     item.convert2string()),
                          UVM_MEDIUM)

                ap.write(item);
            end
            busy_prev = current_busy;
        end

    endtask  //collect_transaction

endclass  //component 

`endif
