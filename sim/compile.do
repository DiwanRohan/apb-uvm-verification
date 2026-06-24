if {[file exists work]} {
  vdel -lib work -all
}
vlib work
vmap work work

set QUESTA_ROOT [file normalize [file join [file dirname [info nameofexecutable]] ..]]
set UVM_HOME [file join $QUESTA_ROOT verilog_src uvm-1.2 src]
vmap mtiUvm [file join $QUESTA_ROOT uvm-1.2]

vlog -cover sbect -sv -timescale 1ns/1ps -L mtiUvm \
  +incdir+$UVM_HOME \
  +incdir+../tb \
  +incdir+../tb/interfaces \
  +incdir+../tb/agents \
  +incdir+../tb/agents/apb_master_agent \
  +incdir+../tb/agents/apb_slave_agent \
  +incdir+../tb/sequences \
  +incdir+../tb/env \
  +incdir+../tb/tests \
  ../tb/interfaces/apb_if.sv \
  ../tb/interfaces/apb_assertions.sv \
  ../rtl/apb_slave.sv \
  ../tb/agents/agent_pkg.sv \
  ../tb/sequences/apb_seq_pkg.sv \
  ../tb/apb_pkg.sv \
  ../tb/tests/apb_test_pkg.sv \
  ../tb/top/apb_tb_top.sv
