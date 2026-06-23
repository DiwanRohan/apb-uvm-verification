# APB UVM Verification Environment

## Overview

This project implements a UVM-based verification environment for an APB Slave DUT.

### Features Verified

- Read Transactions
- Write Transactions
- Back-to-Back Transfers
- Wait State Handling
- PSLVERR Handling
- Address Checking
- Functional Coverage
- Scoreboard-Based Data Checking

## Verification Architecture

Master Agent
- Sequencer
- Driver
- Monitor

Environment
- Scoreboard
- Coverage

## Tools

- SystemVerilog
- UVM 1.2
- QuestaSim

## Running

```bash
make sanity
make random


---

## 4. Create .gitignore

Very important.

```gitignore
# Questa

work/
transcript
modelsim.ini
*.wlf
*.ucdb
*.log

# Coverage

cov_html/

# Waveforms

*.vcd
*.vpd
*.fsdb

# OS

.DS_Store
Thumbs.db

# VSCode

.vscode/