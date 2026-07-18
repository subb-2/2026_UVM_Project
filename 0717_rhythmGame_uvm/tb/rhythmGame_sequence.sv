`ifndef RHYTHMGAME_SEQUENCE_SV
`define RHYTHMGAME_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "rhythmGame_seq_item.sv"

class rhythmGame_seq extends uvm_sequence #(rhythmGame_seq_item);
    `uvm_object_utils(rhythmGame_seq)

    function new(string name = "rhythmGame_seq");
        super.new(name);
    endfunction  //new()

    function automatic bit [3:0] lane_to_region(bit [3:0] lane);
        return {lane[0], lane[1], lane[2], lane[3]};
    endfunction

    // ----------------------------------------------------
    // [Helper Task 1] 노트 생성 (lane_data와 note_start 주입)
    // ----------------------------------------------------
    task send_note(bit [3:0] lane);
        rhythmGame_seq_item item;
        item = rhythmGame_seq_item::type_id::create("item");
        start_item(item);

        item.note_start = 1'b1;
        item.lane_data = lane;
        item.region = 4'b0000;
        item.v_sync = 1'b0;
        item.main_state = 3'b011;

        finish_item(item);
    endtask

    // ----------------------------------------------------
    // [Helper Task 2] 플레이어 입력 없이 v_sync만 토글하여 대기 (노트 하강)
    // ----------------------------------------------------
    task wait_frames(int num_frames);
        repeat (num_frames) begin
            rhythmGame_seq_item item;

            // v_sync = 1 (프레임 갱신 시작)
            item = rhythmGame_seq_item::type_id::create("item");
            start_item(item);
            item.note_start = 1'b0;
            item.lane_data = 4'b0000;
            item.region = 4'b0000;
            item.v_sync = 1'b1;
            item.main_state = 3'b011;
            finish_item(item);

            // v_sync = 0 (비활성화)
            item = rhythmGame_seq_item::type_id::create("item");
            start_item(item);
            item.note_start = 1'b0;
            item.lane_data  = 4'b0000;
            item.region     = 4'b0000;
            item.v_sync     = 1'b0;
            item.main_state = 3'b011;
            finish_item(item);
        end
    endtask

    // ----------------------------------------------------
    // [Helper Task 3] 판정 타이밍에 v_sync와 함께 플레이어 입력 주입
    // ----------------------------------------------------
    task press_region(bit [3:0] region_val);
        rhythmGame_seq_item item;

        // 1. 손 입력 + v_sync High
        item = rhythmGame_seq_item::type_id::create("press_high");
        start_item(item);
        item.note_start = 1'b0;
        item.lane_data  = 4'b0000;
        item.region     = region_val;
        item.v_sync     = 1'b1;
        item.main_state = 3'b011;
        finish_item(item);

        // 2. v_sync 하강 에지
        // DUT가 판정하는 순간이므로 region을 계속 유지
        item = rhythmGame_seq_item::type_id::create("press_tick");
        start_item(item);
        item.note_start = 1'b0;
        item.lane_data  = 4'b0000;
        item.region     = region_val;
        item.v_sync     = 1'b0;
        item.main_state = 3'b011;
        finish_item(item);

        // 3. 판정 후 손 입력 해제
        item = rhythmGame_seq_item::type_id::create("press_release");
        start_item(item);
        item.note_start = 1'b0;
        item.lane_data  = 4'b0000;
        item.region     = 4'b0000;
        item.v_sync     = 1'b0;
        item.main_state = 3'b011;
        finish_item(item);
    endtask  //press_region

endclass

// =========================================================================
// 1. [Perfect 시퀀스] 판정선 중앙(Y=400 부근)에서 정확히 누르는 케이스
// =========================================================================
class Perfect_seq extends rhythmGame_seq;
    `uvm_object_utils(Perfect_seq)

    function new(string name = "Perfect_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        bit [3:0] lane;

        lane = 4'b0001;

        `uvm_info(get_type_name(), "Perfect_seq 시나리오 시작!", UVM_LOW)

        send_note(lane);
        wait_frames(212);
        press_region(lane_to_region(lane));
        wait_frames(10);

        `uvm_info(get_type_name(), "Perfect_seq 시나리오 종료!", UVM_LOW)
    endtask
endclass

// =========================================================================
// 2. [Good 시퀀스] 판정선에 도달하기 약간 직전(Y=384 부근)에 일찍 누르는 케이스
// =========================================================================
class Good_seq extends rhythmGame_seq;
    `uvm_object_utils(Good_seq)

    function new(string name = "Good_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [3:0] lane;

        lane = 4'b0001;

        `uvm_info(get_type_name(), "Good_seq 시나리오 시작!", UVM_LOW)

        send_note(lane);
        wait_frames(195);
        press_region(lane_to_region(lane));
        wait_frames(10);

        `uvm_info(get_type_name(), "Good_seq 시나리오 종료!", UVM_LOW)
    endtask
endclass

// =========================================================================
// 3. [Miss 시퀀스] 버튼을 전혀 누르지 않고 지나쳐버리는 케이스
// =========================================================================
class Miss_seq extends rhythmGame_seq;
    `uvm_object_utils(Miss_seq)

    function new(string name = "Miss_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [3:0] lane;

        lane = 4'b0001;

        `uvm_info(get_type_name(), "Miss_seq 시나리오 시작!", UVM_LOW)

        send_note(lane);

        // Y=465를 지나야 Miss 발생
        wait_frames(234);
        `uvm_info(get_type_name(), "Miss_seq 시나리오 종료!", UVM_LOW)
    endtask
endclass

// =========================================================================
// 4. [조기 입력 무시 검증 시퀀스] 
//    판정존 전의 성급한 입력은 무시하고, 진짜 판정 타이밍에 정상 판정되는지 검증
// =========================================================================
class IgnoreEarlyPress_seq extends rhythmGame_seq;
    `uvm_object_utils(IgnoreEarlyPress_seq)

    function new(string name = "IgnoreEarlyPress_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [3:0] lane;

        lane = 4'b0001;
        `uvm_info(get_type_name(), "IgnoreEarlyPress_seq 시나리오 시작!",
                  UVM_LOW)

        // 1. 1번 레인 노트 생성 (Y=0)
        send_note(lane);

        // 2. 노트가 내려가는 도중 (Y=120 부근) 판정 영역보다 한참 전에 대기
        wait_frames(30);

        // 3. 판정 영역 도달 전 성급하게 손을 감지시킴 (조기 입력)
        // -> [검증 포인트 1] 이 시점에 perfect, good, miss 모두 0(무반응)이어야 합니다.
        press_region(lane_to_region(lane));

        // 4. 진짜 판정선 근처(Y=400)까지 마저 내려올 때까지 대기
        // (앞서 총 30프레임 대기 + 입력용 2프레임 소모했으므로 68프레임 추가 대기)
        wait_frames(181);

        // 5. 진짜 판정선 타이밍에 다시 입력 주입
        // -> [검증 포인트 2] 앞선 조기 입력과 무관하게 정상적으로 'perfect' 판정이 나와야 합니다.
        press_region(lane_to_region(lane));

        // 6. 결과 관찰 대기
        wait_frames(10);

        `uvm_info(get_type_name(), "IgnoreEarlyPress_seq 시나리오 종료!",
                  UVM_LOW)
    endtask
endclass


`endif
