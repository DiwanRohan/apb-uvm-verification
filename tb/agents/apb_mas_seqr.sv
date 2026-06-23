class apb_mas_seqr extends uvm_sequencer #(apb_mas_seq_item);

  `uvm_component_utils(apb_mas_seqr)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

endclass
