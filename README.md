# APB UVM Verification Environment

This repository verifies a memory-backed APB slave with UVM 1.2 and QuestaSim.

## Transaction flow

1. A sequence creates an `apb_mas_seq_item`.
2. The active master agent's sequencer passes it to the master driver.
3. The driver performs APB SETUP and ACCESS phases and holds controls while `PREADY` is low.
4. The DUT completes the read or write and returns `PRDATA`, `PREADY`, and `PSLVERR`.
5. The master monitor publishes an `apb_mas_seq_item` and the passive slave monitor publishes an independent `apb_slv_seq_item`.
6. The scoreboard checks the two monitor streams against each other and checks the slave response against its reference memory.

## UVM hierarchy

```text
apb_test
└── apb_env
    ├── mas_agent_h (UVM_ACTIVE)
    │   ├── seqr_h
    │   ├── drv_h
    │   └── mon_h
    ├── slv_agent_h (UVM_PASSIVE)
    │   └── mon_h
    ├── scoreboard_h
    └── cov
```

The slave agent is deliberately passive: it observes DUT responses but never drives the bus and therefore has no sequencer or driver.

## Implemented checks

- APB read and write transfers
- Address-dependent wait-state handling (0, 1, 3, 12 cycles)
- Valid and out-of-range address responses
- `PSLVERR` checking
- Master/slave monitor agreement
- Scoreboard memory readback
- APB protocol assertions

## Running

Run commands from the `sim` directory:

```sh
make sanity
make write
make read
make random
make gui TEST=apb_sanity_test
make cov TEST=apb_random_test
```

`compile.do` locates the Questa installation from the running simulator and maps its precompiled UVM 1.2 library.
