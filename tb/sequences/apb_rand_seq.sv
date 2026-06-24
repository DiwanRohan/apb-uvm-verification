class apb_rand_seq extends apb_base_seq;
  `uvm_object_utils(apb_rand_seq)

  // Overridable transaction count (default 20).
  int unsigned num_txns = 20;

  function new(string name = "apb_rand_seq");
    super.new(name);
  endfunction

  task body();
    apb_mas_seq_item req;

    // Phase 1: Populate all valid memory cells with constrained write data
    for (int i = 0; i < `DEPTH; i++) begin
      req = apb_mas_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with { kind_e == WRITE; paddr == i; })
        `uvm_fatal("RAND_SEQ", "Phase 1: write randomization failed")
      finish_item(req);
    end

    // Phase 2: Read back from all memory cells to sample read data coverage
    for (int i = 0; i < `DEPTH; i++) begin
      req = apb_mas_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with { kind_e == READ; paddr == i; })
        `uvm_fatal("RAND_SEQ", "Phase 2: read randomization failed")
      finish_item(req);
    end

    // Phase 3: Perform random reads/writes (both in-range and OOB)
    // to hit direction transitions, out-of-range bins, and error responses.
    repeat (num_txns) begin
      req = apb_mas_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_fatal("RAND_SEQ", "Phase 3: random item randomization failed")
      finish_item(req);
    end
  endtask
endclass
