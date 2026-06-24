`ifndef APB_IF_SV
`define APB_IF_SV

`include "apb_defines.sv"

interface apb_if(input logic pclk);

  logic                   prstn;
  logic                   psel;
  logic                   penable;
  logic                   pwrite;
  logic [`ADDR_WIDTH-1:0] paddr;
  logic [`DATA_WIDTH-1:0] pwdata;
  logic [`DATA_WIDTH-1:0] prdata;
  logic                   pready;
  logic                   pslverr;

  clocking mas_drv_cb @(posedge pclk);
    default input #1 output #1;
    input  prstn;
    output psel, penable, pwrite, paddr, pwdata;
    input  prdata, pready, pslverr;
  endclocking

  clocking mon_cb @(posedge pclk);
    default input #1;
    input prstn, psel, penable, pwrite;
    input paddr, pwdata, prdata, pready, pslverr;
  endclocking

  modport MAS_DRV_MP(clocking mas_drv_cb);
  modport MAS_MON_MP(clocking mon_cb);
  modport SLV_MON_MP(clocking mon_cb);

endinterface

`endif
