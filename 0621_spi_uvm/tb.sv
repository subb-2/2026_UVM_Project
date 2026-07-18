`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "i2c_interface.sv"
`include "i2c_seq_item.sv"
`include "i2c_sequence.sv"
`include "i2c_driver.sv"
`include "i2c_monitor.sv"
`include "i2c_scoreboard.sv"
`include "i2c_coverage.sv"
`include "i2c_agent.sv"
`include "i2c_env.sv"
`include "i2c_test.sv"

module tb;

    i2c_interface intf();

    initial begin
        intf.clk = 0;
        forever #5 intf.clk = ~intf.clk;
    end

    initial begin
        intf.rst = 1;
        #20;
        intf.rst = 0;
    end

    initial begin
        run_test("i2c_test");
    end

endmodule
