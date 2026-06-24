class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)

  apb_mas_agent  mas_agent_h;
  apb_slv_agent  slv_agent_h;
  apb_scoreboard scoreboard_h;

  function new(string name = "apb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_active_passive_enum)::set(
      this, "mas_agent_h", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(
      this, "slv_agent_h", "is_active", UVM_PASSIVE);

    mas_agent_h = apb_mas_agent::type_id::create("mas_agent_h", this);
    slv_agent_h = apb_slv_agent::type_id::create("slv_agent_h", this);
    scoreboard_h = apb_scoreboard::type_id::create("scoreboard_h", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mas_agent_h.mon_h.item_collect_port.connect(scoreboard_h.mas_export);
    slv_agent_h.mon_h.item_collect_port.connect(scoreboard_h.slv_export);
  endfunction
endclass
