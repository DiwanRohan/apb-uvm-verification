// Slave-side sequence item.  Inherits all fields from apb_seq_item_base.
// Randomisation is explicitly disabled at construction time: slave items
// are always populated by the monitor from observed bus signals, never
// by a randomize() call.  Keeping a separate type allows the scoreboard
// to maintain type-safe analysis ports for each monitor stream.
class apb_slv_seq_item extends apb_seq_item_base;

  `uvm_object_utils(apb_slv_seq_item)

  function new(string name = "apb_slv_seq_item");
    super.new(name);
    this.rand_mode(0); // Monitor-populated items are never randomized
  endfunction

endclass
