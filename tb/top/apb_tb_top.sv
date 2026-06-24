`timescale 1ns/1ps

module apb_tb_top;
  import uvm_pkg::*;
  import agent_pkg::*;
  import apb_seq_pkg::*;
  import apb_pkg::*;
  import apb_test_pkg::*;

  bit pclk = 1'b0;
  always #5 pclk = ~pclk;

  apb_if vif(pclk);

  apb_slave dut (
    .pclk    (pclk),
    .prstn   (vif.prstn),
    .psel    (vif.psel),
    .penable (vif.penable),
    .paddr   (vif.paddr),
    .pwrite  (vif.pwrite),
    .pwdata  (vif.pwdata),
    .pready  (vif.pready),
    .prdata  (vif.prdata),
    .pslverr (vif.pslverr)
  );

  initial begin
    vif.prstn = 1'b0;
    vif.psel = 1'b0;
    vif.penable = 1'b0;
    vif.pwrite = 1'b0;
    vif.paddr = '0;
    vif.pwdata = '0;
    repeat (3) @(posedge pclk);
    vif.prstn = 1'b1;
  end

  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", vif);
    run_test();
  end

endmodule
