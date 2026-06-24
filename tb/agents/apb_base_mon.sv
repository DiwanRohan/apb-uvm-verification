// Parameterised base monitor shared by the master and slave agents.
// All APB protocol monitoring logic lives here; derived classes select
// the concrete seq-item type (T) and register with the UVM factory.
class apb_base_mon #(type T = apb_seq_item_base) extends uvm_monitor;

  `uvm_component_param_utils(apb_base_mon #(T))

  virtual apb_if         vif;
  uvm_analysis_port #(T) item_collect_port;

  function new(string name, uvm_component parent);
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
    T item;
    item = T::type_id::create("item");

    // Capture SETUP-phase signals.
    item.kind_e = vif.mon_cb.pwrite ? WRITE : READ;
    item.paddr  = vif.mon_cb.paddr;
    item.pwdata = vif.mon_cb.pwdata;

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
