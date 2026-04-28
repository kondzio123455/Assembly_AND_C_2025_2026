
; file: main.asm
; author: konrad skoczylas c00309030
; description: 3-iteration loop with running sum. uses scanf and printf.


section .data
    prompt_msg      db  "Enter number: ", 0                     ; text to ask for input
    result_msg      db  "The sum is: ", 0                       ; text for current loop sum
    final_msg       db  "Final sum is: ", 0                     ; text for the final total
    err_invalid     db  "Error: Number too large.", 10, 0       ; text for input error
    
    fmt_out         db  "%ld", 10, 0                            ; printf format for numbers
    fmt_in          db  "%ld", 0                                ; scanf format for numbers
    
    INT32_MAX       equ 2147483647                              ; max safe 32-bit integer

section .bss
    user_input      resq 1                                      ; 64-bit space for scanf input

section .text
    global main                                                 ; make main visible to linker
    extern printf, scanf                                        ; import c library functions
    extern register_adder                                       ; link our math subroutine

get_input:
    push    rbp                                                 ; save base pointer
    mov     rbp, rsp                                            ; set up stack frame

.retry:
    lea     rdi, [rel prompt_msg]                               ; load prompt text address
    xor     eax, eax                                            ; clear eax for printf
    call    printf                                              ; print the prompt

    lea     rdi, [rel fmt_in]                                   ; load format string for scanf
    lea     rsi, [rel user_input]                               ; load address to save number
    xor     eax, eax                                            ; clear eax for scanf
    call    scanf                                               ; read input from keyboard

    mov     rax, [rel user_input]                               ; move input into rax to return

    cmp     rax, INT32_MAX                                      ; check if number is too big
    jg      .invalid_input                                      ; if greater, jump to error
    
    leave                                                       ; clean up stack frame
    ret                                                         ; return to main loop

.invalid_input:
    lea     rdi, [rel err_invalid]                              ; load error message address
    xor     eax, eax                                            ; clear eax for printf
    call    printf                                              ; print the error message
    jmp     .retry                                              ; loop back to ask again

main:
    push    rbp                                                 ; save base pointer
    mov     rbp, rsp                                            ; set up stack frame
    
    xor     r14, r14                                            ; r14 (d3) = running sum = 0
    mov     r15, 3                                              ; r15 (d4) = loop counter = 3

.game_loop:
    test    r15, r15                                            ; check if counter is zero
    jz      .display_final                                      ; if zero, exit the loop

    call    get_input                                           ; read the first number
    mov     r12, rax                                            ; save it in r12 (d2)
    
    call    get_input                                           ; read the second number
    mov     r13, rax                                            ; save it in r13 (d1)

    mov     rdi, r12                                            ; pass first number to rdi
    mov     rsi, r13                                            ; pass second number to rsi
    call    register_adder                                      ; safely add them together
    mov     r12, rax                                            ; put the result back in r12
    
    add     r14, r12                                            ; add result to running sum

    lea     rdi, [rel result_msg]                               ; load text for sum
    xor     eax, eax                                            ; clear eax for printf
    call    printf                                              ; print the text
    
    lea     rdi, [rel fmt_out]                                  ; load format string to print
    mov     rsi, r12                                            ; pass the current loop sum
    xor     eax, eax                                            ; clear eax for printf
    call    printf                                              ; print the number

    dec     r15                                                 ; subtract 1 from loop counter
    jmp     .game_loop                                          ; jump back to start of loop

.display_final:
    lea     rdi, [rel final_msg]                                ; load text for final total
    xor     eax, eax                                            ; clear eax for printf
    call    printf                                              ; print the text
    
    lea     rdi, [rel fmt_out]                                  ; load format string to print
    mov     rsi, r14                                            ; pass the grand total
    xor     eax, eax                                            ; clear eax for printf
    call    printf                                              ; print the final number

    xor     eax, eax                                            ; set return code to 0
    leave                                                       ; clean up stack frame
    ret  
