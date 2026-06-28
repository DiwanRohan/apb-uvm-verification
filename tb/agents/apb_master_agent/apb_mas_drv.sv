class apb_mas_drv extends uvm_driver #(apb_mas_seq_item);
  `uvm_component_utils(apb_mas_drv)

  virtual apb_if.MAS_DRV_MP vif;

  function new(string name = "apb_mas_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    // Drive all outputs to a known idle state before the first clock edge.
    // Clocking-block outputs driven via '<=' are scheduled for the next
    // clocking event regardless of when the drive is issued, so this is
    // safe to call at time 0.
    drive_idle();

    // Wait for reset de-assertion before accepting transactions.
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
    vif.mas_drv_cb.pstrb   <= '0;
  endtask

  task drive_transfer(apb_mas_seq_item trans);
    // Use a local counter so we do not mutate the shared sequence item
    // during the wait-state loop.
    int unsigned w_cnt = 0;

    // --- SETUP phase ---
    vif.mas_drv_cb.psel    <= 1'b1;
    vif.mas_drv_cb.penable <= 1'b0;
    vif.mas_drv_cb.pwrite  <= (trans.kind_e == WRITE);
    vif.mas_drv_cb.paddr   <= trans.paddr;
    vif.mas_drv_cb.pwdata  <= trans.pwdata;
    vif.mas_drv_cb.pstrb   <= trans.pstrb;

    // --- ACCESS phase ---
    // APB spec: PENABLE asserted one cycle after PSEL.
    @(vif.mas_drv_cb);
    vif.mas_drv_cb.penable <= 1'b1;

    // Hold all control signals until the slave completes the access.
    do begin
      @(vif.mas_drv_cb);
      if (vif.mas_drv_cb.pready !== 1'b1)
        w_cnt++;
    end while (vif.mas_drv_cb.pready !== 1'b1);

    // Record wait count and response in the item once, after completion.
    trans.wait_cycles = w_cnt;
    trans.pslverr     = vif.mas_drv_cb.pslverr;
    trans.prdata      = vif.mas_drv_cb.prdata;

    `uvm_info("MAS_DRV",
      $sformatf("completed %s addr=0x%0h wait=%0d err=%0b",
        trans.kind_e.name(), trans.paddr, trans.wait_cycles, trans.pslverr),
      UVM_MEDIUM)

    //drive_idle();
  endtask
endclass
