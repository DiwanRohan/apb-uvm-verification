package apb_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import agent_pkg::*;
  import apb_seq_pkg::*;
  import apb_pkg::*;

  `include "apb_base_test.sv"
  `include "apb_sanity_test.sv"
  `include "apb_write_test.sv"
  `include "apb_read_test.sv"
  `include "apb_random_test.sv"
endpackage
