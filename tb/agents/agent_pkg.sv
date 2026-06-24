package agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "apb_defines.sv"

  typedef enum bit {READ = 1'b0, WRITE = 1'b1} trans_kind_e;

  // Base seq-item (shared fields, no constraints) must come first.
  `include "apb_seq_item_base.sv"
  // Derived seq-items.
  `include "apb_mas_seq_item.sv"
  `include "apb_slv_seq_item.sv"

  // Sequencer.
  `include "apb_mas_seqr.sv"

  // Base monitor must be included before both derived monitors.
  `include "apb_base_mon.sv"

  // Driver and concrete monitors.
  `include "apb_mas_drv.sv"
  `include "apb_mas_mon.sv"
  `include "apb_mas_agent.sv"
  `include "apb_slv_mon.sv"
  `include "apb_slv_agent.sv"

endpackage
