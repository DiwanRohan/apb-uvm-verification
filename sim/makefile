VSIM = vsim
TOP  = apb_tb_top
TEST ?= apb_sanity_test
# Provide a fixed seed for reproducibility, or override with: make run SEED=<n>
SEED ?= random

.PHONY: compile run sanity random write read gui cov clean help

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

gui:
	$(VSIM) -do "do compile.do; vsim -nodpiexports -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED) work.$(TOP)"

cov:
	$(VSIM) -c -do "do compile.do; vsim -nodpiexports -coverage +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED) work.$(TOP); run -all; coverage save apb.ucdb; quit -f"

# FIX: removed modelsim.ini from clean — it is a hand-configured file that
#      maps the mtiUvm library; deleting it breaks subsequent compile runs.
# FIX: added *.vcd to clean since dumpfile("dump.vcd") is always created.
clean:
	rm -rf work transcript *.wlf *.ucdb *.vcd

help:
	@echo "make compile"
	@echo "make run TEST=apb_sanity_test [SEED=<n>]"
	@echo "make sanity | random | write | read"
	@echo "make gui TEST=apb_sanity_test [SEED=<n>]"
	@echo "make cov TEST=apb_sanity_test [SEED=<n>]"
	@echo "make clean"
