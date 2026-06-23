class apb_mas_drv extends uvm_driver #(apb_mas_seq_item);

  `uvm_component_utils(apb_mas_drv)

  //virtual interface
  virtual apb_mas_inf.MAS_DRV_MP vif;

  function new(string name = "", uvm_component parent = null);
    super.new(name,parent);
  endfunction


  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();
    end
  endtask

  task send_to_dut(apb_mas_seq_item trans);
    static bit first_transfer = 1;
    if (first_transfer) begin
      @(vif.drv_cb);
      first_transfer = 0;
    end
    //RESET CONDITION
    if (apb_pkg::reset) begin
      vif.drv_cb.psel    <= 1'b0;
      vif.drv_cb.penable <= 1'b0;
    end
    else begin
      //-------------------------------------------------
      //SETUP PHASE
      //PSEL    = 1
      //PENABLE = 0
      //-------------------------------------------------
      vif.drv_cb.psel    <= 1'b1;
      vif.drv_cb.penable <= 1'b0;

      vif.drv_cb.pwrite  <= trans.kind_e;
      vif.drv_cb.paddr   <= trans.paddr;
      vif.drv_cb.pwdata  <= trans.pwdata;

      //-------------------------------------------------
      //ACCESS PHASE
      //PSEL    = 1
      //PENABLE = 1
      //-------------------------------------------------
      @(vif.drv_cb);
      vif.drv_cb.penable <= 1'b1;

      //-------------------------------------------------
      //WAIT STATES
      //HOLD SAME VALUES UNTIL PREADY=1
      //-------------------------------------------------
      if (vif.drv_cb.pready !== 1'b1) begin
        do begin
          @(vif.drv_cb);

          vif.drv_cb.psel    <= 1'b1;
          vif.drv_cb.penable <= 1'b1;

          vif.drv_cb.pwrite  <= trans.kind_e;
          vif.drv_cb.paddr   <= trans.paddr;
          vif.drv_cb.pwdata  <= trans.pwdata;
        end while (vif.drv_cb.pready !== 1'b1);
      end
      //ERROR CHECK
      if (vif.drv_cb.pslverr) $display("[DRV] APB ERROR DETECTED ADDR=%0h", trans.paddr);
    end
  endtask

endclass
