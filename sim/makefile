VSIM = vsim
TOP  = apb_tb_top
TEST ?= apb_sanity_test
# Provide a fixed seed for reproducibility, or override with: make run SEED=<n>
SEED ?= random

.PHONY: compile run sanity random write read waitstate regression gui cov clean help

compile:
	$(VSIM) -c -do "do compile.do; quit -f"

run:
	$(VSIM) -c -do "do compile.do; vsim -nodpiexports +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED) work.$(TOP); run -all; quit -f"

sanity:
	$(MAKE) run TEST=apb_sanity_test

random:
	$(MAKE) run TEST=apb_random_test

write:
	$(MAKE) run TEST=apb_write_test

read:
	$(MAKE) run TEST=apb_read_test

waitstate:
	$(MAKE) run TEST=apb_waitstate_test

regression: compile
	$(VSIM) -c -do "vsim -nodpiexports -coverage -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=apb_sanity_test +ntb_random_seed=$(SEED) work.$(TOP); coverage save -onexit cov_sanity.ucdb; run -all"
	$(VSIM) -c -do "vsim -nodpiexports -coverage -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=apb_write_test +ntb_random_seed=$(SEED) work.$(TOP); coverage save -onexit cov_write.ucdb; run -all"
	$(VSIM) -c -do "vsim -nodpiexports -coverage -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=apb_read_test +ntb_random_seed=$(SEED) work.$(TOP); coverage save -onexit cov_read.ucdb; run -all"
	$(VSIM) -c -do "vsim -nodpiexports -coverage -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=apb_waitstate_test +ntb_random_seed=$(SEED) work.$(TOP); coverage save -onexit cov_waitstate.ucdb; run -all"
	$(VSIM) -c -do "vsim -nodpiexports -coverage -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=apb_random_test +ntb_random_seed=$(SEED) work.$(TOP); coverage save -onexit cov_random.ucdb; run -all"
	vcover merge merged.ucdb cov_sanity.ucdb cov_write.ucdb cov_read.ucdb cov_waitstate.ucdb cov_random.ucdb
	vcover report -detail merged.ucdb
	vcover report -html -output merged_cov_html merged.ucdb

gui:
	$(VSIM) -do "do compile.do; vsim -nodpiexports -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED) work.$(TOP)"

cov:
	$(VSIM) -c -do "do compile.do; vsim -nodpiexports -coverage -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED) work.$(TOP); coverage save -onexit apb.ucdb; run -all"

# FIX: removed modelsim.ini from clean — it is a hand-configured file that
#      maps the mtiUvm library; deleting it breaks subsequent compile runs.
# FIX: added *.vcd to clean since dumpfile("dump.vcd") is always created.
clean:
	rm -rf work transcript *.wlf *.ucdb *.vcd merged_cov_html

help:
	@echo "make compile"
	@echo "make run TEST=apb_sanity_test [SEED=<n>]"
	@echo "make sanity | random | write | read | waitstate | regression"
	@echo "make gui TEST=apb_sanity_test [SEED=<n>]"
	@echo "make cov TEST=apb_sanity_test [SEED=<n>]"
	@echo "make clean"
