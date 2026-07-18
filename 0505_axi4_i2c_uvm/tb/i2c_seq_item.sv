`ifndef I2C_SEQ_ITEM_SV
`define I2C_SEQ_ITEM_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_seq_item extends uvm_sequence_item;
    // driver용
    rand logic [7:0] m_tx_data;
    rand logic [7:0] s_tx_data;
    rand logic       cmd_start;
    rand logic       cmd_write;
    rand logic       cmd_read;
    rand logic       cmd_stop;

    // monitor 수집용
    logic      [6:0] addr;
    logic            rw;
    logic      [7:0] mon_data;  // SDA에서 수집한 데이터
    logic            ack;

    // 결과 확인용
    logic      [7:0] m_rx_data;
    logic      [7:0] s_rx_data;
    logic            m_done;

    constraint read_write_c {
        $countones(
            {cmd_start, cmd_write, cmd_read, cmd_stop}
        ) == 1;
    }

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(m_tx_data, UVM_ALL_ON)
        `uvm_field_int(s_tx_data, UVM_ALL_ON)
        `uvm_field_int(cmd_start, UVM_ALL_ON)
        `uvm_field_int(cmd_write, UVM_ALL_ON)
        `uvm_field_int(cmd_read, UVM_ALL_ON)
        `uvm_field_int(cmd_stop, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(rw, UVM_ALL_ON)
        `uvm_field_int(mon_data, UVM_ALL_ON)
        `uvm_field_int(ack, UVM_ALL_ON)
        `uvm_field_int(m_rx_data, UVM_ALL_ON)
        `uvm_field_int(s_rx_data, UVM_ALL_ON)
        `uvm_field_int(m_done, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "m_tx=%h s_tx=%h start=%b write=%b read=%b stop=%b | addr=%h rw=%b mon_data=%h ack=%b | m_rx=%h s_rx=%h done=%b",
            m_tx_data,
            s_tx_data,
            cmd_start,
            cmd_write,
            cmd_read,
            cmd_stop,
            addr,
            rw,
            mon_data,
            ack,
            m_rx_data,
            s_rx_data,
            m_done
        );
    endfunction
endclass
`endif
