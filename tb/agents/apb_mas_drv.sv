class apb_mas_drv extends uvm_driver #(apb_mas_seq_item);
  `uvm_component_utils(apb_mas_drv)

  virtual apb_if.MAS_DRV_MP vif;

  function new(string name = "apb_mas_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    drive_idle();

    do @(vif.mas_drv_cb);
    while (vif.mas_drv_cb.prstn !== 1'b1);

    forever begin
      seq_item_port.get_next_item(req);
      drive_transfer(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_idle();
    vif.mas_drv_cb.psel    <= 1'b0;
    vif.mas_drv_cb.penable <= 1'b0;
    vif.mas_drv_cb.pwrite  <= 1'b0;
    vif.mas_drv_cb.paddr   <= '0;
    vif.mas_drv_cb.pwdata  <= '0;
  endtask

  task drive_transfer(apb_mas_seq_item trans);
    // SETUP phase
    vif.mas_drv_cb.psel    <= 1'b1;
    vif.mas_drv_cb.penable <= 1'b0;
    vif.mas_drv_cb.pwrite  <= (trans.kind_e == WRITE);
    vif.mas_drv_cb.paddr   <= trans.paddr;
    vif.mas_drv_cb.pwdata  <= trans.pwdata;

    // ACCESS phase
    @(vif.mas_drv_cb);
    vif.mas_drv_cb.penable <= 1'b1;

    // The APB controls remain unchanged until the slave completes the access.
    do begin
      @(vif.mas_drv_cb);
      if (vif.mas_drv_cb.pready !== 1'b1)
        trans.wait_cycles++;
    end while (vif.mas_drv_cb.pready !== 1'b1);

    trans.pready  = vif.mas_drv_cb.pready;
    trans.pslverr = vif.mas_drv_cb.pslverr;
    trans.prdata  = vif.mas_drv_cb.prdata;

    `uvm_info("MAS_DRV",
      $sformatf("completed %s addr=0x%0h wait=%0d err=%0b",
        trans.kind_e.name(), trans.paddr, trans.wait_cycles, trans.pslverr),
      UVM_MEDIUM)

    drive_idle();
  endtask
endclass
