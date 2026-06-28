# ==============================================================================
# ModelSim / QuestaSim Simulation Run Script (run.do)
# ==============================================================================
# This script automates compiling the design, loading the simulation, setting up
# waveforms (if in GUI mode), and running the testbench.
#
# Usage:
#   1. Open ModelSim/QuestaSim and change directory to 'sim/'.
#   2. To run the default sanity test:
#      do run.do
#   3. To run a specific test with a custom seed and coverage enabled:
#      set TESTNAME apb_random_test; set SEED 12345; set COVERAGE 1; do run.do
# ==============================================================================

# 1. Quit any active simulation to start clean
quit -sim

# 2. Set default parameters if not already specified by the user
if {![info exists TESTNAME]} {
  set TESTNAME "apb_sanity_test"
}

if {![info exists SEED]} {
  set SEED "random"
}

if {![info exists VERBOSITY]} {
  set VERBOSITY "UVM_MEDIUM"
}

if {![info exists COVERAGE]} {
  set COVERAGE 0
}

# 3. Run the compile script
do compile.do

# 4. Determine coverage options
set vsim_cov_opt ""
if {$COVERAGE == 1} {
  set vsim_cov_opt "-coverage"
}

# 5. Load the simulation top module
eval vsim -nodpiexports $vsim_cov_opt -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=$TESTNAME +ntb_random_seed=$SEED +UVM_VERBOSITY=$VERBOSITY work.apb_tb_top

# 6. Configure simulation run / GUI wave environment
if {[batch_mode] == 0} {
  # Add waveforms only when running in GUI mode
  
  # Configure wave window view options
  configure wave -signalnamewidth 1
  configure wave -timelineunits ns
  
  # Group: APB Interface
  add wave -divider "APB Interface"
  add wave -noupdate -hex /apb_tb_top/vif/pclk
  add wave -noupdate -hex /apb_tb_top/vif/prstn
  add wave -noupdate -hex /apb_tb_top/vif/psel
  add wave -noupdate -hex /apb_tb_top/vif/penable
  add wave -noupdate -hex /apb_tb_top/vif/pwrite
  add wave -noupdate -hex -radix hex /apb_tb_top/vif/paddr
  add wave -noupdate -hex -radix hex /apb_tb_top/vif/pwdata
  add wave -noupdate -hex -radix hex /apb_tb_top/vif/pstrb
  add wave -noupdate -hex /apb_tb_top/vif/pready
  add wave -noupdate -hex -radix hex /apb_tb_top/vif/prdata
  add wave -noupdate -hex /apb_tb_top/vif/pslverr
  
  # Group: APB Slave DUT (Internal Signals)
  add wave -divider "APB Slave DUT"
  add wave -noupdate -hex /apb_tb_top/dut/wait_active
  add wave -noupdate -hex /apb_tb_top/dut/wait_cnt
  add wave -noupdate -hex -radix hex /apb_tb_top/dut/mem
  
  # Group: APB Assertions
  add wave -divider "Assertions"
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/PENABLE_REQUIRES_PSEL
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/SETUP_TO_ACCESS
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/CONTROLS_STABLE_DURING_WAIT
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/PSEL_STABLE_DURING_ACCESS
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/PENABLE_DEASSERTS_AFTER_COMPLETION
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/NO_UNKNOWN_CONTROLS
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/PSLVERR_ONLY_AT_COMPLETION
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/RESET_DRIVES_BUS_IDLE
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/ACCESS_FOLLOWS_SETUP_OR_WAIT
  add wave -noupdate /apb_tb_top/vif/apb_assert_inst/PSTRB_LOW_DURING_READ
  
  # Zoom full and run simulation
  wave zoom full
  run -all
} else {
  # Run and save coverage when in batch mode
  run -all
  if {$COVERAGE == 1} {
    coverage save -onexit cov_$TESTNAME.ucdb
  }
  quit -f
}
