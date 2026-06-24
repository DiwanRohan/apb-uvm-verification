class apb_sanity_test extends apb_base_test;
  `uvm_component_utils(apb_sanity_test)

  function new(string name = "apb_sanity_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_sanity_seq seq_h;
    phase.raise_objection(this);
    seq_h = apb_sanity_seq::type_id::create("seq_h");
    seq_h.start(env_h.mas_agent_h.seqr_h);
    phase.drop_objection(this);
  endtask
endclass
