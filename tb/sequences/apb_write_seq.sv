class apb_write_seq extends apb_base_seq;
  `uvm_object_utils(apb_write_seq)

  function new(string name = "apb_write_seq");
    super.new(name);
  endfunction

  task body();
    apb_mas_seq_item req;
    repeat (10) begin
      req = apb_mas_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with { kind_e == WRITE; paddr < `DEPTH; })
        `uvm_fatal("WRITE_SEQ", "item randomization failed")
      finish_item(req);
    end
  endtask
endclass
