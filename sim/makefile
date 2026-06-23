# ==================================================
# APB UVM Verification Makefile
# ==================================================

VSIM = vsim
VLOG = vlog

TOP  = apb_tb_top

# Default Test
TEST = apb_sanity_test

# ==================================================
# Compile
# ==================================================

compile:
	$(VSIM) -c -do "do compile.do; quit -f"

# ==================================================
# Run Default Test
# ==================================================

run:
	$(VSIM) -c -do "do compile.do; \
	vsim -voptargs=+acc +UVM_TESTNAME=$(TEST) work.$(TOP); \
	run -all; \
	quit -f"

# ==================================================
# Individual Tests
# ==================================================

sanity:
	$(MAKE) run TEST=apb_sanity_test

random:
	$(MAKE) run TEST=apb_random_test

write:
	$(MAKE) run TEST=apb_write_test

read:
	$(MAKE) run TEST=apb_read_test

# ==================================================
# GUI Mode
# ==================================================

gui:
	$(VSIM) -do "do compile.do; \
	vsim -voptargs=+acc +UVM_TESTNAME=$(TEST) work.$(TOP)"

# ==================================================
# Coverage
# ==================================================

cov:
	$(VSIM) -c -do "do compile.do; \
	vsim -coverage +UVM_TESTNAME=$(TEST) work.$(TOP); \
	run -all; \
	coverage save apb.ucdb; \
	quit -f"

# ==================================================
# Clean
# ==================================================

clean:
	rm -rf work
	rm -rf transcript
	rm -rf *.wlf
	rm -rf *.ucdb
	rm -rf modelsim.ini

# ==================================================
# Help
# ==================================================

help:
	@echo "make compile"
	@echo "make run"
	@echo "make sanity"
	@echo "make random"
	@echo "make write"
	@echo "make read"
	@echo "make gui"
	@echo "make cov"
	@echo "make clean"