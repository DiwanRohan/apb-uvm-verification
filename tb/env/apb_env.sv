class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)

  apb_mas_agent  mas_agent_h;
  apb_scoreboard scoreboard_h;
  apb_coverage   cov;

  function new(string name = "apb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_active_passive_enum)::set(
      this, "mas_agent_h", "is_active", UVM_ACTIVE);

    mas_agent_h  = apb_mas_agent::type_id::create("mas_agent_h", this);
    scoreboard_h = apb_scoreboard::type_id::create("scoreboard_h", this);
    cov          = apb_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mas_agent_h.mon_h.item_collect_port.connect(scoreboard_h.analysis_export);
    mas_agent_h.mon_h.item_collect_port.connect(cov.analysis_export);
  endfunction

endclass
