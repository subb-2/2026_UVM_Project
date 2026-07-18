`include "uvm_macros.svh"
import uvm_pkg::*;

`include "i2c_agent.sv"
`include "i2c_coverage.sv"
`include "i2c_driver.sv"
`include "i2c_env.sv"
`include "i2c_interface.sv"
`include "i2c_monitor.sv"
`include "i2c_scoreboard.sv"
`include "i2c_seq_item.sv"
`include "i2c_sequence.sv"
`include "i2c_test.sv"

module tb_i2c ();

    logic clk;
    logic rst;

    always #5 clk = ~clk;

    i2c_if i2c_if (
        clk,
        rst
    );

    top_i2c dut (
        .clk(clk),
        .rst(rst),
        .cmd_start(i2c_if.cmd_start),
        .cmd_write(i2c_if.cmd_write),
        .cmd_read(i2c_if.cmd_read),
        .cmd_stop(i2c_if.cmd_stop),
        .m_tx_data(i2c_if.m_tx_data),
        .m_rx_data(i2c_if.m_rx_data),
        .s_tx_data(i2c_if.s_tx_data),
        .s_rx_data(i2c_if.s_rx_data),
        .m_done(i2c_if.m_done)
    );

    assign i2c_if.scl = dut.scl;
    assign i2c_if.sda = dut.sda;

    initial begin
        clk = 0;
        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;
    end

    initial begin
        uvm_config_db#(virtual i2c_if)::set(null, "*", "i2c_if", i2c_if);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_i2c, "+all");
    end
endmodule
