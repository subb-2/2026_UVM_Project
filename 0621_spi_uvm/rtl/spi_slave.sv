

module spi_slave (
    input  logic       clk,
    input  logic       rst,
    input  logic       sclk,
    input  logic       mosi,
    output logic       miso,
    //input  logic       busy,
    input  logic       cs_n,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    logic edge_reg, edge_rise, edge_falling;
    logic [7:0] rx_shift_reg, tx_shift_reg;
    logic [2:0] bit_cnt;

    assign edge_rise    = (~edge_reg) & sclk;
    assign edge_falling = edge_reg & (~sclk);

    //edge detector
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 0;
        end else begin
            edge_reg <= sclk;  // 현재 sclk 값 
        end
    end

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } spi_slave_state_e;

    spi_slave_state_e state;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            miso         <= 1'bz;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
        end else begin
            rx_done      <= 1'b0;
            case (state)
                IDLE: begin
                    miso <= 1'bz;
                    rx_done      <= 1'b0;
                    if (!cs_n) begin
                        tx_shift_reg <= tx_data; //피드백 : 더미 데이터 
                        bit_cnt <= 0;
                        state <= START;
                    end
                end
                START: begin
                    //rx_data = 값을 받는 역할 
                    miso <= tx_shift_reg[7];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    state <= DATA;
                end
                DATA: begin
                    if (edge_rise) begin  // 수신 구간 
                        rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                    end
                    if (edge_falling) begin  // 송신 구간 
                        if (bit_cnt < 7) begin
                            miso <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        end
                        if (bit_cnt == 7) begin
                            state   <= STOP;
                            bit_cnt <= 0;
                            rx_data <= rx_shift_reg;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end
                STOP: begin
                    miso  <= 1'bz;
                    rx_done <= 1'b1;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
