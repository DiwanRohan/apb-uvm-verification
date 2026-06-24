// Master-side monitor.  Observes APB signals through the master monitor
// modport and emits apb_mas_seq_item transactions on item_collect_port.
// All monitoring logic is in the parameterised base class apb_base_mon.
class apb_mas_mon extends apb_base_mon #(apb_mas_seq_item);
  `uvm_component_utils(apb_mas_mon)

  function new(string name = "apb_mas_mon", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
