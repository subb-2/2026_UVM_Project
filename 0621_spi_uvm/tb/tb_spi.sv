`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_agent.sv"
`include "spi_coverage.sv"
`include "spi_driver.sv"
`include "spi_env.sv"
`include "spi_interface.sv"
`include "spi_monitor.sv"
`include "spi_scoreboard.sv"
`include "spi_seq_item.sv"
`include "spi_sequence.sv"
`include "spi_test.sv"

module tb_spi ();

    logic clk;
    logic rst;

    always #5 clk = ~clk;

    spi_if spi_if (
        clk,
        rst
    );

    spi_top dut (
        .clk      (clk),
        .rst      (rst),
        .cpol     (spi_if.cpol),
        .cpha     (spi_if.cpha),
        .clk_div  (spi_if.clk_div),
        .m_start  (spi_if.m_start),
        .m_tx_data(spi_if.m_tx_data),
        .m_rx_data(spi_if.m_rx_data),
        .m_done   (spi_if.m_done),
        .m_busy   (spi_if.m_busy),
        .s_tx_data(spi_if.s_tx_data),
        .s_rx_data(spi_if.s_rx_data),
        .s_rx_done(spi_if.s_rx_done)
    );

    assign spi_if.sclk = dut.sclk;
    assign spi_if.mosi = dut.mosi;
    assign spi_if.miso = dut.miso;
    assign spi_if.cs_n = dut.cs_n;

    initial begin
        clk = 0;
        rst = 1;
        repeat (5) @(posedge clk);
        rst = 0;
    end

    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "*", "spi_if", spi_if);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_spi, "+all");
    end
endmodule
