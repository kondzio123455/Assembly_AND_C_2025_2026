; ============================================================
; Project:     68000 to x86_64 Assembly Conversion
; Author:      Konrad | C00309030 | SETU Carlow
; Description: 3-iteration loop keeping a running sum.
;              Uses scanf for input and printf for output.
; ============================================================

section .data
    prompt_msg      db  "Enter number: ", 0
    result_msg      db  "The sum is: ", 0
    final_msg       db  "Final sum is: ", 0
    err_invalid     db  "Error: Number too large. Try again.", 10, 0
    
    fmt_out         db  "%ld", 10, 0    ; Format for printf
    fmt_in          db  "%ld", 0        ; Format for scanf
    
    INT32_MAX       equ 2147483647

section .bss
    user_input      resq 1              ; 64-bit variable to store scanf input

section .text
    global main
    extern printf, scanf
    extern register_adder               ; Link to our math subroutine

; --- Subroutine to safely get a number ---
get_input:
    push    rbp
    mov     rbp, rsp

.retry:
    ; 1. Print prompt
    lea     rdi, [rel prompt_msg]
    xor     eax, eax
    call    printf

    ; 2. Read number with scanf
    lea     rdi, [rel fmt_in]           
    lea     rsi, [rel user_input]       
    xor     eax, eax
    call    scanf

    ; 3. Move number to rax to return it
    mov     rax, [rel user_input]       

    ; 4. Check if the initial input is already too big
    cmp     rax, INT32_MAX      
    jg      .invalid_input
    
    leave
    ret

.invalid_input:
    lea     rdi, [rel err_invalid]
    xor     eax, eax
    call    printf
    jmp     .retry

; --- Main Program ---
main:
    push    rbp
    mov     rbp, rsp
    
    xor     r14, r14            ; r14 (D3 equivalent) = Running Sum = 0
    mov     r15, 3              ; r15 (D4 equivalent) = Loop Counter = 3

.game_loop:
    test    r15, r15
    jz      .display_final

    ; Get D2 and D1
    call    get_input
    mov     r12, rax            ; First number
    call    get_input
    mov     r13, rax            ; Second number

    ; Do the addition
    mov     rdi, r12
    mov     rsi, r13
    call    register_adder      ; Adds parameters, handles overflow
    mov     r12, rax            ; Put result back in r12
    
    ; Add to running sum
    add     r14, r12            

    ; Print iteration sum
    lea     rdi, [rel result_msg]
    xor     eax, eax
    call    printf
    lea     rdi, [rel fmt_out]
    mov     rsi, r12
    xor     eax, eax
    call    printf

    dec     r15                 ; Loop counter --
    jmp     .game_loop

.display_final:
    ; Print final sum
    lea     rdi, [rel final_msg]
    xor     eax, eax
    call    printf
    lea     rdi, [rel fmt_out]
    mov     rsi, r14
    xor     eax, eax
    call    printf

    xor     eax, eax            ; Exit successfully
    leave
    ret