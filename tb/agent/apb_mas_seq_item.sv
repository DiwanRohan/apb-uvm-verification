// Master sequence item — all APB transaction fields plus randomisation
// constraints for stimulus generation.
class apb_mas_seq_item extends uvm_sequence_item;

  // Stimulus fields — rand so the sequencer can constrain them.
  rand trans_kind_e              kind_e;      // READ or WRITE
  rand bit [`ADDR_WIDTH-1:0]     paddr;       // APB address
  rand bit [`DATA_WIDTH-1:0]     pwdata;      // Write data
  rand bit [(`DATA_WIDTH/8)-1:0] pstrb;       // Byte strobe

  // Response / output fields — populated by the driver/monitor, never rand.
  bit [`DATA_WIDTH-1:0] prdata;      // Read data returned by DUT
  bit                   pslverr;     // PSLVERR sampled at transfer completion
  int unsigned          wait_cycles; // Number of PREADY=0 cycles observed

  `uvm_object_utils_begin(apb_mas_seq_item)
    `uvm_field_enum(trans_kind_e, kind_e,     UVM_ALL_ON)
    `uvm_field_int (paddr,                    UVM_ALL_ON)
    `uvm_field_int (pwdata,                   UVM_ALL_ON)
    `uvm_field_int (pstrb,                    UVM_ALL_ON)
    `uvm_field_int (prdata,                   UVM_ALL_ON)
    `uvm_field_int (pslverr,                  UVM_ALL_ON)
    `uvm_field_int (wait_cycles,              UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_mas_seq_item");
    super.new(name);
  endfunction

  // 70 % of addresses hit valid memory; 30 % go out-of-range to exercise
  // the PSLVERR response path.  The range [DEPTH : DEPTH+3] is chosen so
  // that OOB accesses are close to the boundary (worst-case decoder).
  constraint address_c {
    paddr dist { [0      : `DEPTH-1  ] :/ 70,
                 [`DEPTH : `DEPTH+3  ] :/ 30 };
  }

  constraint pwdata_c {
    pwdata dist {
      '0                                                            :/ 10,
      [1 : ({`DATA_WIDTH{1'b1}}>>2)]                                :/ 20,
      [(({`DATA_WIDTH{1'b1}}>>2)+1) : ({`DATA_WIDTH{1'b1}}>>1)]       :/ 20,
      [(({`DATA_WIDTH{1'b1}}>>1)+1) : (({`DATA_WIDTH{1'b1}}>>1)+({`DATA_WIDTH{1'b1}}>>2)+1)] :/ 20,
      [((({`DATA_WIDTH{1'b1}}>>1)+({`DATA_WIDTH{1'b1}}>>2)+1)+1) : ({`DATA_WIDTH{1'b1}}-1)] :/ 20,
      {`DATA_WIDTH{1'b1}}                                           :/ 10
    };
  }

  constraint pstrb_c {
    if (kind_e == READ) {
      pstrb == '0;
    } else {
      pstrb inside {[1 : (1 << (`DATA_WIDTH/8)) - 1]};
    }
  }

endclass
