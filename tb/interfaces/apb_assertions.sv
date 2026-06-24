`ifndef APB_ASSERTIONS_SV
`define APB_ASSERTIONS_SV

`include "apb_defines.sv"

interface apb_assertions_if (
  input logic                   pclk,
  input logic                   prstn,
  input logic                   psel,
  input logic                   penable,
  input logic                   pwrite,
  input logic [`ADDR_WIDTH-1:0] paddr,
  input logic [`DATA_WIDTH-1:0] pwdata,
  input logic [`DATA_WIDTH-1:0] prdata,
  input logic                   pready,
  input logic                   pslverr
);

  property penable_requires_psel;
    @(posedge pclk) disable iff (!prstn) penable |-> psel;
  endproperty
  assert property (penable_requires_psel)
    else $error("APB: PENABLE asserted without PSEL");

  property setup_to_access;
    @(posedge pclk) disable iff (!prstn)
      (psel && !penable) |=> (psel && penable);
  endproperty
  assert property (setup_to_access)
    else $error("APB: SETUP did not transition to ACCESS");

  property controls_stable_during_wait;
    @(posedge pclk) disable iff (!prstn)
      (psel && penable && !pready) |=>(psel && penable &&
        $stable({paddr, pwrite, pwdata}));
  endproperty
  assert property (controls_stable_during_wait)
    else $error("APB: controls changed during a wait state");

  property no_unknown_controls;
    @(posedge pclk) disable iff (!prstn)
      !$isunknown({psel, penable, pwrite, pready});
  endproperty
  assert property (no_unknown_controls)
    else $error("APB: unknown control value detected");

  property pslverr_only_at_completion;
    @(posedge pclk) disable iff (!prstn)
      pslverr |-> (psel && penable && pready);
  endproperty
  assert property (pslverr_only_at_completion)
    else $error("APB: PSLVERR asserted outside transfer completion");

  property reset_drives_bus_idle;
    @(posedge pclk) !prstn |-> (!psel && !penable);
  endproperty
  assert property (reset_drives_bus_idle)
    else $error("APB: bus is not idle during reset");

  property access_follows_setup_or_wait;
    @(posedge pclk) disable iff (!prstn)
      penable |-> $past(psel && (!penable || !pready));
  endproperty
  assert property (access_follows_setup_or_wait)
    else $error("APB: ACCESS occurred without SETUP or a preceding wait");

endinterface

`endif
