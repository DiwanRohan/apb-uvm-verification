module apb_tb_top;

  import uvm_pkg::*;
  import agent_pkg::*;
  import apb_seq_pkg::*;
  import apb_test_pkg::*;
  import apb_pkg::*;

  bit pclk;

  //-----------------------------------
  // Clock Generation
  //-----------------------------------

  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  //-----------------------------------
  // Interface
  //-----------------------------------

  apb_if vif(pclk);

  //-----------------------------------
  // DUT
  //-----------------------------------

  apb_slave dut (

      .pclk     (pclk),

      .presetn  (vif.presetn),

      .psel     (vif.psel),

      .penable  (vif.penable),

      .pwrite   (vif.pwrite),

      .paddr    (vif.paddr),

      .pwdata   (vif.pwdata),

      .prdata   (vif.prdata),

      .pready   (vif.pready),

      .pslverr  (vif.pslverr)

  );

  //-----------------------------------
  // Config DB
  //-----------------------------------

  initial begin

    uvm_config_db#(virtual apb_if)::set
    (
      null,
      "*",
      "vif",
      vif
    );

    run_test();

  end

endmodule
