
module spi_top (
    input  logic       clk,
    input  logic       rst,
    input  logic       cpol,
    input  logic       cpha,
    input  logic [7:0] clk_div,
    input  logic       m_start,
    input  logic [7:0] m_tx_data,
    output logic [7:0] m_rx_data,
    output logic       m_done,
    output logic       m_busy,
    input  logic [7:0] s_tx_data,
    output logic [7:0] s_rx_data,
    output logic       s_rx_done
);

    logic sclk;
    logic mosi, miso, cs_n;


    //assign clk_div = 8'd4;
    //assign cpol = 0;
    //assign cpha = 0;

    spi_master U_SPI_MASTER (
        .clk(clk),
        .rst(rst),
        .cpol(cpol),
        .cpha(cpha),
        .clk_div(clk_div),
        .tx_data(m_tx_data),
        .start(m_start),
        .rx_data(m_rx_data),
        .done(m_done),
        .busy(m_busy),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n)
    );

    spi_slave U_SPI_SLAVE (
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n),
        .tx_data(s_tx_data),
        .rx_data(s_rx_data),
        .rx_done(s_rx_done)
    );
endmodule
