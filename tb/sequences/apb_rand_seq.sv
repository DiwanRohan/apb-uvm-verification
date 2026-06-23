class apb_rand_seq extends apb_base_seq;

  `uvm_object_utils(apb_rand_seq)

  apb_mas_seq_item req;

  function new(string name="apb_rand_seq");
    super.new(name);
  endfunction

  task body();

    req = apb_mas_seq_item::type_id::create("req");

    start_item(req);

    assert(req.randomize());

    finish_item(req);

  endtask
endclass
