class apb_sanity_seq extends apb_base_seq;
  `uvm_object_utils(apb_sanity_seq)

  function new(string name = "apb_sanity_seq");
    super.new(name);
  endfunction

  task body();
    apb_mas_seq_item req;

    req = apb_mas_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      kind_e == WRITE;
      paddr  == 32'h0000_0001;
      pwdata == 32'hA5A5_0001;
    })
      `uvm_fatal("SANITY_SEQ", "write item randomization failed")
    finish_item(req);

    req = apb_mas_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      kind_e == READ;
      paddr  == 32'h0000_0001;
    })
      `uvm_fatal("SANITY_SEQ", "read item randomization failed")
    finish_item(req);
  endtask
endclass
