`ifndef APB_ASSERTIONS_SV
`define APB_ASSERTIONS_SV

`include "apb_defines.sv"

// This interface is bound to apb_if in apb_tb_top.sv via:
//   bind apb_if apb_assertions_if apb_assert_inst (.*);
// All port names must match signals in apb_if exactly.
interface apb_assertions_if (
  input logic                   pclk,
  input logic                   prstn,
  input logic                   psel,
  input logic                   penable,
  input logic                   pwrite,
  input logic [`ADDR_WIDTH-1:0] paddr,
  input logic [`DATA_WIDTH-1:0] pwdata,
  input logic [`DATA_WIDTH-1:0] prdata,
  input logic [(`DATA_WIDTH/8)-1:0] pstrb,
  input logic                   pready,
  input logic                   pslverr
);

  // -----------------------------------------------------------------------
  // APB Rule: PENABLE may only be asserted while PSEL is asserted.
  // -----------------------------------------------------------------------
  property penable_requires_psel;
    @(posedge pclk) disable iff (!prstn) penable |-> psel;
  endproperty
  PENABLE_REQUIRES_PSEL: assert property (penable_requires_psel)
    else $error("APB: PENABLE asserted without PSEL");

  // -----------------------------------------------------------------------
  // APB Rule: SETUP phase (PSEL=1, PENABLE=0) must be followed immediately
  // by ACCESS phase (PSEL=1, PENABLE=1) on the next cycle.
  // -----------------------------------------------------------------------
  property setup_to_access;
    @(posedge pclk) disable iff (!prstn)
      (psel && !penable) |=> (psel && penable);
  endproperty
  SETUP_TO_ACCESS: assert property (setup_to_access)
    else $error("APB: SETUP did not transition to ACCESS");

  // -----------------------------------------------------------------------
  // APB Rule: Control signals must remain stable during wait states.
  // -----------------------------------------------------------------------
  property controls_stable_during_wait;
    @(posedge pclk) disable iff (!prstn)
      (psel && penable && !pready) |=> (psel && penable &&
        $stable({paddr, pwrite, pwdata, pstrb}));
  endproperty
  CONTROLS_STABLE_DURING_WAIT: assert property (controls_stable_during_wait)
    else $error("APB: controls changed during a wait state");

  // -----------------------------------------------------------------------
  // APB Rule: PSEL must remain asserted throughout the ACCESS phase
  // (including all wait cycles) until PREADY goes high.
  // -----------------------------------------------------------------------
  property psel_stable_during_access;
    @(posedge pclk) disable iff (!prstn)
      (psel && penable && !pready) |=> psel;
  endproperty
  PSEL_STABLE_DURING_ACCESS: assert property (psel_stable_during_access)
    else $error("APB: PSEL de-asserted during ACCESS wait state");

  // -----------------------------------------------------------------------
  // APB Rule: PENABLE must de-assert one cycle after transfer completion
  // (the cycle after PSEL && PENABLE && PREADY are all high together).
  // -----------------------------------------------------------------------
  property penable_deasserts_after_completion;
    @(posedge pclk) disable iff (!prstn)
      (psel && penable && pready) |=> !penable;
  endproperty
  PENABLE_DEASSERTS_AFTER_COMPLETION: assert property (penable_deasserts_after_completion)
    else $error("APB: PENABLE not de-asserted after transfer completion");

  // -----------------------------------------------------------------------
  // APB Rule: No unknown (X/Z) values on control signals.
  // -----------------------------------------------------------------------
  property no_unknown_controls;
    @(posedge pclk) disable iff (!prstn)
      !$isunknown({psel, penable, pwrite, pready});
  endproperty
  NO_UNKNOWN_CONTROLS: assert property (no_unknown_controls)
    else $error("APB: unknown control value detected");

  // -----------------------------------------------------------------------
  // APB Rule: PSLVERR is only valid during transfer completion.
  // -----------------------------------------------------------------------
  property pslverr_only_at_completion;
    @(posedge pclk) disable iff (!prstn)
      pslverr |-> (psel && penable && pready);
  endproperty
  PSLVERR_ONLY_AT_COMPLETION: assert property (pslverr_only_at_completion)
    else $error("APB: PSLVERR asserted outside transfer completion");

  // -----------------------------------------------------------------------
  // APB Rule: During reset the bus must be idle (PSEL=0, PENABLE=0).
  // No disable iff here — this is an unconditional check of reset state.
  // -----------------------------------------------------------------------
  property reset_drives_bus_idle;
    @(posedge pclk) !prstn |-> (!psel && !penable);
  endproperty
  RESET_DRIVES_BUS_IDLE: assert property (reset_drives_bus_idle)
    else $error("APB: bus is not idle during reset");

  // -----------------------------------------------------------------------
  // APB Rule: ACCESS phase must be preceded by SETUP or a wait state.
  // -----------------------------------------------------------------------
  property access_follows_setup_or_wait;
    @(posedge pclk) disable iff (!prstn)
      penable |-> $past(psel && (!penable || !pready));
  endproperty
  ACCESS_FOLLOWS_SETUP_OR_WAIT: assert property (access_follows_setup_or_wait)
    else $error("APB: ACCESS occurred without SETUP or a preceding wait");

  // -----------------------------------------------------------------------
  // APB4 Rule: PSTRB must be low (all zeros) for READ transfers.
  // -----------------------------------------------------------------------
  property pstrb_low_during_read;
    @(posedge pclk) disable iff (!prstn)
      (psel && !pwrite) |-> (pstrb == '0);
  endproperty
  PSTRB_LOW_DURING_READ: assert property (pstrb_low_during_read)
    else $error("APB: PSTRB is not zero during a read transfer");

endinterface

`endif
