class apb_base_test extends uvm_test;

  `uvm_component_utils(apb_base_test)

  static apb_base_test test;

  apb_env env_h;
  apb_env env;

  function new(string name="apb_base_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    test = this;
    env_h = apb_env::type_id::create("env_h",this);
    env = env_h;
  endfunction

endclass
