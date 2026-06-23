class apb_sanity_seq extends apb_base_seq;

  `uvm_object_utils(apb_sanity_seq)

  apb_mas_seq_item req;

  function new(string name="apb_sanity_seq");
    super.new(name);
  endfunction

  task body();

    req = apb_mas_seq_item::type_id::create("req");

    start_item(req);

    assert(req.randomize() with {
      kind_e == WRITE;
      addr == 32'h0000_0001;
      data == 32'h0000_0001;
    });

    finish_item(req);

    start_item(req);

    assert(req.randomize() with {
      kind_e == READ;
      addr == 32'h0000_0001;
    });

    finish_item(req);

  endtask
endclass
