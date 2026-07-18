
`timescale 1 ns / 1 ps

module I2C_3_v1_0 #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
) (
    // Users to add ports here
    output wire scl,
    inout  wire sda,
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire s00_axi_awvalid,
    output wire s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire s00_axi_wvalid,
    output wire s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire s00_axi_bvalid,
    input wire s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire s00_axi_arvalid,
    output wire s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire s00_axi_rvalid,
    input wire s00_axi_rready
);

    wire       cmd_start;
    wire       cmd_write;
    wire       cmd_read;
    wire       cmd_stop;
    wire [7:0] tx_data;
    wire       ack_in;  //master가 받는 것
    wire [7:0] rx_data;
    wire       done;
    wire       ack_out;  //master가 주는 것 
    wire       busy;

    // Instantiation of Axi Bus Interface S00_AXI
    I2C_3_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) I2C_3_v1_0_S00_AXI_inst (
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .ack_in(ack_in),  //master가 받는 것
        .rx_data(rx_data),
        .done(done),
        .ack_out(ack_out),  //master가 주는 것 
        .busy(busy),
        .S_AXI_ACLK(s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR(s00_axi_awaddr),
        .S_AXI_AWPROT(s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA(s00_axi_wdata),
        .S_AXI_WSTRB(s00_axi_wstrb),
        .S_AXI_WVALID(s00_axi_wvalid),
        .S_AXI_WREADY(s00_axi_wready),
        .S_AXI_BRESP(s00_axi_bresp),
        .S_AXI_BVALID(s00_axi_bvalid),
        .S_AXI_BREADY(s00_axi_bready),
        .S_AXI_ARADDR(s00_axi_araddr),
        .S_AXI_ARPROT(s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA(s00_axi_rdata),
        .S_AXI_RRESP(s00_axi_rresp),
        .S_AXI_RVALID(s00_axi_rvalid),
        .S_AXI_RREADY(s00_axi_rready)
    );

    // Add user logic here
    I2C_Master_top U_I2C_MASTER (
        .clk(s00_axi_aclk),
        .rst(~s00_axi_aresetn),
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .ack_in(ack_in),  //master가 받는 것
        .rx_data(rx_data),
        .done(done),
        .ack_out(ack_out),  //master가 주는 것 
        .busy(busy),
        .scl(scl),
        .sda(sda)
    );
    // User logic ends

endmodule


module I2C_Master_top (
    input  wire       clk,
    input  wire       rst,
    // command port 
    input  wire       cmd_start,
    input  wire       cmd_write,
    input  wire       cmd_read,
    input  wire       cmd_stop,
    input  wire [7:0] tx_data,
    input  wire       ack_in,     //master가 받는 것
    // internal output
    output wire [7:0] rx_data,
    output wire       done,
    output wire       ack_out,    //master가 주는 것 
    output wire       busy,
    //external i2c port
    output wire       scl,
    inout  wire       sda
);

    wire sda_o, sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_master U_I2C_TOP (
        .clk(clk),
        .rst(rst),
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read(cmd_read),
        .cmd_stop(cmd_stop),
        .tx_data(tx_data),
        .ack_in(ack_in),  //master가 받는 것
        .rx_data(rx_data),
        .done(done),
        .ack_out(ack_out),  //master가 주는 것 
        .busy(busy),
        .scl(scl),
        .sda_o(sda_o),
        .sda_i(sda_i)
    );

endmodule

module i2c_master (
    input  wire       clk,
    input  wire       rst,
    // command port 
    input  wire       cmd_start,
    input  wire       cmd_write,
    input  wire       cmd_read,
    input  wire       cmd_stop,
    input  wire [7:0] tx_data,
    input  wire       ack_in,     //master가 받는 것
    // internal output
    output reg  [7:0] rx_data,
    output reg        done,
    output reg        ack_out,    //master가 주는 것 
    output wire       busy,
    //external i2c port
    output wire       scl,
    output wire       sda_o,
    input  wire       sda_i
);

    //100KHz : standard mode 
    //bit 신호를 보낼 때마다, 구간을 4개로 쪼개서 할 것임
    //실제 tick이 발생하는 속도는 400KHz로 해야 함

    localparam [2:0] IDLE = 3'b000, START = 3'b001, WAIT_CMD = 3'b010, DATA = 3'b011, DATA_ACK = 3'b100, STOP = 3'b101;

    reg [2:0] state;

    reg [7:0] div_cnt;
    reg       qtr_tick;
    reg scl_r, sda_r;
    reg [1:0] step;
    reg [7:0] tx_shift_reg, rx_shift_reg;
    reg [2:0] bit_cnt;
    reg is_read, ack_in_r;

    assign scl   = scl_r;
    assign sda_o = sda_r;
    //IDLE이 아니면 busy 
    assign busy  = (state != IDLE);

    //통신 속도 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //들어오는 clk = 100MHz
            //400MHz = {100MHz/(100KHz * 4)} - 1
            //{100_000_000 / (100_000 * 4)} - 1 = 250 - 1 = 249 
            div_cnt  <= 0;
            qtr_tick <= 1'b0;
        end else begin
            if (div_cnt == (250 - 1)) begin  // scl : 100kHz 
                div_cnt  <= 0;
                qtr_tick <= 1'b1;
            end else begin
                div_cnt  <= div_cnt + 1;
                qtr_tick <= 1'b0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            scl_r        <= 1'b1;
            sda_r        <= 1'b1;
            //busy         <= 1'b0;
            step         <= 0;
            done         <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            is_read      <= 1'b0;
            bit_cnt      <= 0;
            ack_in_r     <= 1'b1;  //nack 상태 
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    scl_r <= 1'b1;
                    sda_r <= 1'b1;
                    //busy  <= 1'b0;
                    if (cmd_start) begin
                        state <= START;
                        step  <= 0;  //한 주기를 4로 나눈 step 
                        //stop에서 idle로 넘어갈 때, 0으로 줘야하는가?
                        //위에서 assign으로 주는 것으로 변경 
                        //stop일 때 0으로 주는 것도 괜찮을거 같다고?
                        //busy  <= 1'b1; 
                    end
                end
                START: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                sda_r <= 1'b1;
                                scl_r <= 1'b1;
                                step  <= 2'd1;
                            end
                            2'd1: begin
                                sda_r <= 1'b0;
                                step  <= 2'd2;
                            end
                            2'd2: begin
                                //현 상태 유지 
                                step <= 2'd3;
                            end
                            2'd3: begin
                                scl_r <= 1'b0;
                                step  <= 2'd0;
                                //start 구간 끝났다는 의미 
                                done  <= 1'b1;
                                state <= WAIT_CMD;
                            end
                        endcase
                    end
                end
                WAIT_CMD: begin
                    step <= 0;
                    if (cmd_write) begin
                        //write이면, tx_data를 shift reg에 저장
                        tx_shift_reg <= tx_data;
                        bit_cnt <= 0;
                        is_read <= 1'b0;
                        state <= DATA;
                    end else if (cmd_read) begin
                        rx_shift_reg <= 0;
                        bit_cnt <= 0;
                        is_read <= 1'b1;
                        ack_in_r <= ack_in; //ack 넣어주고 이후에 전송 
                        state <= DATA;
                    end else if (cmd_stop) begin
                        state <= STOP;
                    end else if (cmd_start) begin
                        state <= START;
                    end
                end
                DATA: begin
                    if (qtr_tick) begin
                        //이 동작을 8번 반복해야 됨 
                        case (step)
                            2'd0: begin
                                //전송 
                                scl_r <= 1'b0;
                                //sda_r에 넣어야지 전송 
                                //입력값이 들어올 때 나가면 안됨
                                //sda_o = sda_r 
                                sda_r <= is_read ? 1'b1 : tx_shift_reg[7];
                                step  <= 2'd1;
                            end
                            2'd1: begin
                                // scl 상승 구간 
                                scl_r <= 1'b1;
                                step  <= 2'd2;

                            end
                            2'd2: begin
                                //수신 
                                scl_r <= 1'b1;
                                //read일 때 읽겠다.
                                if (is_read) begin
                                    rx_shift_reg <= {rx_shift_reg[6:0], sda_i};
                                end
                                step <= 2'd3;
                            end
                            2'd3: begin
                                //shift
                                scl_r <= 1'b0;
                                //read 아닐 때, write 상태일 때 shift 
                                //다음 비트 준비 
                                if (!is_read) begin
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end
                                step <= 2'd0;

                                if (bit_cnt == 7) begin
                                    //여기서 다시 0으로 초기화 안 해줘도 되나?
                                    state <= DATA_ACK;
                                end else begin
                                    bit_cnt <= bit_cnt + 1;
                                end
                            end
                        endcase
                    end
                end
                DATA_ACK: begin
                    //master 입장에서
                    //ack 주고, 받고
                    //nack를 줌 
                    //read, write를 먼저 판단 
                    //ack_in -> 0: ack / 1: nack 
                    //이 신호를 host 쪽에서 주는 것 
                    //cpu가 넣어주는 것 (코딩해서)
                    //받은 값은 ack_out을 통해서 host로 주는 것 
                    //**ack를 host 쪽에서 판단 
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl_r <= 1'b0;
                                //master는 1번 구간에서 보냄
                                if (is_read) begin
                                    //latching
                                    //들어온 것을 reg에 넣어두기
                                    //들어오고 다음 명령어로 넘어갈 수 있기 때문 
                                    sda_r <= ack_in_r;
                                end else begin
                                    //ack 읽어야 함
                                    //1이면 왜 input인지는 회로 보면 알게 됨 
                                    //high impedence로 만들어줘야 ack 읽을 수 있음 
                                    sda_r <= 1'b1;  // sda input 설정 , sda high impedence 설정 
                                end
                                step <= 2'd1;
                            end
                            2'd1: begin
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end
                            2'd2: begin
                                //ack는 3번째에서 받는게 좋음
                                scl_r <= 1'b1;
                                if (!is_read) begin  // ack 수신 
                                    //data 들어온 갑으로 나감 
                                    //host에게 알려주는 것 
                                    ack_out <= sda_i;
                                end
                                if (is_read) begin
                                    //read 입장에서 ack는 한 byte 받았다는 의미
                                    //한 바이트를 host 쪽으로 주기 
                                    rx_data <= rx_shift_reg;
                                end
                                step <= 2'd3;

                            end
                            2'd3: begin
                                scl_r <= 1'b0;
                                //신호를 받고 host가 다음을 어떻게 할지 알아서 결정 
                                done  <= 1'b1;
                                step  <= 2'd0;
                                state <= WAIT_CMD;
                            end
                        endcase
                    end
                end
                STOP: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                sda_r <= 1'b0;
                                scl_r <= 1'b0;
                                step  <= 2'd1;
                            end
                            2'd1: begin
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end
                            2'd2: begin
                                sda_r <= 1'b1;
                                step  <= 2'd3;
                            end
                            2'd3: begin
                                step  <= 2'd0;
                                done  <= 1'b1;
                                state <= IDLE;
                            end
                        endcase
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

