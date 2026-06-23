class apb_sanity_test extends apb_base_test;

  `uvm_component_utils(apb_sanity_test)

  apb_sanity_seq seq_h;

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq_h =
      apb_sanity_seq::type_id::create("seq_h");

    seq_h.start(env_h.agent_h.seqr_h);

    phase.drop_objection(this);

  endtask

endclass
