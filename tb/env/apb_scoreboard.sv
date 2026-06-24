`uvm_analysis_imp_decl(_mas)
`uvm_analysis_imp_decl(_slv)

class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp_mas #(apb_mas_seq_item, apb_scoreboard) mas_export;
  uvm_analysis_imp_slv #(apb_slv_seq_item, apb_scoreboard) slv_export;

  bit [`DATA_WIDTH-1:0] ref_mem [`DEPTH];
  apb_mas_seq_item mas_q[$];
  apb_slv_seq_item slv_q[$];

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
    mas_export = new("mas_export", this);
    slv_export = new("slv_export", this);
    foreach (ref_mem[i])
      ref_mem[i] = '0;
  endfunction

  function void write_mas(apb_mas_seq_item item);
    mas_q.push_back(item);
    compare_monitor_streams();
  endfunction

  function void write_slv(apb_slv_seq_item item);
    slv_q.push_back(item);
    check_slave_response(item);
    compare_monitor_streams();
  endfunction

  function void compare_monitor_streams();
    apb_mas_seq_item mas_item;
    apb_slv_seq_item slv_item;

    while (mas_q.size() > 0 && slv_q.size() > 0) begin
      mas_item = mas_q.pop_front();
      slv_item = slv_q.pop_front();
      compared_count++;

      if (mas_item.kind_e      != slv_item.kind_e      ||
          mas_item.paddr       != slv_item.paddr       ||
          mas_item.pwdata      != slv_item.pwdata      ||
          mas_item.prdata      != slv_item.prdata      ||
          mas_item.pslverr     != slv_item.pslverr     ||
          mas_item.wait_cycles != slv_item.wait_cycles) begin
        error_count++;
        `uvm_error("SB_MON_COMPARE",
          $sformatf("Master/slave monitor mismatch\nMASTER:\n%s\nSLAVE:\n%s",
            mas_item.sprint(), slv_item.sprint()))
      end
      else begin
        `uvm_info("SB_MON_COMPARE",
          $sformatf("both monitors matched %s addr=0x%0h",
            slv_item.kind_e.name(), slv_item.paddr), UVM_LOW)
      end
    end
  endfunction

  function void check_slave_response(apb_slv_seq_item item);
    bit [`DATA_WIDTH-1:0] expected;

    if (item.paddr >= `DEPTH) begin
      if (!item.pslverr) begin
        error_count++;
        `uvm_error("SB", $sformatf(
          "missing PSLVERR for out-of-range address 0x%0h", item.paddr))
      end
      return;
    end

    if (item.pslverr) begin
      error_count++;
      `uvm_error("SB", $sformatf(
        "unexpected PSLVERR for valid address 0x%0h", item.paddr))
      return;
    end

    case (item.kind_e)
      WRITE: begin
        write_count++;
        ref_mem[item.paddr] = item.pwdata;
        `uvm_info("SB", $sformatf("WRITE PASS addr=0x%0h data=0x%0h",
          item.paddr, item.pwdata), UVM_LOW)
      end

      READ: begin
        read_count++;
        expected = ref_mem[item.paddr];
        if (expected != item.prdata) begin
          error_count++;
          `uvm_error("SB", $sformatf(
            "READ FAIL addr=0x%0h expected=0x%0h actual=0x%0h",
            item.paddr, expected, item.prdata))
        end
        else begin
          `uvm_info("SB", $sformatf(
            "READ PASS addr=0x%0h data=0x%0h", item.paddr, item.prdata), UVM_LOW)
        end
      end
      default:begin
      end
    endcase
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (mas_q.size() != 0 || slv_q.size() != 0) begin
      error_count++;
      `uvm_error("SB", $sformatf(
        "unpaired monitor transactions: master=%0d slave=%0d",
        mas_q.size(), slv_q.size()))
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SB_REPORT", $sformatf(
      "writes=%0d reads=%0d monitor_pairs=%0d errors=%0d",
      write_count, read_count, compared_count, error_count), UVM_NONE)
    fail_cnt = error_count;
    if (compared_count > error_count)
      pass_cnt = compared_count - error_count;
    else
      pass_cnt = 0;
  endfunction
endclass
