`ifndef APB_COVERAGE_SV
`define APB_COVERAGE_SV

class apb_coverage extends uvm_subscriber #(apb_mas_seq_item);
  `uvm_component_utils(apb_coverage)

  localparam int unsigned AddrSpace = (1 << `ADDR_WIDTH);
  localparam int unsigned AddrLowMin = 0;
  localparam int unsigned AddrLowMax = (AddrSpace / 4) - 1;
  localparam int unsigned AddrLowMidMin = AddrSpace / 4;
  localparam int unsigned AddrLowMidMax = (AddrSpace / 2) - 1;
  localparam int unsigned AddrHighMidMin = AddrSpace / 2;
  localparam int unsigned AddrHighMidMax = ((3 * AddrSpace) / 4) - 1;
  localparam int unsigned AddrHighMin = (3 * AddrSpace) / 4;
  localparam int unsigned AddrHighMax = AddrSpace - 1;

  localparam bit [`DATA_WIDTH-1:0] DataZero = '0;
  localparam bit [`DATA_WIDTH-1:0] DataMaxVal = {`DATA_WIDTH{1'b1}};
  localparam bit [`DATA_WIDTH-1:0] DataQ1Max = DataMaxVal >> 2;
  localparam bit [`DATA_WIDTH-1:0] DataQ2Max = DataMaxVal >> 1;
  localparam bit [`DATA_WIDTH-1:0] DataQ3Max = DataQ1Max + DataQ2Max + 1'b1;

  apb_mas_seq_item last_trans;

  trans_kind_e sample_kind;
  bit [`ADDR_WIDTH-1:0] sample_paddr;
  bit [`DATA_WIDTH-1:0] sample_pwdata;
  bit [`DATA_WIDTH-1:0] sample_prdata;
  bit sample_pslverr;
  int unsigned sample_wait_cycles;

  int unsigned total_samples;
  int unsigned write_samples;
  int unsigned read_samples;

  covergroup apb_transfer_cg;

    option.per_instance = 1;
    option.name = "apb_transfer_cg";

    cp_kind: coverpoint sample_kind {
      bins read  = {READ};
      bins write = {WRITE};
    }

    cp_addr_region: coverpoint sample_paddr {
      bins low_range     = {[AddrLowMin     : AddrLowMax]};
      bins lowmid_range  = {[AddrLowMidMin  : AddrLowMidMax]};
      bins highmid_range = {[AddrHighMidMin : AddrHighMidMax]};
      bins high_range    = {[AddrHighMin    : AddrHighMax]};
    }

    cp_addr_boundary: coverpoint sample_paddr {
      bins first_addr = {AddrLowMin};
      bins last_addr  = {AddrHighMax};
      bins other_addr = default;
    }

    cp_kind_transition: coverpoint sample_kind {
      bins write_to_write = (WRITE => WRITE);
      bins write_to_read  = (WRITE => READ);
      bins read_to_write  = (READ  => WRITE);
      bins read_to_read   = (READ  => READ);
    }

    cp_wait_state: coverpoint sample_wait_cycles {
      bins no_wait = {0};
      ignore_bins wait_not_enabled = {[1:32'hffff_ffff]};
    }

    cp_response: coverpoint sample_pslverr {
      bins no_error = {0};
      illegal_bins unexpected_error = {1};
    }

    cross_kind_addr_region: cross cp_kind, cp_addr_region;

  endgroup

  covergroup apb_write_data_cg;

    option.per_instance = 1;
    option.name = "apb_write_data_cg";

    cp_write_data: coverpoint sample_pwdata {
      bins zero         = {DataZero};
      bins low_range    = {[DataZero + 1'b1 : DataQ1Max]};
      bins lowmid_range = {[DataQ1Max + 1'b1 : DataQ2Max]};
      bins highmid_range = {[DataQ2Max + 1'b1 : DataQ3Max]};
      bins high_range   = {[DataQ3Max + 1'b1 : DataMaxVal - 1'b1]};
      bins max_value    = {DataMaxVal};
    }

  endgroup

  covergroup apb_read_data_cg;

    option.per_instance = 1;
    option.name = "apb_read_data_cg";

    cp_read_data: coverpoint sample_prdata {
      bins zero         = {DataZero};
      bins low_range    = {[DataZero + 1'b1 : DataQ1Max]};
      bins lowmid_range = {[DataQ1Max + 1'b1 : DataQ2Max]};
      bins highmid_range = {[DataQ2Max + 1'b1 : DataQ3Max]};
      bins high_range   = {[DataQ3Max + 1'b1 : DataMaxVal - 1'b1]};
      bins max_value    = {DataMaxVal};
    }

  endgroup

  function new(string name = "apb_coverage", uvm_component parent = null);
    super.new(name, parent);
    apb_transfer_cg = new();
    apb_write_data_cg = new();
    apb_read_data_cg = new();
  endfunction

  virtual function void write(apb_mas_seq_item t);
    sample_coverage(t);
  endfunction

  function void sample_coverage(apb_mas_seq_item trans);

    if (trans == null) begin
      `uvm_error("COV", "Null transaction sample ignored")
      return;
    end

    $cast(last_trans, trans.clone());

    sample_kind = last_trans.kind_e;
    sample_paddr = last_trans.paddr;
    sample_pwdata = last_trans.pwdata;
    sample_prdata = last_trans.prdata;
    sample_pslverr = last_trans.pslverr;
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

  function real get_functional_coverage();

    real transfer_cov;
    real write_data_cov;
    real read_data_cov;

    transfer_cov = apb_transfer_cg.get_coverage();
    write_data_cov = (write_samples > 0) ? apb_write_data_cg.get_coverage() : 100.0;
    read_data_cov = (read_samples > 0) ? apb_read_data_cg.get_coverage() : 100.0;

    return ((transfer_cov + write_data_cov + read_data_cov) / 3.0);

  endfunction

  function void report();

    $display("======================================");
    $display("FUNCTIONAL COVERAGE = %0.2f %% ", get_functional_coverage());
    $display("  Transfer coverage = %0.2f %%", apb_transfer_cg.get_coverage());
    $display("  Write data coverage = %0.2f %%", apb_write_data_cg.get_coverage());
    $display("  Read data coverage = %0.2f %%", apb_read_data_cg.get_coverage());
    $display("  Samples total/write/read = %0d/%0d/%0d",
             total_samples, write_samples, read_samples);
    $display("======================================");

  endfunction

endclass

`endif
