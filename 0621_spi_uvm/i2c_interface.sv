`ifndef I2C_INTERFACE_SV
`define I2C_INTERFACE_SV

interface i2c_interface;

    logic clk;
    logic rst;

    // TODO: Add DUT signals here
    logic [7:0] data;

endinterface

`endif
