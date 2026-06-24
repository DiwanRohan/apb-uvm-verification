// Master-side sequence item.  Inherits all fields from apb_seq_item_base
// and adds an address constraint that biases traffic towards the valid
// memory range while still exercising out-of-bounds accesses for
// PSLVERR coverage.
class apb_mas_seq_item extends apb_seq_item_base;

  // 70 % of addresses hit valid memory; 30 % go out-of-range to exercise
  // the PSLVERR response path.  The range [DEPTH : DEPTH+3] is chosen so
  // that OOB accesses are close to the boundary (worst-case decoder).
  constraint address_c {
    paddr dist { [0      : `DEPTH-1  ] :/ 70,
                 [`DEPTH : `DEPTH+3  ] :/ 30 };
  }

  `uvm_object_utils(apb_mas_seq_item)

  function new(string name = "apb_mas_seq_item");
    super.new(name);
  endfunction

endclass
