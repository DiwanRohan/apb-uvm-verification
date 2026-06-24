class apb_base_test extends uvm_test;

  `uvm_component_utils(apb_base_test)

  apb_env env_h;

  function new(string name="apb_base_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = apb_env::type_id::create("env_h",this);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if ((env_h.scoreboard_h.fail_cnt == 0) &&
        (env_h.scoreboard_h.pass_cnt > 0)) begin
      $display(" ==========    ==========   ==========   ========== ");
      $display(" =        =    =        =   =            =          ");
      $display(" =        =    =        =   =            =          ");
      $display(" ==========    ==========   ==========   ========== ");
      $display(" =             =        =            =            = ");
      $display(" =             =        =            =            = ");
      $display(" =             =        =            =            = ");
      $display(" =             =        =   ==========   ========== ");
    end else begin
      $display(" ==========   ==========    ==========   =          ");
      $display(" =            =        =        =        =          ");
      $display(" =            =        =        =        =          ");
      $display(" ==========   ==========        =        =          ");
      $display(" =            =        =        =        =          ");
      $display(" =            =        =        =        =          ");
      $display(" =            =        =        =        =          ");
      $display(" =            =        =    ==========   ===========");
    end
    $display("Pass_cnt = %0d", env_h.scoreboard_h.pass_cnt);
    $display("Fail_cnt = %0d", env_h.scoreboard_h.fail_cnt);
    env_h.cov.report();
  endfunction

endclass
