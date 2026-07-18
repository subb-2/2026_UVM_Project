`ifndef MONITOR_SV
`define MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "rhythmGame_seq_item.sv"

//템플릿 
class rhythmGame_monitor extends uvm_monitor;
    `uvm_component_utils(rhythmGame_monitor)

    //통신선 필요
    uvm_analysis_port #(rhythmGame_seq_item) ap;
    virtual rhythmGame_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    //scb, cov 경우에는 report 까지 하는 경우도 있음
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual rhythmGame_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),
                       "[monitor] vif를 가져오지 못했습니다!");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        // 리셋 해제될 때까지 모니터링 대기 
        wait (vif.reset == 0); 
        `uvm_info(get_type_name(), "rhythmGame 모니터링 시작 ...",
                  UVM_MEDIUM)

        forever begin
            rhythmGame_transaction();
        end
    endtask  //run_phase

    task rhythmGame_transaction();
        //tr 받기
        rhythmGame_seq_item item;

        @(vif.mon_cb);

        if (vif.mon_cb.v_sync || vif.mon_cb.perfect || vif.mon_cb.good || vif.mon_cb.miss) begin
            item         = rhythmGame_seq_item::type_id::create("mon_item");

            // 인터페이스의 값을 아이템에 복사
                item.note_start = vif.mon_cb.note_start;
                item.lane_data  = vif.mon_cb.lane_data;
                item.region     = vif.mon_cb.region;
                item.v_sync     = vif.mon_cb.v_sync;
                item.main_state = vif.mon_cb.main_state;
                item.score      = vif.mon_cb.score;
                item.perfect    = vif.mon_cb.perfect;
                item.good       = vif.mon_cb.good;
                item.miss       = vif.mon_cb.miss;
                item.combo      = vif.mon_cb.combo;
                item.fever      = vif.mon_cb.fever;
            // `uvm_info(get_type_name(),
            //           $sformatf("mon item: %s", item.convert2string()), UVM_MEDIUM)
            // 디버깅 로그 출력
                `uvm_info(get_type_name(), $sformatf("Mon 수집 완료: lane_data=%b region=%b | perf=%b good=%b miss=%b score=%0d", 
                          item.lane_data, item.region, item.perfect, item.good, item.miss, item.score), UVM_HIGH)
            //값 전송 
            ap.write(item);
        end
    endtask  //rhythmGame_transaction

endclass  //component 

`endif
