`ifndef APB_SLAVE_SV
`define APB_SLAVE_SV

`include "apb_defines.sv"

module apb_slave (
  input  logic                   pclk,
  input  logic                   prstn,
  input  logic                   psel,
  input  logic                   penable,
  input  logic [`ADDR_WIDTH-1:0] paddr,
  input  logic                   pwrite,
  input  logic [`DATA_WIDTH-1:0] pwdata,
  output logic                   pready,
  output logic [`DATA_WIDTH-1:0] prdata,
  output logic                   pslverr
);

  logic [`DATA_WIDTH-1:0] mem [`DEPTH];
  logic                   wait_active;
  int unsigned            wait_cnt;

  always_ff @(posedge pclk or negedge prstn) begin
    integer i;
    if (!prstn) begin
      for (i = 0; i < `DEPTH; i++)
        mem[i] <= '0;
    end
    else if (psel && penable && pready && pwrite && (paddr < `DEPTH)) begin
      mem[paddr] <= pwdata;
    end
  end

  always_comb begin
    prdata = '0;
    if (prstn && psel && penable && pready && !pwrite && (paddr < `DEPTH))
      prdata = mem[paddr];
  end

  always_comb begin
    pready = `DEFAULT_PREADY;
    if (psel && penable && wait_active)
      pready = 1'b0;
  end

  always_ff @(posedge pclk or negedge prstn) begin
    if (!prstn) begin
      wait_active <= 1'b0;
      wait_cnt    <= 0;
    end
    else if (psel && !penable && !wait_active) begin
      // Synthesizable, address-dependent wait state latency mapping
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

  always_comb begin
    pslverr = psel && penable && pready && (paddr >= `DEPTH);
  end

endmodule

`endif
