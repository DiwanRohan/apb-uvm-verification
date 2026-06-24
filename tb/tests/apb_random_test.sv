class apb_random_test extends apb_base_test;
  `uvm_component_utils(apb_random_test)

  function new(string name = "apb_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_rand_seq seq_h;
    phase.raise_objection(this);
    seq_h = apb_rand_seq::type_id::create("seq_h");
    seq_h.start(env_h.mas_agent_h.seqr_h);
    phase.drop_objection(this);
  endtask
endclass
