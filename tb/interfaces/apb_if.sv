///////////////////////////////////
//
//------------------HEADER---------------------
//FILE NAME: apb_if.sv
//AUTHOR NAME: Rohan Diwan
//INTERFACE NAME: apb_if
//DESCRIPTION: This file contains the interface and modports for the project RAM_verification, it also defines a clocking block which will defining the input and output skew which will tell us when the sampling and driving will happen during posedge.
//Version: 1
//Date: 14-04-2026
//Time: 12:15 pm
//
/////////////////////////////////////

//Guard Statement to avoid multiple compilation of a file
`ifndef APB_INF_SV
`define APB_INF_SV

`include "apb_defines.sv"

interface apb_if (
    input logic pclk
);

  //ACTIVE LOW RESET SIGNAL
  logic                   prstn;

  //APB CONTROL SIGNALS
  logic                   psel;
  logic                   penable;
  logic                   pwrite;

  //APB ADDRESS/DATA
  logic [`ADDR_WIDTH-1:0] paddr;
  logic [`DATA_WIDTH-1:0] pwdata;
  logic [`DATA_WIDTH-1:0] prdata;

  //APB SLAVE SIGNALS
  logic                   pready;
  logic                   pslverr;


  //DRIVER CLOCKING BLOCK
  clocking mas_drv_cb @(posedge pclk);

    default input #1 output #1;

    //DRIVEN TO DUT
    output prstn;

    output psel;
    output penable;
    output pwrite;

    output paddr;
    output pwdata;

    //SAMPLED FROM DUT
    input prdata;
    input pready;
    input pslverr;

  endclocking

  //MONITOR CLOCKING BLOCK
  clocking mon_cb @(posedge pclk);

    default input #1;

    input prstn;

    input psel;
    input penable;
    input pwrite;

    input paddr;
    input pwdata;

    input prdata;
    input pready;
    input pslverr;

  endclocking

  //MODPORTS
  modport MAS_DRV_MP(clocking mas_drv_cb);

  modport MAS_MON_MP(clocking mon_cb);

  modport SLV_MON_MP(clocking mon_cb);

  //----------------------------------
  //ASSERTIONS
  //----------------------------------

  //Assertion 1
  //When penable is high psel should be high
  property penable_psel_check;

    @(posedge pclk) disable iff (!prstn) penable |-> psel;
  endproperty

  assert property (penable_psel_check)
  else $error("APB ASSERTION FAILED: PENABLE asserted without PSEL");

  //Assertion 2
  //SETUP should always go to ACCESS in next clock cycle
  property setup_to_access_check;

    @(posedge pclk) disable iff (!prstn) (psel && !penable) |=> penable;
  endproperty

  assert property (setup_to_access_check)
  else $error("APB ASSERTION FAILED: SETUP did not transition to ACCESS");

  //Assertion 3
  //PADDR must be stable during pready is low and in ACCESS state
  property p_addr_stable_wait;

    @(posedge pclk) disable iff (!prstn) (psel && penable && !pready) |-> $stable(
        paddr
    );

  endproperty

  assert property (p_addr_stable_wait)
  else $error("APB ASSERTION FAILED : PADDR changed during wait state");

  //Assertion 4
  //PWRITE must be stable during pready is low and in ACCESS state
  property p_write_stable_wait;

    @(posedge pclk) disable iff (!prstn) (psel && penable && !pready) |-> $stable(
        pwrite
    );

  endproperty

  assert property (p_write_stable_wait)
  else $error("APB ASSERTION FAILED : PWRITE changed during wait state");

  //Assertion 5
  //PWDATA must be stable during pready is low and in ACCESS state
  property p_pwdata_stable_wait;

    @(posedge pclk) disable iff (!prstn) (psel && penable && !pready && pwrite) |-> $stable(
        pwdata
    );

  endproperty

  assert property (p_pwdata_stable_wait)
  else $error("APB ASSERTION FAILED : PWDATA changed during write wait state");

  //Assetion 6
  //PSEL must remain high for wait states
  property p_psel_hold_wait;

    @(posedge pclk) disable iff (!prstn) (psel && penable && !pready) |-> psel;

  endproperty

  assert property (p_psel_hold_wait)
  else $error("APB ASSERTION FAILED : PSEL dropped during wait state");

  //Assetion 7
  //PENABLE must remain high for wait states
  property p_penable_hold_wait;

    @(posedge pclk) disable iff (!prstn) (psel && penable && !pready) |-> penable;

  endproperty

  assert property (p_penable_hold_wait)
  else $error("APB ASSERTION FAILED : PENABLE dropped during wait state");

  //Assertion 8
  //No unknown signal on any of the control signals
  property p_no_unknown_control;

    @(posedge pclk) disable iff (!prstn) !$isunknown(
        {psel, penable, pwrite, pready}
    );

  endproperty

  ap_no_unkown_control :
  assert property (p_no_unknown_control)
  else $error("APB ASSERTION FAILED : Unknown value detected on control signals");

  //Asserion 9
  //PSLVERR must valid only at the end of transaction
  property p_pslverr_valid;

    @(posedge pclk) disable iff (!prstn) pslverr |-> (psel && penable && pready);

  endproperty

  assert property (p_pslverr_valid)
  else $error("APB ASSERTION FAILED : PSLVERR asserted outside valid transfer completion");

  //Assertin 10
  //When reset happens psel and penable should be low
  property p_reset_behavior;

    @(posedge pclk) !prstn |-> (!psel && !penable);

  endproperty

  assert property (p_reset_behavior)
  else $error("APB ASSERTION FAILED : Invalid signal values during reset");

  //Assertion 11
  //ACCESS should come after SETUP
  property p_access_after_setup;

    @(posedge pclk) disable iff (!prstn) penable |-> $past(
        psel
    );

  endproperty

  assert property (p_access_after_setup)
  else $error("APB ASSERTION FAILED : ACCESS occurred without prior SETUP");

  //Assertion 12
  //IDLE state conditions check
  property p_idle_state_valid;

    @(posedge pclk) disable iff (!prstn) !psel |-> !penable;

  endproperty

  assert property (p_idle_state_valid)
  else $error("APB ASSERTION FAILED : Invalid IDLE state");

endinterface

`endif
