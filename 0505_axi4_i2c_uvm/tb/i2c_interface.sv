interface i2c_if (
    input logic clk,
    input logic rst
);

    logic       cmd_start;
    logic       cmd_write;
    logic       cmd_read;
    logic       cmd_stop;
    logic [7:0] m_tx_data;
    logic [7:0] m_rx_data;
    logic [7:0] s_tx_data;
    logic [7:0] s_rx_data;
    logic       m_done;

    logic       scl;
    wire        sda;


    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output cmd_start;
        output cmd_write;
        output cmd_read;
        output cmd_stop;
        output m_tx_data;
        output s_tx_data;
        input m_rx_data;
        input s_rx_data;
        input m_done;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input cmd_start;
        input cmd_write;
        input cmd_read;
        input cmd_stop;
        input m_tx_data;
        input s_tx_data;
        input m_rx_data;
        input s_rx_data;
        input m_done;
        input scl;
        input sda;
    endclocking

    modport mp_drv(clocking drv_cb, input clk, input rst);
    modport mp_mon(clocking mon_cb, input clk, input rst);

endinterface  //i2c_if
