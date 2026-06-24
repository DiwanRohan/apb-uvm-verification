`ifndef APB_COVERAGE_SV
`define APB_COVERAGE_SV

class apb_coverage extends uvm_subscriber #(apb_mas_seq_item);
  `uvm_component_utils(apb_coverage)

  // -----------------------------------------------------------------------
  // Localparams for data-value coverage bins.
  // These use fixed-width bit-vector arithmetic and do not overflow.
  // -----------------------------------------------------------------------
  localparam bit [`DATA_WIDTH-1:0] DataZero   = '0;
  localparam bit [`DATA_WIDTH-1:0] DataMaxVal = {`DATA_WIDTH{1'b1}};
  localparam bit [`DATA_WIDTH-1:0] DataQ1Max  = DataMaxVal >> 2;
  localparam bit [`DATA_WIDTH-1:0] DataQ2Max  = DataMaxVal >> 1;
  localparam bit [`DATA_WIDTH-1:0] DataQ3Max  = DataQ1Max + DataQ2Max + 1'b1;

  // Sampled each time a transaction arrives — used by covergroups.
  trans_kind_e              sample_kind;
  bit [`ADDR_WIDTH-1:0]     sample_paddr;
  bit [`DATA_WIDTH-1:0]     sample_pwdata;
  bit [`DATA_WIDTH-1:0]     sample_prdata;
  bit                       sample_pslverr;
  int unsigned              sample_wait_cycles;

  int unsigned total_samples;
  int unsigned write_samples;
  int unsigned read_samples;

  apb_mas_seq_item last_trans;

  // -----------------------------------------------------------------------
  // covergroup: transfer-level coverage
  // -----------------------------------------------------------------------
  covergroup apb_transfer_cg;
    option.per_instance = 1;
    option.name = "apb_transfer_cg";

    // Transaction direction.
    cp_kind: coverpoint sample_kind {
      bins read  = {READ};
      bins write = {WRITE};
    }

    // Address regions relative to the DUT memory map.
    // Bins are based on DEPTH, not on the full ADDR_WIDTH address space
    // (which would overflow a 32-bit int for ADDR_WIDTH=32).
    cp_addr_region: coverpoint sample_paddr {
      bins valid_low    = {[0         : `DEPTH/2-1]};   // lower half of memory
      bins valid_high   = {[`DEPTH/2  : `DEPTH-1  ]};   // upper half of memory
      bins out_of_range = {[`DEPTH    : `DEPTH+3  ]};   // OOB — per addr constraint
    }

    // Address boundary conditions.
    cp_addr_boundary: coverpoint sample_paddr {
      bins addr_zero    = {0};
      bins addr_max_mem = {`DEPTH-1};
      bins first_oob    = {`DEPTH};
      bins other        = default;
    }

    // Direction transitions (write-after-read / read-after-write etc.).
    cp_kind_transition: coverpoint sample_kind {
      bins write_to_write = (WRITE => WRITE);
      bins write_to_read  = (WRITE => READ);
      bins read_to_write  = (READ  => WRITE);
      bins read_to_read   = (READ  => READ);
    }

    // Wait-state coverage.
    // FIX: previously all non-zero counts were in ignore_bins, meaning
    //      wait states were NEVER covered.  Now each tier is a real bin.
    cp_wait_state: coverpoint sample_wait_cycles {
      bins no_wait    = {0};
      bins one_wait   = {1};
      bins multi_wait = {[2:10]};
      bins many_wait  = {[11:$]};
    }

    // Slave response coverage.
    // FIX: previously pslverr=1 was marked illegal_bins, causing a
    //      simulation warning every time the DUT correctly asserted
    //      PSLVERR for an out-of-range access.  It is a legal, expected
    //      response and must be a normal coverage bin.
    cp_response: coverpoint sample_pslverr {
      bins ok_response = {0};
      bins slv_error   = {1}; // Expected for OOB addresses — NOT illegal
    }

    // Cross: direction × address region.
    cross_kind_addr: cross cp_kind, cp_addr_region;

  endgroup

  // -----------------------------------------------------------------------
  // covergroup: write-data value coverage
  // -----------------------------------------------------------------------
  covergroup apb_write_data_cg;
    option.per_instance = 1;
    option.name = "apb_write_data_cg";

    cp_write_data: coverpoint sample_pwdata {
      bins zero          = {DataZero};
      bins low_range     = {[DataZero + 1'b1   : DataQ1Max          ]};
      bins lowmid_range  = {[DataQ1Max + 1'b1  : DataQ2Max          ]};
      bins highmid_range = {[DataQ2Max + 1'b1  : DataQ3Max          ]};
      bins high_range    = {[DataQ3Max + 1'b1  : DataMaxVal - 1'b1  ]};
      bins max_value     = {DataMaxVal};
    }
  endgroup

  // -----------------------------------------------------------------------
  // covergroup: read-data value coverage
  // -----------------------------------------------------------------------
  covergroup apb_read_data_cg;
    option.per_instance = 1;
    option.name = "apb_read_data_cg";

    cp_read_data: coverpoint sample_prdata {
      bins zero          = {DataZero};
      bins low_range     = {[DataZero + 1'b1   : DataQ1Max          ]};
      bins lowmid_range  = {[DataQ1Max + 1'b1  : DataQ2Max          ]};
      bins highmid_range = {[DataQ2Max + 1'b1  : DataQ3Max          ]};
      bins high_range    = {[DataQ3Max + 1'b1  : DataMaxVal - 1'b1  ]};
      bins max_value     = {DataMaxVal};
    }
  endgroup

  // -----------------------------------------------------------------------
  // Construction
  // -----------------------------------------------------------------------
  function new(string name = "apb_coverage", uvm_component parent = null);
    super.new(name, parent);
    apb_transfer_cg   = new();
    apb_write_data_cg = new();
    apb_read_data_cg  = new();
  endfunction

  // -----------------------------------------------------------------------
  // Analysis write — called by the analysis port on each transaction.
  // -----------------------------------------------------------------------
  virtual function void write(apb_mas_seq_item t);
    sample_coverage(t);
  endfunction

  // -----------------------------------------------------------------------
  // Sample all covergroups from one transaction.
  // -----------------------------------------------------------------------
  function void sample_coverage(apb_mas_seq_item trans);
    if (trans == null) begin
      `uvm_error("COV", "Null transaction received — sample ignored")
      return;
    end

    $cast(last_trans, trans.clone());

    sample_kind        = last_trans.kind_e;
    sample_paddr       = last_trans.paddr;
    sample_pwdata      = last_trans.pwdata;
    sample_prdata      = last_trans.prdata;
    sample_pslverr     = last_trans.pslverr;
    sample_wait_cycles = last_trans.wait_cycles;

    total_samples++;
    apb_transfer_cg.sample();

    if (sample_kind == WRITE) begin
      write_samples++;
      apb_write_data_cg.sample();
    end else begin
      read_samples++;
      apb_read_data_cg.sample();
    end
  endfunction

  // -----------------------------------------------------------------------
  // Aggregate coverage result (weighted average over all three groups).
  // -----------------------------------------------------------------------
  function real get_functional_coverage();
    real transfer_cov  = apb_transfer_cg.get_coverage();
    real write_data_cov = (write_samples > 0) ? apb_write_data_cg.get_coverage() : 100.0;
    real read_data_cov  = (read_samples  > 0) ? apb_read_data_cg.get_coverage()  : 100.0;
    return (transfer_cov + write_data_cov + read_data_cov) / 3.0;
  endfunction

  // -----------------------------------------------------------------------
  // FIX: use `uvm_info instead of $display so that verbosity filtering
  //      and log-file redirection are respected.
  // -----------------------------------------------------------------------
  function void report();
    `uvm_info("COV_REPORT", $sformatf(
      "\n======================================\n"
      "  FUNCTIONAL COVERAGE = %0.2f %%\n"
      "  Transfer coverage   = %0.2f %%\n"
      "  Write data coverage = %0.2f %%\n"
      "  Read  data coverage = %0.2f %%\n"
      "  Samples total/write/read = %0d/%0d/%0d\n"
      "======================================",
      get_functional_coverage(),
      apb_transfer_cg.get_coverage(),
      apb_write_data_cg.get_coverage(),
      apb_read_data_cg.get_coverage(),
      total_samples, write_samples, read_samples),
      UVM_NONE)
  endfunction

endclass

`endif
