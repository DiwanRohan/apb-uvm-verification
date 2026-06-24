// Base sequence item shared by both the master and slave agents.
// All common APB transaction fields are declared here.  Derived classes
// either add randomisation constraints (master) or call rand_mode(0)
// at construction time (slave monitor items).
class apb_seq_item_base extends uvm_sequence_item;

  // Stimulus fields - rand so the master seq-item can constrain them.
  rand trans_kind_e          kind_e;      // READ or WRITE
  rand bit [`ADDR_WIDTH-1:0] paddr;       // APB address
  rand bit [`DATA_WIDTH-1:0] pwdata;      // Write data

  // Response / output fields - populated by the driver/monitor, never rand.
  bit [`DATA_WIDTH-1:0]      prdata;      // Read data returned by DUT
  bit                        pready;      // PREADY sampled at transfer completion
  bit                        pslverr;     // PSLVERR sampled at transfer completion
  int unsigned               wait_cycles; // Number of PREADY=0 cycles observed

  `uvm_object_utils_begin(apb_seq_item_base)
    `uvm_field_enum(trans_kind_e, kind_e,     UVM_ALL_ON)
    `uvm_field_int (paddr,                    UVM_ALL_ON)
    `uvm_field_int (pwdata,                   UVM_ALL_ON)
    `uvm_field_int (prdata,                   UVM_ALL_ON)
    `uvm_field_int (pready,                   UVM_ALL_ON)
    `uvm_field_int (pslverr,                  UVM_ALL_ON)
    `uvm_field_int (wait_cycles,              UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_seq_item_base");
    super.new(name);
  endfunction

endclass
