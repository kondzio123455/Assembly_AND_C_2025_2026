# 68000 to x86_64 Assembly Port & Security Refactor

**Author:** Konrad Skoczylas (C00309030)  
**Module:** Assembly and C Module - Year 2 Stage 2  

## Project Overview
[cite_start]The goal of this project was to take a legacy Motorola 68000 assembly program—which executed a 3-iteration math loop while tracking a running sum—and port it to modern 64-bit x86_64 assembly[cite: 9, 21]. 

However, this wasn't just a simple syntax translation. [cite_start]The original 68000 code contained critical security vulnerabilities regarding how it handled user input and memory[cite: 11, 14]. This refactored version not only replicates the original math logic but strictly enforces modern security practices, input validation, and ABI compliance.

##  Changes & Optimizations
Moving from the 68000 architecture to x86_64 required fundamentally changing how data moves through the program.

* **Register Mapping:** The original code relied heavily on 32-bit Data Registers (`D1` through `D4`). [cite_start]I mapped these directly to x86_64 general-purpose registers (`r12` to `r15`) to keep the data living in the CPU, which is highly optimized and avoids unnecessary reads/writes to RAM[cite: 23].
* **System V AMD64 ABI:** The original 68000 code often passed parameters via the stack or shared data registers. To allow my assembly code to link seamlessly with modern C libraries (like `libc`), I strictly adopted the System V ABI. [cite_start]When my `main` loop calls the `register_adder` subroutine, it passes the numbers securely via the `rdi` and `rsi` registers[cite: 9, 20].

##  Security & Exploit Mitigation (The "Major Issue")
[cite_start]The project brief highlighted the importance of recognizing how improper memory access and unvalidated inputs lead to exploits[cite: 13, 14]. Here is how I addressed the major vulnerabilities found in the original code:

### 1. The "Major Issue": Integer Overflow (Signed Wrapping)
* **The Flaw:** The 68000 codebase used `TRAP #15` (Task 4) to blind-read numerical input directly into a 32-bit register. It had zero bounds checking. If a user entered a number larger than `2,147,483,647` (the maximum limit for a signed 32-bit integer), the binary value would wrap around into the negative bits, causing data corruption and returning massive negative in numbers.
* **The Fix:** I mitigated this by separating the input phase from the math phase. In `registeradder.asm`, I implemented hardware-level arithmetic checking using the x86_64 `jo` (Jump if Overflow) instruction. If the addition of two valid numbers exceeds the 32-bit threshold, the CPU sets the Overflow Flag. [cite_start]My code intercepts this flag, prints a graceful error warning to the user, and clamps the result at `2147483647` to prevent the system from returning a corrupted negative value[cite: 24, 25].

### 2. Input Validation & Buffer Overflows
* [cite_start]**The Flaw:** Allowing users to type freely into a terminal without limiting the memory size is a classic recipe for a stack-based buffer overflow[cite: 12]. 
* **The Fix:** I replaced the raw `TRAP #15` calls with the C standard library's `scanf` function. [cite_start]By utilizing the strict `%ld` formatting token and routing the data directly into a reserved 64-bit (`resq 1`) memory space in the `.bss` section, I ensured the program will strictly only accept valid numeric data, completely neutralizing the risk of arbitrary string execution or stack smashing[cite: 12, 13].

## Testing
[cite_start]To prove the assembly math logic and overflow mitigation work perfectly, I built a C-based test harness (`testmain.c`)[cite: 36]. 
[cite_start]Using the `<assert.h>` library, the test suite injects normal numbers, edge cases (like zero), and massive exploit-level numbers directly into the assembly subroutine to verify that the math is accurate and the overflow clamping triggers exactly when it should[cite: 35, 36].
##  Test Plan
The following test cases were developed to verify the `register_adder` subroutine:

| Test Case | Input A | Input B | Expected Result | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| Basic Addition | 15 | 25 | 40 | Verify standard math logic. |
| Boundary Case | 0 | 100 | 100 | Verify addition with zero. |
| Security/Overflow | 2147483647 | 1 | 2147483647 | Verify the JO flag triggers clamping. |
 **Compile the project:**
   ```bash
   make
