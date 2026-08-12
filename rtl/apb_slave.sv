`ifndef APB_SLAVE_SV
`define APB_SLAVE_SV

`include "apb_defines.sv"

module apb_slave #(
  parameter int ADDR_WIDTH = `ADDR_WIDTH,
  parameter int DATA_WIDTH = `DATA_WIDTH,
  parameter int DEPTH      = `DEPTH,
  parameter bit DEFAULT_PREADY = `DEFAULT_PREADY
) (
  input  logic                      pclk,
  input  logic                      prstn,
  input  logic                      psel,
  input  logic                      penable,
  input  logic [ADDR_WIDTH-1:0]     paddr,
  input  logic                      pwrite,
  input  logic [DATA_WIDTH-1:0]     pwdata,
  input  logic [(DATA_WIDTH/8)-1:0] pstrb,
  output logic                      pready,
  output logic [DATA_WIDTH-1:0]     prdata,
  output logic                      pslverr
);

  logic [DATA_WIDTH-1:0] mem [DEPTH];
  logic                  wait_active;
  logic [3:0]            wait_cnt;

  // --------------------------------------------------------
  // Memory write block: Handles asynchronous reset initialization 
  // and synchronous writes using PSTRB for byte-lane granular masking.
  // --------------------------------------------------------
  always_ff @(posedge pclk or negedge prstn) begin
    if (!prstn) begin
      for (int i = 0; i < DEPTH; i++) begin
        mem[i] <= '0;
      end
    end
    else if (psel && penable && pready && pwrite && (paddr < DEPTH)) begin
      for (int i = 0; i < DATA_WIDTH/8; i++) begin
        if (pstrb[i]) begin
          mem[paddr][i*8 +: 8] <= pwdata[i*8 +: 8];
        end
      end
    end
  end

  // --------------------------------------------------------
  // Memory read block: Combinational read from target address.
  // Data is safely driven only during the ACCESS phase (PENABLE=1).
  // --------------------------------------------------------
  always_comb begin
    prdata = '0;
    if (psel && penable && pready && !pwrite && (paddr < DEPTH))
      prdata = mem[paddr];
  end

  // --------------------------------------------------------
  // PREADY generation: Controls bus wait-states.
  // Stalls the master by holding PREADY low when wait_active is set.
  // --------------------------------------------------------
  always_comb begin
    if (DEFAULT_PREADY) begin
      pready = 1'b1;
      if (psel && penable && wait_active) begin
        pready = 1'b0;
      end
    end
    else begin
      pready = 1'b0;
      if (psel && penable && !wait_active) begin
        pready = 1'b1;
      end
    end
  end

  // --------------------------------------------------------
  // Wait state counter: State machine that injects synthetic delays 
  // based on the lower 2 bits of the accessed address.
  // --------------------------------------------------------
  always_ff @(posedge pclk or negedge prstn) begin
    if (!prstn) begin
      wait_active <= 1'b0;
      wait_cnt    <= 0;
    end
    else if (psel && !penable && !wait_active) begin
      // Address-dependent wait state latency mapping
      case (paddr[1:0])
        2'b01: begin
          wait_active <= 1'b1;
          wait_cnt    <= 1;
        end
        2'b10: begin
          wait_active <= 1'b1;
          wait_cnt    <= 3;
        end
        2'b11: begin
          wait_active <= 1'b1;
          wait_cnt    <= 12;
        end
        default: begin
          wait_active <= 1'b0;
          wait_cnt    <= 0;
        end
      endcase
    end
    else if (wait_active && psel && penable) begin
      if (wait_cnt > 1)
        wait_cnt <= wait_cnt - 1;
      else begin
        wait_cnt    <= 0;
        wait_active <= 1'b0;
      end
    end
  end

  // --------------------------------------------------------
  // PSLVERR generation: Asserts error response if the master 
  // attempts to access an out-of-bounds memory address.
  // --------------------------------------------------------
  always_comb begin
    pslverr = psel && penable && pready && (paddr >= DEPTH);
  end

endmodule

`endif
