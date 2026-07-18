`ifndef DRIVER_SV
`define DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "sccb_seq_item.sv"

class sccb_driver extends uvm_driver #(sccb_seq_item);
    `uvm_component_utils(sccb_driver)

    virtual sccb_if sccb_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual sccb_if)::get(this, "", "sccb_if", sccb_if))
            `uvm_fatal(get_type_name(), "Driver에서 uvm_config_db 에러 발생.")
    endfunction

    virtual task run_phase(uvm_phase phase);
        sccb_seq_item req;
        logic [31:0] rdata;

        sccb_init();
        wait (sccb_if.rst_n == 1);
        @(posedge sccb_if.clk);
        `uvm_info(get_type_name(), "리셋 해제 확인, 트랜잭션 대기 중...", UVM_MEDIUM)

        forever begin
            seq_item_port.get_next_item(req);

            // 1. Slave가 보낼 데이터 세팅
            sccb_if.tx_data <= req.tx_data_s;

            // 2. AXI Write: TX 레지스터(0x4)에 Master 송신 데이터 기록
            axi_write(4'h4, {24'h0, req.tx_data_m});

            // 3. AXI Write: CR 레지스터(0x0) Start(bit10)=1, clk_div=4
            axi_write(4'h0, 32'h0000_0404);

            // 4. Start 펄스 클리어
            axi_write(4'h0, 32'h0000_0004);

            // 5. Busy(bit8)가 0이 될 때까지 대기
            do begin
                axi_read(4'h8, rdata);
            end while ((rdata & (1 << 8)) != 0);

            // 6. 결과 캡처
            req.rx_data_m = rdata[7:0];
            req.rx_data_s = sccb_if.rx_data;
            req.rx_done   = sccb_if.rx_done;
            req.rdata     = rdata;

            `uvm_info("DRV", $sformatf("Transaction Completed: %s",
                      req.convert2string()), UVM_HIGH)

            @(posedge sccb_if.clk);
            seq_item_port.item_done();
        end
    endtask

    task sccb_init();
        sccb_if.awvalid <= 0;
        sccb_if.wvalid  <= 0;
        sccb_if.bready  <= 0;
        sccb_if.arvalid <= 0;
        sccb_if.rready  <= 0;
    endtask

    task axi_write(input [3:0] addr, input [31:0] data);
        @(posedge sccb_if.clk);
        sccb_if.awaddr  <= addr;
        sccb_if.awvalid <= 1;
        sccb_if.wdata   <= data;
        sccb_if.wstrb   <= 4'hF;
        sccb_if.wvalid  <= 1;

        fork
            begin
                wait (sccb_if.awready);
                @(posedge sccb_if.clk);
                sccb_if.awvalid <= 0;
            end
            begin
                wait (sccb_if.wready);
                @(posedge sccb_if.clk);
                sccb_if.wvalid <= 0;
            end
        join

        sccb_if.bready <= 1;
        wait (sccb_if.bvalid);
        @(posedge sccb_if.clk);
        sccb_if.bready <= 0;
    endtask

    task axi_read(input [3:0] addr, output [31:0] data);
        @(posedge sccb_if.clk);
        sccb_if.araddr  <= addr;
        sccb_if.arvalid <= 1;
        wait (sccb_if.arready);
        @(posedge sccb_if.clk);
        sccb_if.arvalid <= 0;

        sccb_if.rready <= 1;
        wait (sccb_if.rvalid);
        data = sccb_if.rdata;
        @(posedge sccb_if.clk);
        sccb_if.rready <= 0;
    endtask

endclass

`endif