// Wait-state diagnostic sequence.
// Verifies that address-dependent wait states are correctly generated
// and observed by the driver:
// - paddr[1:0] == 2'b00 -> 0 wait cycles
// - paddr[1:0] == 2'b01 -> 1 wait cycle
// - paddr[1:0] == 2'b10 -> 3 wait cycles
// - paddr[1:0] == 2'b11 -> 12 wait cycles
class apb_waitstate_seq extends apb_base_seq;
  `uvm_object_utils(apb_waitstate_seq)

  function new(string name = "apb_waitstate_seq");
    super.new(name);
  endfunction

  task body();
    apb_mas_seq_item req;

    // --- Case 0: WRITE to 0x4 (ends in 2'b00, expected wait = 0) ---
    req = apb_mas_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      kind_e == WRITE;
      paddr  == 32'h0000_0004;
      pwdata == 32'hAAAA_AAAA;
    })
      `uvm_fatal("WAIT_SEQ", "WRITE 0x4 randomization failed")
    finish_item(req);

    if (req.wait_cycles != 0)
      `uvm_error("WAIT_SEQ", $sformatf(
        "WRITE 0x4 (2'b00) should have 0 wait cycles, got %0d", req.wait_cycles))

    // --- Case 1: WRITE to 0x5 (ends in 2'b01, expected wait = 1) ---
    req = apb_mas_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      kind_e == WRITE;
      paddr  == 32'h0000_0005;
      pwdata == 32'hBBBB_BBBB;
    })
      `uvm_fatal("WAIT_SEQ", "WRITE 0x5 randomization failed")
    finish_item(req);

    if (req.wait_cycles != 1)
      `uvm_error("WAIT_SEQ", $sformatf(
        "WRITE 0x5 (2'b01) should have 1 wait cycle, got %0d", req.wait_cycles))

    // --- Case 2: WRITE to 0x6 (ends in 2'b10, expected wait = 3) ---
    req = apb_mas_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      kind_e == WRITE;
      paddr  == 32'h0000_0006;
      pwdata == 32'hCCCC_CCCC;
    })
      `uvm_fatal("WAIT_SEQ", "WRITE 0x6 randomization failed")
    finish_item(req);

    if (req.wait_cycles != 3)
      `uvm_error("WAIT_SEQ", $sformatf(
        "WRITE 0x6 (2'b10) should have 3 wait cycles, got %0d", req.wait_cycles))

    // --- Case 3: WRITE to 0x7 (ends in 2'b11, expected wait = 12) ---
    req = apb_mas_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      kind_e == WRITE;
      paddr  == 32'h0000_0007;
      pwdata == 32'hDDDD_DDDD;
    })
      `uvm_fatal("WAIT_SEQ", "WRITE 0x7 randomization failed")
    finish_item(req);

    if (req.wait_cycles != 12)
      `uvm_error("WAIT_SEQ", $sformatf(
        "WRITE 0x7 (2'b11) should have 12 wait cycles, got %0d", req.wait_cycles))

    // --- Case 4: READ from 0x5 (ends in 2'b01, expected wait = 1) ---
    req = apb_mas_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      kind_e == READ;
      paddr  == 32'h0000_0005;
    })
      `uvm_fatal("WAIT_SEQ", "READ 0x5 randomization failed")
    finish_item(req);

    if (req.wait_cycles != 1)
      `uvm_error("WAIT_SEQ", $sformatf(
        "READ 0x5 (2'b01) should have 1 wait cycle, got %0d", req.wait_cycles))

    `uvm_info("WAIT_SEQ", "Wait-state sequence complete successfully", UVM_LOW)
  endtask

endclass
