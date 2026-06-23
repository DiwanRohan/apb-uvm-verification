`ifndef APB_SLAVE_SV
`define APB_SLAVE_SV

`include "apb_defines.sv"

module apb_slave (

    input logic pclk,
    input logic prstn,

    input logic psel,
    input logic penable,

    input logic [`ADDR_WIDTH-1:0] paddr,
    input logic                   pwrite,
    input logic [`DATA_WIDTH-1:0] pwdata,

    output logic                   pready,
    output logic [`DATA_WIDTH-1:0] prdata,
    output logic                   pslverr
);

  //MEMORY
  logic [`DATA_WIDTH-1:0] mem[`DEPTH];

  //WAIT STATE CONTROL
  logic wait_active;

  integer wait_cnt;

  //WAIT INJECTION
  logic inject_wait;

  //CUSTOM WAIT INJECTION
  integer INJECT_WAIT_AT;

  initial begin

    inject_wait = 1'b0;

    #`INJECT_WAIT_AT;
    inject_wait = 1'b1;
    #2;

    @(posedge pclk);
    inject_wait = 1'b0;

  end

  //WRITE
  always_ff @(posedge pclk or negedge prstn) begin

    integer i;

    if (!prstn) begin

      for (i = 0; i < `DEPTH; i++) mem[i] <= 'x;

    end else if (psel && penable && pready && pwrite && (paddr < `DEPTH)) mem[paddr] <= pwdata;

  end

  //READ
  always_comb begin

    if (!prstn) prdata = 'x;

    else if (psel && penable && pready && !pwrite && (paddr < `DEPTH)) prdata = mem[paddr];

    else prdata = 'x;

  end

  //PREADY GENERATION
  always_comb begin

    //DEFAULT
    pready = `DEFAULT_PREADY;

    //ACCESS PHASE ONLY
    if (psel && penable) begin

      // WAIT STATE ACTIVE
      if (wait_active) pready = 1'b0;

      //READY
      else
        pready = 1'b1;

    end
  end

  //WAIT STATE CONTROL
  always_ff @(posedge pclk or negedge prstn) begin

    if (!prstn) begin
      wait_active <= 1'b0;
      wait_cnt    <= 0;
    end else begin

      //START WAIT
      if (psel && !penable && inject_wait && !wait_active) begin

        wait_active <= 1'b1;
        wait_cnt    <= `WAIT_CNT;

      end  //COUNT WAIT CYCLES
      else if (wait_active && psel && penable) begin

        if (wait_cnt > 1) wait_cnt <= wait_cnt - 1;

        else begin
          wait_cnt    <= 0;
          wait_active <= 1'b0;
        end
      end
    end
  end

  //PSLVERR
  always_comb begin

    pslverr = 1'b0;

    if (psel && penable && (paddr >= `DEPTH)) pslverr = 1'b1;

  end

endmodule

`endif
