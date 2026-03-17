# Synchronous FIFO — Verilog

A parameterized synchronous FIFO design implemented in Verilog, featuring configurable data width and depth with full/empty status flags and overflow/underflow protection.

## Project Overview

This project implements a synchronous (single-clock) FIFO buffer, a fundamental building block used in digital systems for data buffering, rate matching, and pipeline decoupling.

## Features

* Parameterized data width and depth (default: 8-bit, 16-deep)
* Full and empty status flags
* Overflow and underflow protection
* Simultaneous read/write support
* Element count output
* Synthesis-verified design (Xilinx Artix-7 FPGA)

## Architecture

### FIFO Module (`sync_fifo.v`)

* Single-clock domain (synchronous)
* Dual pointer architecture (read/write) with natural wrap
* Count register for status flag generation
* Memory implemented as distributed flip-flops (no BRAM at this depth)
* Power-of-2 depth for efficient pointer wrapping

### Key Signals

* `wr_en` / `rd_en` — Write and read enable controls
* `wr_data` / `rd_data` — Data input and output buses
* `full` / `empty` — Status flags driven by count register
* `count` — Current number of elements in FIFO

## Resource Utilization

Synthesized for Xilinx Artix-7 (xc7a35tcpg236-1):

| Resource        | Used | Available | Utilization |
|-----------------|------|-----------|-------------|
| Slice LUTs      |   13 |    20,800 |       0.06% |
| Slice Registers |   25 |    41,600 |       0.06% |
| Bonded IOBs     |   27 |       106 |      25.47% |
| Block RAM       |    0 |        50 |       0.00% |
| DSPs            |    0 |        90 |       0.00% |
| BUFG            |    1 |        32 |       3.13% |

### Primitives Breakdown

* **Flip-Flops:** 17 FDCE (async reset) + 8 FDRE (sync reset) = 25 total
* **LUTs:** 7×LUT6, 3×LUT1, 2×LUT5, 2×LUT2, 1×LUT4, 1×LUT3 = 13 total
* **IO:** 12 IBUF + 15 OBUF = 27 total
* **Clock:** 1 BUFG

0 Latches — Clean RTL design with no combinational loops

## Getting Started

### Prerequisites

* ModelSim / Vivado Simulator / Icarus Verilog
* Xilinx Vivado (for synthesis)

### Running Simulation
```
# Using Icarus Verilog
iverilog -o sim rtl/sync_fifo.v testbench/tb_sync_fifo.v
vvp sim

# Using Vivado
# Add sync_fifo.v as design source, tb_sync_fifo.v as simulation source
# Run Simulation → Run Behavioral Simulation
```

### Synthesis

1. Open Vivado and create new project
2. Add `sync_fifo.v` from `rtl/` directory
3. Set `sync_fifo` as top module
4. Run Synthesis → Report Utilization

## Project Structure
```
sync_fifo/
├── rtl/                    # RTL source files
│   └── sync_fifo.v
├── testbench/              # Verification files
│   └── tb_sync_fifo.v
├── docs/                   # Documentation
│   └── sync_fifo_utilization_synth.rpt
└── README.md
```

## Verification

The testbench performs the following tests:

1. Empty flag correct after reset
2. Write 4 values, read back in FIFO order
3. Fill FIFO to full, verify full flag
4. Write when full — overflow protection
5. Drain entire FIFO, verify empty flag
6. Read when empty — underflow protection
7. Simultaneous read/write — count stability

**Result:** 
<img width="1913" height="1127" alt="Waveform" src="https://github.com/user-attachments/assets/928e0db1-a690-4dc2-8e92-e41c32e58ce3" />


## Technologies Used

* **HDL:** Verilog
* **Simulation:** Vivado 2025.2 Behavioral Simulation
* **Synthesis:** Xilinx Vivado 2025.2
* **Target Device:** Xilinx Artix-7 FPGA (xc7a35tcpg236-1)

## Key Concepts Demonstrated

* Synchronous FIFO architecture
* Parameterized RTL design
* Dual-pointer memory management
* Status flag generation
* Overflow/underflow protection
* Simultaneous read/write handling
* Synthesizable RTL coding practices

## What's Next

* Asynchronous FIFO (dual-clock, Gray code pointers)
* Integration with AXI4-Lite interconnect

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Akshith Kumar Sambugari**

* Email: sambugariakshith@gmail.com
* LinkedIn: [www.linkedin.com/in/akshithkumar](https://www.linkedin.com/in/akshithkumar)
