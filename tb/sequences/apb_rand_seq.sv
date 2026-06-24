class apb_rand_seq extends apb_base_seq;
  `uvm_object_utils(apb_rand_seq)

  function new(string name = "apb_rand_seq");
    super.new(name);
  endfunction

  task body();
    apb_mas_seq_item req;
    repeat (20) begin
      req = apb_mas_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize())
        `uvm_fatal("RAND_SEQ", "item randomization failed")
      finish_item(req);
    end
  endtask
endclass
