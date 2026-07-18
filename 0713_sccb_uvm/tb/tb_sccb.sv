`include "uvm_macros.svh"
import uvm_pkg::*;

`include "sccb_interface.sv"
`include "sccb_agent.sv"
`include "sccb_coverage.sv"
`include "sccb_driver.sv"
`include "sccb_env.sv"
`include "sccb_monitor.sv"
`include "sccb_scoreboard.sv"
`include "sccb_seq_item.sv"
`include "sccb_sequence.sv"
`include "sccb_test.sv"

module tb_sccb ();

    logic clk;
    logic reset;

    always #5 clk = ~clk;

    sccb_if sccb_if (
        .clk  (clk),
        .reset(reset)
    );

    SCCB_Data_Controller dut (
        .clk  (clk),
        .reset(reset),
        .scl  (sccb_if.scl),
        .sda  (sccb_if.sda)
    );

    pullup (sccb_if.sda);

    initial begin
        clk   = 1'b0;
        reset = 1'b1;
        repeat (5) @(posedge clk);
        reset = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual sccb_if)::set(
            null, "*", "sccb_if", sccb_if
        );
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_sccb, "+all");
    end

endmodule
