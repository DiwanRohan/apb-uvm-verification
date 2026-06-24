VSIM = vsim
TOP  = apb_tb_top
TEST ?= apb_sanity_test

.PHONY: compile run sanity random write read gui cov clean help

compile:
	$(VSIM) -c -do "do compile.do; quit -f"

run:
	$(VSIM) -c -do "do compile.do; vsim -nodpiexports +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) work.$(TOP); run -all; quit -f"

sanity:
	$(MAKE) run TEST=apb_sanity_test

random:
	$(MAKE) run TEST=apb_random_test

write:
	$(MAKE) run TEST=apb_write_test

read:
	$(MAKE) run TEST=apb_read_test

gui:
	$(VSIM) -do "do compile.do; vsim -nodpiexports -voptargs=+acc +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) work.$(TOP)"

cov:
	$(VSIM) -c -do "do compile.do; vsim -nodpiexports -coverage +UVM_NO_RELNOTES +UVM_TESTNAME=$(TEST) work.$(TOP); run -all; coverage save apb.ucdb; quit -f"

clean:
	rm -rf work transcript *.wlf *.ucdb modelsim.ini

help:
	@echo "make compile"
	@echo "make run TEST=apb_sanity_test"
	@echo "make sanity | random | write | read"
	@echo "make gui TEST=apb_sanity_test"
	@echo "make cov TEST=apb_sanity_test"
	@echo "make clean"
