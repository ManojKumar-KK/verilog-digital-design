# 🧠 Decoder-Based RAM (4 x 8x8 memory banks)

![Language](https://img.shields.io/badge/HDL-Verilog-blue)
![Status](https://img.shields.io/badge/status-working-brightgreen)

A small Verilog project I built to understand how a **decoder** can be used to select between multiple RAM blocks — basically a mini "bank-switched memory" design.

## 📑 Table of Contents

- [What this project does](#-what-this-project-does)
- [Files in this project](#-files-in-this-project)
- [Module breakdown](#️-module-breakdown)
- [Testbench](#-testbench-decoder_based_ram_tbsv)
- [Why use a decoder here](#-why-use-a-decoder-here-the-actual-point-of-this-project)
- [Known quirks](#️-known-quirks--things-i-noticed)
- [What I learned](#-what-i-learned-from-this-project)
---

## 📌 What this project does

Instead of building one big RAM, this design uses:
- **4 separate 8x8 RAM blocks** (each stores 8 locations, 8 bits wide)
- **One 2-to-4 decoder** that picks *which* of the 4 RAM blocks is active
---

## 🧩 Files in this project

| File | Purpose |
|---|---|
| `Decoder_based_RAM.sv` | Main design — contains `decoder`, `ram_8x8`, and top module `Decoder_Ram` |
| `Decoder_based_RAM_tb.sv` | Testbench — writes data into different RAM banks and reads it back |

---

## 🏗️ Module breakdown

### 1. `decoder`
```
Input:  d_in  [1:0]   -> 2-bit select line
Output: d_out [3:0]   -> one-hot output (only 1 bit is HIGH at a time)
```
This is a classic **2-to-4 line decoder**. Truth table:

| d_in | d_out (cs3 cs2 cs1 cs0) |
|------|--------------------------|
| 00   | 0001                     |
| 01   | 0010                     |
| 10   | 0100                     |
| 11   | 1000                     |

Only the RAM block whose `cs` bit is `1` gets "woken up."

### 2. `ram_8x8`
A simple synchronous RAM:
- 8 memory locations (`addr` is 3 bits → 2³ = 8)
- Each location stores 8 bits (`data_in` / `data_out` are 8 bits wide)
- Works only when its own `cs` (chip select) is `1`
- On every clock edge:
  - if `rst` → clear `data_out`
  - else if `wr_en && cs` → write `data_in` into `RAM[addr]`
  - else if `rd_en && cs` → read `RAM[addr]` into `data_out`
  - else → `data_out` goes to 0

### 3. `Decoder_Ram` (top module)
This connects everything:
- Takes a 2-bit `select` signal
- Feeds it into the `decoder` → generates 4 chip-select lines (`cs[0]` to `cs[3]`)
- Each `cs` bit goes to one of the 4 `ram_8x8` instances (`r1`, `r2`, `r3`, `r4`)
- All 4 RAM blocks share the same `addr`, `data_in`, `clk`, `wr_en`, `rd_en`, `rst`
- A final `case` statement picks which RAM block's output (`data_out0..3`) actually reaches the top-level `data_out`, based on `select`
---

## 🧪 Testbench (`Decoder_based_RAM_tb.sv`)

The testbench does this sequence:
1. Generates a clock (`#5` toggle → 10ns period)
2. Applies reset for 1 cycle
3. **Writes** 4 different values into 4 different RAM banks:
   - `write(10, select=1)` → 10 goes into RAM bank 1, address 0
   - `write(20, select=2)` → 20 goes into RAM bank 2, address 0
   - `write(30, select=3)` → 30 goes into RAM bank 3, address 0
   - `write(50, select=0)` → 50 goes into RAM bank 0, address 0
4. **Reads back** from all 4 banks in order (0, 1, 2, 3) and checks the correct value comes out on `data_out`
5. Dumps a `.vcd` waveform file for viewing in GTKWave/similar tools

This proves the decoder is correctly isolating each bank — each RAM only responds when its `cs` line is high, so writing to one bank never disturbs the others.

---

## 🧠 Why use a decoder here? (the actual point of this project)

Without a decoder, you'd need custom logic every time you want to enable a specific memory block. A decoder makes this **scalable and clean**:
- 2-bit select → controls 4 RAM banks
- If we wanted 8 banks, we'd just use a 3-to-8 decoder — same idea, more outputs
- This is exactly how real memory systems (and even microprocessor address decoding) select between different memory chips/regions using part of the address bus

This is a simplified version of **address decoding / memory-mapped I/O**, a real concept used in computer architecture when a CPU has one address bus but must talk to multiple separate memory or peripheral chips.

---

## ⚠️ Known quirks / things I noticed

- `data_out` is registered (updates one clock cycle *after* `rd_en` is asserted), so there's a 1-cycle read latency — normal for synchronous RAM, but easy to trip over if you expect combinational reads.
- If neither `wr_en` nor `rd_en` is active, `data_out` resets to `0` every clock cycle (it doesn't "hold" the last value) — worth remembering when debugging waveforms.
- Only one bank is selected at a time (one-hot `cs`), so there's no risk of writing/reading two banks simultaneously — but also no way to access more than one location across banks in a single cycle.

---

## 📚 What I learned from this project

- How a decoder converts a binary select code into one-hot enable signals
- How chip-select (`cs`) is used to activate only one memory block at a time
- How multiple RAM instances can be connected in parallel and multiplexed at the output
- The basics of writing a self-checking-style testbench with `task`s for reusable write/read sequences
- Why real systems use address decoding to manage multiple memory chips with a shared bus

---

## 🗂️ Repo structure

```
.
├── Decoder_based_RAM.sv      # design (decoder + ram_8x8 + top module)
├── Decoder_based_RAM_tb.sv   # testbench
└── README.md
```

## 🤝 Contributing

This is a learning project, but suggestions/issues are welcome — feel free to open a PR if you spot a bug or want to extend it (e.g. more banks, a larger address space, or a byte-enable feature).
