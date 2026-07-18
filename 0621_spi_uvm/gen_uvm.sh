#!/bin/bash
set -e

P=$1

if [ -z "$P" ]; then
    echo "Usage: ./gen_uvm.sh <prefix>"
    echo "Example: ./gen_uvm.sh spi"
    exit 1
fi

UP=$(echo "$P" | tr '[:lower:]' '[:upper:]')

gen_component () {
    local SUF=$1
    local BASE=$2
    local FILE="${P}_${SUF}.sv"
    local SUF_UP=$(echo "$SUF" | tr '[:lower:]' '[:upper:]')

cat > "$FILE" <<'EOF'
`ifndef __UP___SUF_UP___SV
`define __UP___SUF_UP___SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class __P___SUF__ extends __BASE__;

    `uvm_component_utils(__P___SUF__)

    function new(string name="__P___SUF__", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask

    virtual function void report_phase(uvm_phase phase);
    endfunction

endclass

`endif
EOF

    sed -i "s/__P__/${P}/g; s/__UP__/${UP}/g; s/__SUF_UP__/${SUF_UP}/g; s/__SUF__/${SUF}/g; s/__BASE__/${BASE}/g" "$FILE"
}

cat > "${P}_seq_item.sv" <<'EOF'
`ifndef __UP___SEQ_ITEM_SV
`define __UP___SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class __P___seq_item extends uvm_sequence_item;

    rand bit [7:0] data;

    `uvm_object_utils_begin(__P___seq_item)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="__P___seq_item");
        super.new(name);
    endfunction

endclass

`endif
EOF

sed -i "s/__P__/${P}/g; s/__UP__/${UP}/g" "${P}_seq_item.sv"

cat > "${P}_sequence.sv" <<'EOF'
`ifndef __UP___SEQUENCE_SV
`define __UP___SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class __P___sequence extends uvm_sequence #(__P___seq_item);

    `uvm_object_utils(__P___sequence)

    function new(string name="__P___sequence");
        super.new(name);
    endfunction

    virtual task body();
        __P___seq_item req;

        repeat (10) begin
            req = __P___seq_item::type_id::create("req");
            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("__P___sequence", "Randomization failed")
            end

            finish_item(req);
        end
    endtask

endclass

`endif
EOF

sed -i "s/__P__/${P}/g; s/__UP__/${UP}/g" "${P}_sequence.sv"

cat > "${P}_interface.sv" <<'EOF'
`ifndef __UP___INTERFACE_SV
`define __UP___INTERFACE_SV

interface __P___interface;

    logic clk;
    logic rst;

    // TODO: Add DUT signals here
    logic [7:0] data;

endinterface

`endif
EOF

sed -i "s/__P__/${P}/g; s/__UP__/${UP}/g" "${P}_interface.sv"

gen_component "agent"      "uvm_component"
gen_component "coverage"   "uvm_component"
gen_component "driver"     "uvm_component"
gen_component "env"        "uvm_component"
gen_component "monitor"    "uvm_component"
gen_component "scoreboard" "uvm_component"
gen_component "test"       "uvm_test"

cat > "tb.sv" <<'EOF'
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "__P___interface.sv"
`include "__P___seq_item.sv"
`include "__P___sequence.sv"
`include "__P___driver.sv"
`include "__P___monitor.sv"
`include "__P___scoreboard.sv"
`include "__P___coverage.sv"
`include "__P___agent.sv"
`include "__P___env.sv"
`include "__P___test.sv"

module tb;

    __P___interface intf();

    initial begin
        intf.clk = 0;
        forever #5 intf.clk = ~intf.clk;
    end

    initial begin
        intf.rst = 1;
        #20;
        intf.rst = 0;
    end

    initial begin
        run_test("__P___test");
    end

endmodule
EOF

sed -i "s/__P__/${P}/g" "tb.sv"

cat > "filelist.f" <<EOF
+incdir+.
tb.sv
EOF

echo "UVM template files for '${P}' generated successfully."