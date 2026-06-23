class apb_slv_mon extends uvm_monitor;

  virtual apb_slv_inf.SLV_MON_MP vif;

  //analysis port
  uvm_analysis_port #(apb_mas_seq_item) item_collect_port;

  apb_mas_seq_item item_collected;

  //factory registration
  `uvm_component_utils(apb_slv_mon)

  //new
  function new(string name = "apb_slv_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collect_port = new("item_collect_port", this);
    item_collected = new();
  endfunction

  task run_phase(uvm_phase phase);
    monitor();
  endtask

  task monitor();
    forever begin

      @(vif.mon_cb);

      if (vif.mon_cb.psel && vif.mon_cb.penable) begin

        item_collected = new();

        item_collected.pready  = vif.mon_cb.pready;

        item_collected.paddr   = vif.mon_cb.paddr;
        item_collected.kind_e  = vif.mon_cb.pwrite ? WRITE : READ;
        item_collected.pslverr = vif.mon_cb.pslverr;

        while (vif.mon_cb.psel && vif.mon_cb.penable && !vif.mon_cb.pready)
        item_collected.wait_cycles++;

        if (item_collected.wait_cycles > 0)
          $display("Wait Cycles started and count = %0d", item_collected.wait_cycles);

        if (vif.mon_cb.pwrite) item_collected.pwdata = vif.mon_cb.pwdata;
        else item_collected.prdata = vif.mon_cb.prdata;

        item_collect_port.write(item_collected);

        @(vif.mon_cb iff !vif.mon_cb.penable);

      end
    end
  endtask
endclass
