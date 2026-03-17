# Synchronous FIFO — Verilog

Parameterized synchronous FIFO design implemented in Verilog and synthesized on Xilinx Artix-7.

## Features
- Configurable data width and depth (default: 8-bit, 16-deep)
- Full and empty flags
- Overflow and underflow protection
- Simultaneous read/write support
- Element count output

## Architecture
- Single-clock domain (synchronous)
- Dual pointer (read/write) with natural wrap (power-of-2 depth)
- Count register for status flag generation
- Memory implemented as distributed flip-flops (no BRAM at this depth)

## Synthesis Results
**Target:** Xilinx Artix-7 (xc7a35tcpg236-1) — Vivado 2025.2

| Resource        | Used | Available | Utilization |
|-----------------|------|-----------|-------------|
| Slice LUTs      |   13 |    20,800 |       0.06% |
| Slice Registers |   25 |    41,600 |       0.06% |
| Bonded IOBs     |   27 |       106 |      25.47% |
| Block RAM       |    0 |        50 |       0.00% |
| DSPs            |    0 |        90 |       0.00% |
| BUFG            |    1 |        32 |       3.13% |

### Primitives Breakdown
- **Flip-Flops:** 17 FDCE (async reset) + 8 FDRE (sync reset) = 25 total
- **LUTs:** 7×LUT6, 3×LUT1, 2×LUT5, 2×LUT2, 1×LUT4, 1×LUT3 = 13 total
- **IO:** 12 IBUF + 15 OBUF = 27 total
- **Clock:** 1 BUFG

## Simulation
Testbench covers:
- Reset behavior and flag initialization
- FIFO ordering (write 4, read 4)
- Full flag and overflow protection
- Empty flag and underflow protection
- Simultaneous read/write stability

**Tool:** Vivado 2025.2 Behavioral Simulation

## Repository Structure
```
sync_fifo/
├── rtl/
│   └── sync_fifo.v
├── testbench/
│   └── tb_sync_fifo.v
├── docs/
│   └── sync_fifo_utilization_synth.rpt
└── README.md
```

## Tools
- Verilog (IEEE 1364-2005)
- Xilinx Vivado 2025.2
- Target FPGA: xc7a35tcpg236-1

## What's Next
- Asynchronous FIFO (dual-clock, Gray code pointers)
- Integration with AXI4-Lite interconnect
