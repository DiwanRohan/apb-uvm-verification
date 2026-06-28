// APB master monitor — captures every completed APB transfer from the bus.
class apb_mas_mon extends uvm_monitor;

  `uvm_component_utils(apb_mas_mon)

  virtual apb_if                        vif;
  uvm_analysis_port #(apb_mas_seq_item) item_collect_port;

  function new(string name = "apb_mas_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collect_port = new("item_collect_port", this);
  endfunction

  // --------------------------------------------------------------------- run
  task run_phase(uvm_phase phase);
    forever begin
      @(vif.mon_cb);
      // SETUP phase: PSEL asserted, PENABLE not yet asserted.
      if (vif.mon_cb.prstn && vif.mon_cb.psel && !vif.mon_cb.penable)
        collect_transfer();
    end
  endtask

  // -------------------------------------------------------- collect_transfer
  task collect_transfer();
    apb_mas_seq_item item;
    item = apb_mas_seq_item::type_id::create("item");

    // Capture SETUP-phase signals.
    item.kind_e = vif.mon_cb.pwrite ? WRITE : READ;
    item.paddr  = vif.mon_cb.paddr;
    item.pwdata = vif.mon_cb.pwdata;
    item.pstrb  = vif.mon_cb.pstrb;

    // Advance to ACCESS phase.
    @(vif.mon_cb);

    // Count wait states (PREADY de-asserted by slave).
    while (vif.mon_cb.psel && vif.mon_cb.penable &&
           vif.mon_cb.pready !== 1'b1) begin
      item.wait_cycles++;
      @(vif.mon_cb);
    end

    // Transfer completed normally — capture response fields.
    if (vif.mon_cb.psel && vif.mon_cb.penable) begin
      item.pslverr = vif.mon_cb.pslverr;
      item.prdata  = vif.mon_cb.prdata;
      item_collect_port.write(item);
      `uvm_info(get_type_name(), {"captured ", item.sprint()}, UVM_HIGH)
    end else begin
      // PSEL was unexpectedly de-asserted — protocol violation.
      `uvm_error(get_type_name(),
        "PSEL de-asserted unexpectedly during ACCESS phase — transaction dropped")
    end
  endtask

endclass
