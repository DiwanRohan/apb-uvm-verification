class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp #(apb_mas_seq_item, apb_scoreboard) analysis_export;

  bit [`DATA_WIDTH-1:0] ref_mem [`DEPTH];

  int unsigned write_count;
  int unsigned read_count;
  int unsigned error_count;
  int unsigned compared_count;

  int fail_cnt;
  int pass_cnt;

  function new(string name = "apb_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export = new("analysis_export", this);
    foreach (ref_mem[i])
      ref_mem[i] = '0;
  endfunction

  // Called by the analysis port on every monitored transaction.
  function void write(apb_mas_seq_item item);
    compared_count++;
    check_response(item);
  endfunction

  function void check_response(apb_mas_seq_item item);
    bit [`DATA_WIDTH-1:0] expected;

    // Out-of-range address — expect PSLVERR.
    if (item.paddr >= `DEPTH) begin
      if (!item.pslverr) begin
        error_count++;
        `uvm_error("SB", $sformatf(
          "missing PSLVERR for out-of-range address 0x%0h", item.paddr))
      end
      return;
    end

    // Valid address — unexpected PSLVERR.
    if (item.pslverr) begin
      error_count++;
      `uvm_error("SB", $sformatf(
        "unexpected PSLVERR for valid address 0x%0h", item.paddr))
      return;
    end

    case (item.kind_e)
      WRITE: begin
        write_count++;
        for (int i = 0; i < `DATA_WIDTH/8; i++) begin
          if (item.pstrb[i]) begin
            ref_mem[item.paddr][i*8 +: 8] = item.pwdata[i*8 +: 8];
          end
        end
        `uvm_info("SB", $sformatf("WRITE PASS addr=0x%0h data=0x%0h pstrb=0x%0h",
          item.paddr, item.pwdata, item.pstrb), UVM_LOW)
      end

      READ: begin
        read_count++;
        expected = ref_mem[item.paddr];
        if (expected != item.prdata) begin
          error_count++;
          `uvm_error("SB", $sformatf(
            "READ FAIL addr=0x%0h expected=0x%0h actual=0x%0h",
            item.paddr, expected, item.prdata))
        end else begin
          `uvm_info("SB", $sformatf(
            "READ PASS addr=0x%0h data=0x%0h", item.paddr, item.prdata), UVM_LOW)
        end
      end

      default: begin
      end
    endcase
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SB_REPORT", $sformatf(
      "writes=%0d reads=%0d transactions=%0d errors=%0d",
      write_count, read_count, compared_count, error_count), UVM_NONE)
    fail_cnt = error_count;
    if (compared_count > error_count)
      pass_cnt = compared_count - error_count;
    else
      pass_cnt = 0;
  endfunction

endclass
