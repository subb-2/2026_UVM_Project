`ifndef SCCB_INTERFACE_SV
`define SCCB_INTERFACE_SV

interface sccb_if (
    input logic clk,
    input logic reset
);

    logic scl;
    tri   sda;

    // OV7670 slave model: 1이면 SDA를 Low로 구동하고,
    // 0이면 SDA를 해제하여 pull-up에 의해 High가 된다.
    logic slave_sda_low = 1'b0;

    assign sda = slave_sda_low ? 1'b0 : 1'bz;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        input  reset;
        input  scl;
        input  sda;
        output slave_sda_low;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input reset;
        input scl;
        input sda;
        input slave_sda_low;
    endclocking

    modport mp_drv (
        clocking drv_cb,
        input clk,
        input reset
    );

    modport mp_mon (
        clocking mon_cb,
        input clk,
        input reset
    );

endinterface

`endif
