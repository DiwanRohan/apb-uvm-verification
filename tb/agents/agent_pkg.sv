package agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "apb_defines.sv"

  typedef enum bit {READ = 1'b0, WRITE = 1'b1} trans_kind_e;

  `include "apb_mas_seq_item.sv"
  `include "apb_slv_seq_item.sv"
  `include "apb_mas_seqr.sv"
  `include "apb_mas_drv.sv"
  `include "apb_mas_mon.sv"
  `include "apb_mas_agent.sv"
  `include "apb_slv_mon.sv"
  `include "apb_slv_agent.sv"

endpackage
