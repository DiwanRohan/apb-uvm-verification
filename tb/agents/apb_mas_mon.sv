class apb_mas_mon extends uvm_monitor;
  `uvm_component_utils(apb_mas_mon)

  virtual apb_if.MAS_MON_MP vif;
  uvm_analysis_port #(apb_mas_seq_item) item_collect_port;

  function new(string name = "apb_mas_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collect_port = new("item_collect_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.prstn && vif.mon_cb.psel && !vif.mon_cb.penable)
        collect_transfer();
    end
  endtask

  task collect_transfer();
    apb_mas_seq_item item;
    item = apb_mas_seq_item::type_id::create("item");
    item.kind_e = vif.mon_cb.pwrite ? WRITE : READ;
    item.paddr  = vif.mon_cb.paddr;
    item.pwdata = vif.mon_cb.pwdata;

    @(vif.mon_cb);
    while (vif.mon_cb.psel && vif.mon_cb.penable &&
           vif.mon_cb.pready !== 1'b1) begin
      item.wait_cycles++;
      @(vif.mon_cb);
    end

    if (vif.mon_cb.psel && vif.mon_cb.penable) begin
      item.pready  = vif.mon_cb.pready;
      item.pslverr = vif.mon_cb.pslverr;
      item.prdata  = vif.mon_cb.prdata;
      item_collect_port.write(item);
      `uvm_info("MAS_MON", {"captured ", item.sprint()}, UVM_HIGH)
    end
  endtask
endclass
