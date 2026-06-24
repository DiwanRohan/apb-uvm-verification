// Slave-side monitor.  Observes APB signals through the slave monitor
// modport and emits apb_slv_seq_item transactions on item_collect_port.
// All monitoring logic is in the parameterised base class apb_base_mon.
class apb_slv_mon extends apb_base_mon #(apb_slv_seq_item);
  `uvm_component_utils(apb_slv_mon)

  function new(string name = "apb_slv_mon", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
