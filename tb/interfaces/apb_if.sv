`ifndef APB_IF_SV
`define APB_IF_SV

`include "apb_defines.sv"

interface apb_if(input logic pclk);

  logic                   prstn = 1'b0;
  logic                   psel = 1'b0;
  logic                   penable = 1'b0;
  logic                   pwrite = 1'b0;
  logic [`ADDR_WIDTH-1:0] paddr = '0;
  logic [`DATA_WIDTH-1:0] pwdata = '0;
  logic [`DATA_WIDTH-1:0] prdata;
  logic [(`DATA_WIDTH/8)-1:0] pstrb = '0;
  logic                   pready;
  logic                   pslverr;

  clocking mas_drv_cb @(posedge pclk);
    default input #1 output #1;
    input  prstn;
    output psel, penable, pwrite, paddr, pwdata, pstrb;
    input  prdata, pready, pslverr;
  endclocking

  clocking mon_cb @(posedge pclk);
    default input #1;
    input prstn, psel, penable, pwrite;
    input paddr, pwdata, pstrb, prdata, pready, pslverr;
  endclocking

  modport MAS_DRV_MP(clocking mas_drv_cb);

endinterface

`endif
