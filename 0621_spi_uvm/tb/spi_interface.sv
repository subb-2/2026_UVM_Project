interface spi_if (
    input logic clk,
    input logic rst
);

    logic       cpol;
    logic       cpha;
    logic [7:0] clk_div;
    logic       m_start;
    logic [7:0] m_tx_data;
    logic [7:0] m_rx_data;
    logic       m_done;
    logic       m_busy;
    logic [7:0] s_tx_data;
    logic [7:0] s_rx_data;
    logic       s_rx_done;

    logic       sclk;
    logic       mosi;
    logic       miso;
    logic       cs_n;


    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output cpol;
        output cpha;
        output clk_div;
        output m_start;
        output m_tx_data;
        output s_tx_data;
        input m_rx_data;
        input m_done;
        input m_busy;
        input s_rx_data;
        input s_rx_done;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input cpol;
        input cpha;
        input clk_div;
        input m_start;
        input m_tx_data;
        input m_rx_data;
        input s_tx_data;
        input m_done;
        input m_busy;
        input s_rx_data;
        input s_rx_done;

        input sclk;
        input mosi;
        input miso;
        input cs_n;

    endclocking

    modport mp_drv(clocking drv_cb, input clk, input rst);
    modport mp_mon(clocking mon_cb, input clk, input rst);

endinterface  //spi_if
