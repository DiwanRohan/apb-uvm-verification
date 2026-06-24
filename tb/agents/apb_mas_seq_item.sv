class apb_mas_seq_item extends uvm_sequence_item;
  rand trans_kind_e          kind_e;
  rand bit [`ADDR_WIDTH-1:0] paddr;
  rand bit [`DATA_WIDTH-1:0] pwdata;
       bit [`DATA_WIDTH-1:0] prdata;
       bit                   pready;
       bit                   pslverr;
       int unsigned          wait_cycles;

  // Keep random traffic near the implemented address range so it exercises
  // both normal accesses and a few address-error responses.
  constraint address_c { paddr inside {[0:`DEPTH+3]}; }

  `uvm_object_utils_begin(apb_mas_seq_item)
    `uvm_field_enum(trans_kind_e, kind_e, UVM_ALL_ON)
    `uvm_field_int(paddr,       UVM_ALL_ON)
    `uvm_field_int(pwdata,      UVM_ALL_ON)
    `uvm_field_int(prdata,      UVM_ALL_ON)
    `uvm_field_int(pready,      UVM_ALL_ON)
    `uvm_field_int(pslverr,     UVM_ALL_ON)
    `uvm_field_int(wait_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_mas_seq_item");
    super.new(name);
  endfunction
endclass
