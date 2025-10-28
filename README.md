# Application-Specific-Embedded-Processor-using-System-Verilog
Implemented a picoMIPS implementation for 1-dimensional Gaussian Smoothing utilising a small number of the FPGA resources, minimising design cost.

## Architecture of the design 
This processor implements a custom 14-bit instruction set to perform 1-dimensional Gaussian smoothing. It features a control path and a data path for a processor design rather than a dedicated hardware implementation.

### 1. Control Path: 
The control path begins at the Program Memory, which stores the 14 bit instructions in binary encoding. The Program Counter fetches the instruction, which 
is decoded by the Decoder, and generates the following control signals : 

The PC increment or branch is determined by two decoder signals: 
* **PCincr:** enables next instruction execution (PC = PC + 1), and 
* **PCrelbranch:** triggers relative branching. 

Since the instruction set includes relative conditional branching via BNE, the immediate field was chosen to be 5 bits wide, allowing signed values from -16 to +15. This supports a relative jump of -10 in binary (10110 in two's complement). 

Similarly, the following control signals affect the function of the Register file: 

* **w:** This control signal enables the write-back functionality of the register file. 
* **Imm:** Controls the multiplexer before the ALU input b to select either source register (Rdata2) or the 5-bit Immediate explicitly part of instruction. However, when performing arithmetic calculations the Sign-bit of the immediate is extended to pad the missing 3 bits. 
* **g_in** and **w_in**: These control signals determine the data that is to be written into the destination register. It selects between the ALU result, the Wave ROM (w_rom.sv) or the Gaussian Kernel ROM (g_rom).  

The multiplexers controlled by the Imm and the concatenated **{w_in, g_in}** for the ALU operand b and the writeback respectively.

Control signals relating to the ALU are as follows: 
* **ALUfunc:** The decoder extracts the 3-bit opcode and uses bits [1:0] as ALUfunc to select operations from the alucodes file, including subtraction—used implicitly during branch evaluation (e.g., BNE), despite not being part of the instruction set. 
* **flag:** The ALU not only performs the Arithmetic calculations as mentioned above, but also sets and resets the flag for calculation of the Zero flag to be used by the decoder for branching not equal logic.

### 2. Data Path:
The data path comprises of the following modules: 
* **Register File:** The register file consists of a total of 8 registers. The external connections to this application-specific processor including the input index - inport (from SW[7:0]), polling switch - poll (from SW[8]) and the output result – outport (to 
LED[7:0]) are an extended part of this data path: 
    * **%1:** The inport is configured to store data to register 1 when the Load Wave from Kernel instruction is executed. 
    * **%7:** The polling switch input is written into register 7 when the Load from Gaussian Kernel instruction is implemented. 
    * **%6:** Register 6 acts as an accumulator and is connected to the LEDs to display the final result.  

The LEDs output fluctuates initially as the result is being calculated, but stays constant, displaying the final result until the polling switch, user input and next calculation sequence. 
* **Program Memory:** The program memory is capable of 32 instructions and is 14 bits wide. The processor assigns instructions stored in the binary file into the program memory, which is then cycled by the program counter as controlled by the decoder.  
* **ROMs:** The wave and gaussian kernel are read from their respective hex files and stored in the following ROMs that are part of the implemented CPU: 
    * **w_rom:** contains 256 lines of waveform data (from wave.hex) 
    * **g_rom:** contains the 5-point Gaussian kernel [17, 29, 35, 29, 17] 
* **ALU:** Accepts two 8-bit operands and a 2-bit function code (alufunc). ALU operations include addition and subtraction (used implicitly in branch comparisons). 
* **Multiplier:** A single DSP-based multiplier is used to perform the multiplications needed for convolution. From the 16-bit result, bits [14:7] are extracted to provide an 8-bit scaled output as required by the specification. The multiplier is part of the ALU and shares the same ports.

## Instruction Set
| Mnemonic | Instruction Name | Description | Format |
| :--- | :--- | :--- | :--- |
| NOP | No Operation | No Operation or Stall. | NOP |
| ADD | Addition | Calculates the sum of destination and source and saves it in the destination. | ADD %d, %s |
| ADDI | Addition with Immediate | Calculates the sum of source and value of immediate and saves it in the destination. | ADDI %d, %s, Imm |
| MUL | Multiplication | Calculates the Product of destination and source and saves it in the destination. | MUL %d, %s |
| BNE | Branch if not equal (Relative) | Branch to the address as specified by the immediate if destination and source are not equal. | BNE %d, %s, imm |
| LW | Load Word | Load a value from the source into the destination. | LW %d, %s |
| LWW | Load Word from Wave | Load the respective index in source from the Wave ROM into the destination. | LWW %d, %s |
| LWG | Load Word from Gaussian Kernel | Load the respective index in source from the Gaussian Kernel ROM into the destination. | LWG %d, %s |

## Instruction Format: 
### 14'b AB_CDEF_GHIJ_KLMN

| Bits | Field | Description |
| :--- | :--- | :--- |
| A B C | **Op Code** | The first 3 bits that determine the instruction type. **A** is specifically used for Load instructions. **B C** encode the ALU operations. |
| D E F | **Destination Register** | A 3-bit field specifying one of the **8 registers** in the Register file. |
| G H I | **Source Register** | A 3-bit field specifying one of the **8 registers** in the Register file. |
| J K L M N | **Immediate** | A **5-bit signed** value. Used for Immediate Operations and Relative Branching. The value range is **-16 to +15**. |
