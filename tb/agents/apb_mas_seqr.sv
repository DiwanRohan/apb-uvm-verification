// APB master sequencer — thin type-parameterised wrapper around
// uvm_sequencer.  No overrides needed; the default behaviour is correct.
class apb_mas_seqr extends uvm_sequencer #(apb_mas_seq_item);
  `uvm_component_utils(apb_mas_seqr)

  function new(string name = "apb_mas_seqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
