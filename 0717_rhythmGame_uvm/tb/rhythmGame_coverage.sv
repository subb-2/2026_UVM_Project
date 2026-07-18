`ifndef COVERAGE_SV
`define COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "rhythmGame_seq_item.sv"

//템플릿 
class rhythmGame_coverage extends uvm_subscriber #(rhythmGame_seq_item);
    `uvm_component_utils(rhythmGame_coverage)

    //covergroup 만들기 위해 seq_item 필요
    rhythmGame_seq_item req;

    covergroup cg_rhythm_game;

        // 1. 노트 생성 레인 데이터 측정
        cp_lane: coverpoint req.lane_data {
            bins lane_1 = {4'b0001};
            bins lane_2 = {4'b0010};
            bins lane_3 = {4'b0100};
            bins lane_4 = {4'b1000};
        }
        // 2. 플레이어의 버튼(영역) 입력 레인 측정
        cp_region: coverpoint req.region {
            bins press_1 = {4'b0001};
            bins press_2 = {4'b0010};
            bins press_3 = {4'b0100};
            bins press_4 = {4'b1000};
            bins no_press = {4'b0000};  // 손을 뗀 상태
        }
        // 3. 교차 커버리지: 노트 위치와 손 입력 위치가 정상적으로 크로스 매치되었는가?
        cross_lane_press: cross cp_lane, cp_region;
    endgroup  // cg_rhythm_game

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_rhythm_game = new();
    endfunction  //new()

    virtual function void write(rhythmGame_seq_item t);
        req = t;
        //sample을 하면 수집됨 
        cg_rhythm_game.sample();
    endfunction

    // =========================================================================
    // [커버리지 요약 리포트]
    // =========================================================================
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info(get_type_name(), "===== Coverage Summary =====", UVM_LOW)

        // 전체 커버리지율 출력
        `uvm_info(
            get_type_name(), $sformatf(
            "    Overall             : %.1f%%", cg_rhythm_game.get_coverage()),
            UVM_LOW)

        // 1. 노트 라인 커버리지 출력
        `uvm_info(get_type_name(), $sformatf(
                  "    Lane Cover          : %.1f%%",
                  cg_rhythm_game.cp_lane.get_coverage()
                  ), UVM_LOW)

        // 2. 버튼 입력 커버리지 출력
        `uvm_info(get_type_name(), $sformatf(
                  "    Region (Press) Cover: %.1f%%",
                  cg_rhythm_game.cp_region.get_coverage()
                  ), UVM_LOW)

        // 3. 교차(Cross) 커버리지 출력
        `uvm_info(get_type_name(), $sformatf(
                  "    Cross(lane, press)  : %.1f%%",
                  cg_rhythm_game.cross_lane_press.get_coverage()
                  ), UVM_LOW)

        `uvm_info(get_type_name(), "===== Coverage Summary =====\n\n", UVM_LOW)
    endfunction

endclass  //component 

`endif
