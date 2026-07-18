`ifndef SCCB_SEQ_ITEM_SV
`define SCCB_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class sccb_seq_item extends uvm_sequence_item;

    rand logic [7:0] tx_data_m;  // Master -> Slave 보낼 데이터
    rand logic [7:0] tx_data_s;  // Slave -> Master 보낼 데이터

    logic [7:0]  rx_data_m;      // Master가 받은 데이터 (결과)
    logic [7:0]  rx_data_s;      // Slave가 받은 데이터 (결과)
    logic        rx_done;        // Slave 수신 완료

    // Monitor AXI 버스 스누핑용
    logic [3:0]  awaddr;
    logic [31:0] wdata;
    logic [3:0]  araddr;
    logic [31:0] rdata;

    `uvm_object_utils_begin(sccb_seq_item)
        `uvm_field_int(tx_data_m, UVM_ALL_ON)
        `uvm_field_int(tx_data_s, UVM_ALL_ON)
        `uvm_field_int(rx_data_m, UVM_ALL_ON)
        `uvm_field_int(rx_data_s, UVM_ALL_ON)
        `uvm_field_int(rx_done,   UVM_ALL_ON)
        `uvm_field_int(awaddr,    UVM_ALL_ON)
        `uvm_field_int(wdata,     UVM_ALL_ON)
        `uvm_field_int(araddr,    UVM_ALL_ON)
        `uvm_field_int(rdata,     UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "sccb_seq_item");
        super.new(name);
    endfunction

    function string convert2string;
        return $sformatf(
            "[Master] TX:0x%0h RX:0x%0h | [Slave] TX:0x%0h RX:0x%0h done:%0b",
            tx_data_m, rx_data_m, tx_data_s, rx_data_s, rx_done
        );
    endfunction

endclass

`endif