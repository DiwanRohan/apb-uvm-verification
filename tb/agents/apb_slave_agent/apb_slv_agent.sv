class apb_slv_agent extends uvm_agent;
  `uvm_component_utils(apb_slv_agent)

  apb_slv_mon mon_h;
  virtual apb_if vif;

  function new(string name = "apb_slv_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("SLV_AGENT", "Unable to get virtual interface")

    if (get_is_active() != UVM_PASSIVE)
      `uvm_fatal("SLV_AGENT", "Slave agent should be configured UVM_PASSIVE")
    mon_h = apb_slv_mon::type_id::create("mon_h", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon_h.vif = vif;
  endfunction
endclass
