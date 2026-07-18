`timescale 1ns / 1ps


module I2C_SLAVE #(
    parameter logic [6:0] SLA_ADDR = 7'h12
) (
    input logic clk,
    input logic reset,

    input logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic done,
    output logic busy,

    input logic scl,
    inout wire  sda
);

    logic sda_o, sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_slave #(
        .SLA_ADDR(SLA_ADDR)
    ) u_i2c_slave (
        .*,
        .sda_o(sda_o),
        .sda_i(sda_i)
    );

endmodule

module i2c_slave #(
    parameter logic [6:0] SLA_ADDR = 7'h12
) (
    input logic clk,
    input logic reset,

    input logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic done,
    output logic busy,

    input  logic scl,
    output logic sda_o,
    input  logic sda_i
);

    typedef enum logic [2:0] {
        IDLE     = 3'b000,
        ADDR     = 3'b001,
        ACK_ADDR = 3'b010,
        DATA     = 3'b011,
        DATA_ACK = 3'b100
    } i2c_state_e;

    i2c_state_e state;

    logic [2:0] scl_sync, sda_sync;
    logic sda_r;
    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [3:0] bit_cnt;
    logic is_read;

    assign sda_o = sda_r;
    assign busy  = (state != IDLE);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            scl_sync <= 3'b111;
            sda_sync <= 3'b111;
        end else begin
            scl_sync <= {scl_sync[1:0], scl};
            sda_sync <= {sda_sync[1:0], sda_i};
        end
    end

    wire scl_high = (scl_sync[1] == 1'b1);
    wire scl_rise = (scl_sync[2:1] == 2'b01);
    wire scl_fall = (scl_sync[2:1] == 2'b10);

    wire sda_fall = (sda_sync[2:1] == 2'b10);
    wire sda_rise = (sda_sync[2:1] == 2'b01);

    wire start_cond = scl_high && sda_fall;
    wire stop_cond = scl_high && sda_rise;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            sda_r        <= 1'b1;
            done         <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            is_read      <= 1'b0;
            bit_cnt      <= 0;
            rx_data      <= 0;

        end else if (start_cond) begin
            state   <= ADDR;
            bit_cnt <= 0;
            sda_r   <= 1'b1;
            done    <= 1'b0;

        end else if (stop_cond) begin
            state <= IDLE;
            sda_r <= 1'b1;

        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    sda_r <= 1'b1;
                    tx_shift_reg <= 0;
                end

                ADDR: begin
                    if (scl_rise) begin
                        rx_shift_reg <= {rx_shift_reg[6:0], sda_sync[1]};
                    end
                    if (scl_fall) begin
                        if (bit_cnt == 8) begin
                            if (rx_shift_reg[7:1] == SLA_ADDR) begin
                                state   <= ACK_ADDR;
                                is_read <= rx_shift_reg[0];
                                sda_r   <= 1'b0;
                                tx_shift_reg <= tx_data;//추가
                            end else begin
                                state <= IDLE;
                            end
                            bit_cnt <= 0;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                ACK_ADDR: begin
                    if (scl_fall) begin
                        state   <= DATA;
                        bit_cnt <= 0;
                        if (is_read) begin
                            //tx_shift_reg <= tx_data; //추가 
                            //sda_r        <= tx_data[7];
                            sda_r <= tx_shift_reg[7]; //추가
                        end else begin
                            sda_r <= 1'b1;
                        end
                    end
                end

                DATA: begin
                    if (scl_rise) begin
                        if (!is_read) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], sda_sync[1]};
                            // 마지막 비트면 바로 rx_data에도 저장
                            if (bit_cnt == 7) begin
                                rx_data <= {rx_shift_reg[6:0], sda_sync[1]};
                            end
                        end
                    end
                    if (scl_fall) begin
                        if (bit_cnt == 7) begin
                            state   <= DATA_ACK;
                            bit_cnt <= 0;
                            done    <= 1'b1;
                            if (!is_read) begin
                                // rx_data <= rx_shift_reg; 
                                sda_r <= 1'b0;
                            end else begin
                                sda_r <= 1'b1;
                            end
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                            if (is_read) begin
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                sda_r        <= tx_shift_reg[6];
                            end
                        end
                    end
                end

                DATA_ACK: begin
                    if (scl_rise) begin
                        if (is_read && sda_sync[1] == 1'b1) begin
                            state <= IDLE;
                        end
                    end
                    if (scl_fall) begin
                        state <= DATA;
                        if (is_read) begin
                            tx_shift_reg <= tx_data;
                            sda_r        <= tx_data[7];
                        end else begin
                            sda_r <= 1'b1;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule


module fnd_controller (
    input         clk,
    input         reset,
    input  [13:0] fnd_in_data,
    output [ 3:0] fnd_digit,
    output [ 7:0] fnd_data
);


    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000, w_mux_4x1_out; //bit 맞추어야 함
    wire [1:0] w_digit_sel;


    // ssign fnd_digit = 4'b1110;  // to fnd an[3:0]


    digit_splitter U_DIGIT_SPL (
        .in_data(fnd_in_data),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );


    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(w_1khz)
    );


    counter_4 U_COUNTER_4 (
        .clk(w_1khz),
        .reset(reset),
        .digit_sel(w_digit_sel)
    );


    Decoder2x4 U_Decoder_2x4 (
        .digit_sel  (w_digit_sel),
        .fnd_digit_D(fnd_digit)
    );


    mux_4x1 U_Mux_4x1 (
        .sel(w_digit_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .mux_out(w_mux_4x1_out)
    );

    bcd U_BCD (
        .bcd(w_mux_4x1_out),  //sum 8bit 중에서 4bit만 사용하겠음
        .fnd_data(fnd_data) //reg가 아니라, instance 이후 왜 wire인 것일까 bcd에서 선택되었고, controller에서는 값을 연결만 하는 것  
    );


endmodule


module clk_div (
    input clk,
    input reset,
    output reg o_1khz
);

    // reg [16:0] counter_r; //module 다르니 다른 변수
    reg [$clog2(100_000):0] counter_r;  //로그로 하면 알아서 bit로 바꿔줌

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_r <= 0; // 초기화 안 하면 그냥 X로 출력함 - 일을 안함
            o_1khz <= 1'b0;
        end else begin
            if (counter_r == 99999) begin
                counter_r <= 0;
                o_1khz <= 1'b1;
            end else begin
                counter_r <= counter_r + 1; //9999까지만 가야하므로 조건 필요함
                o_1khz <= 1'b0;
            end
        end

    end
endmodule


module counter_4 (
    input        clk,
    input        reset,
    output [1:0] digit_sel
);
    // 순차논리는 항상 always 구문 사용

    reg [1:0] counter_r;

    assign digit_sel = counter_r; // reg 다음에 assign 나오기 이래야지 오류 안남

    always @(posedge clk, posedge reset) begin
        //초기화 먼저
        if (reset == 1) begin // 괄호 안에 그냥 reset만 적으면 자동적으로 1이면 실행하고 그렇긴 함
            // init counter_r을 0으로 초기화
            counter_r <= 0; //순차논리에서는 부등호 사용하고 = 사용 , 이 방향으로 내보내는데 nonblocking
        end else begin
            //to do
            counter_r <= counter_r + 1;  //2bit이므로, 0~3으로만 나옴
        end
    end
endmodule

//to select to fnd digit display
module Decoder2x4 (
    input [1:0] digit_sel,
    output reg [3:0] fnd_digit_D
);

    always @(digit_sel) begin
        case (digit_sel)
            2'b00: fnd_digit_D = 4'b1110;
            2'b01: fnd_digit_D = 4'b1101;
            2'b10: fnd_digit_D = 4'b1011;
            2'b11: fnd_digit_D = 4'b0111;
        endcase
    end
endmodule


module mux_4x1 (
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output reg [3:0] mux_out
);
    // reg o_mux_out;
    // assign mux_out = o_mux_out;


    always @(*) begin //*을 사용 = 모든 입력을 감시하겠다는 의미


        case (sel)  //선택만 하면 되는 것이므로
            2'b00: mux_out = digit_1;
            2'b01: mux_out = digit_10;
            2'b10: mux_out = digit_100;
            2'b11: mux_out = digit_1000;
        endcase
    end
endmodule

module digit_splitter (
    input  [13:0] in_data,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);

    //들어오는 값 바로 연산 - assign 문 사용
    assign digit_1 = in_data % 10;
    assign digit_10 = (in_data / 10) % 10;
    assign digit_100 = (in_data / 100) % 10;
    assign digit_1000 = (in_data/1000) % 10; //10bit 이상 되어야지 나타남 지금은 gnd 연결 sum 이 8bit 이기 때문

    //연산기 , 연산은 assign하고 always 문 둘 다 사용 가능
endmodule

module bcd (
    input [3:0] bcd,
    output reg [7:0] fnd_data // bcd에서 나와서 fnd로 들어가서 4bit라고 생각했는데, 아님, 8bit
    // reg 안 쓰면, 기본인 wire로 연결
);
    always @(bcd) begin
        case (bcd)
            4'd0: fnd_data = 8'hc0;  //fnd_data가 output data
            4'd1:
            fnd_data = 8'hf9; //bcd data 1이 들어오면 fnd_data f9가 출력됨 8'hf9를 유지한다는 의미
            4'd2: fnd_data = 8'ha4;
            4'd3: fnd_data = 8'hb0;
            4'd4: fnd_data = 8'h99;
            4'd5: fnd_data = 8'h92;
            4'd6: fnd_data = 8'h82;
            4'd7: fnd_data = 8'hf8;
            4'd8: fnd_data = 8'h80;
            4'd9: fnd_data = 8'h90;
            default:
            fnd_data = 8'hFF; //위의 경우 외의 경우에는 FF 출력 유지
        endcase
    end
endmodule

