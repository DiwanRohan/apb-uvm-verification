class apb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(apb_scoreboard)

  // Analysis implementation port
  uvm_analysis_imp #(apb_mas_seq_item,
                     apb_scoreboard) item_collect_export;

  // Reference memory model
  bit [`DATA_WIDTH-1:0] ref_mem [`DEPTH];

  // Statistics
  int write_count;
  int read_count;
  int error_count;

  // Constructor
  function new(string name="apb_scoreboard",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    item_collect_export =
      new("item_collect_export", this);

    foreach(ref_mem[i])
      ref_mem[i] = '0;
  endfunction

  // Called automatically by analysis port
  function void write(apb_mas_seq_item item);

    bit [`DATA_WIDTH-1:0] expected;

    // Address range check
    if(item.paddr >= `DEPTH) begin
      error_count++;

      `uvm_error("SB",
        $sformatf("Address Out Of Range : ADDR = %0h",
                  item.paddr))
      return;
    end

    case(item.kind_e)

      WRITE: begin

        write_count++;

        ref_mem[item.paddr] = item.pwdata;

        `uvm_info("SB",
          $sformatf("WRITE PASS ADDR=%0h DATA=%0h",
                     item.paddr,
                     item.pwdata),
          UVM_LOW)

      end

      READ: begin

        read_count++;

        expected = ref_mem[item.paddr];

        if(expected == item.prdata) begin

          `uvm_info("SB",
            $sformatf("READ PASS ADDR=%0h EXP=%0h ACT=%0h",
                       item.paddr,
                       expected,
                       item.prdata),
            UVM_LOW)

        end
        else begin

          error_count++;

          `uvm_error("SB",
            $sformatf("READ FAIL ADDR=%0h EXP=%0h ACT=%0h",
                       item.paddr,
                       expected,
                       item.prdata))

        end

      end

      default: begin

        error_count++;

        `uvm_error("SB",
          $sformatf("Unknown transaction type"))

      end

    endcase

  endfunction

  // End of simulation report
  function void report_phase(uvm_phase phase);

    `uvm_info("SB_REPORT",
      $sformatf("\nWRITE COUNT = %0d\nREAD COUNT  = %0d\nERROR COUNT = %0d",
                write_count,
                read_count,
                error_count),
      UVM_NONE)

  endfunction

endclass
