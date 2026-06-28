class apb_mas_agent extends uvm_agent;
  `uvm_component_utils(apb_mas_agent)

  apb_mas_drv  drv_h;
  apb_mas_mon  mon_h;
  apb_mas_seqr seqr_h;
  virtual apb_if vif;

  function new(string name = "apb_mas_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("MAS_AGENT", "Unable to get virtual interface")

    mon_h = apb_mas_mon::type_id::create("mon_h", this);
    if (get_is_active() == UVM_ACTIVE) begin
      drv_h  = apb_mas_drv::type_id::create("drv_h", this);
      seqr_h = apb_mas_seqr::type_id::create("seqr_h", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon_h.vif = vif;
    if (get_is_active() == UVM_ACTIVE) begin
      drv_h.vif = vif;
      drv_h.seq_item_port.connect(seqr_h.seq_item_export);
    end
  endfunction
endclass
