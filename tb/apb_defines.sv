`ifndef APB_DEFINES_SV
`define APB_DEFINES_SV

`define ADDR_WIDTH        32
`define DATA_WIDTH        32
`define DEPTH             16        // Memory depth (number of addressable words)
`define DEFAULT_PREADY    1'b1
`define WAIT_CNT          2
`define INJECT_WAIT_AT    42        // 42 ns (timescale 1ns/1ps)

`endif
