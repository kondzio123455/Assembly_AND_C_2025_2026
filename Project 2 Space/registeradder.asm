
; file: registeradder.asm
; author: konrad skoczylas c00309030
; description: adds two numbers and prevents integer overflow wrap-around.


section .data
    err_overflow    db  "Error: Overflow clamped.", 10, 0       ; text for overflow error
    INT32_MAX       equ 2147483647                              ; max safe 32-bit integer

section .text
    global register_adder                                       ; make function public
    extern printf                                               ; import printf from c library

register_adder:
    push    rbp                                                 ; save base pointer
    mov     rbp, rsp                                            ; set up stack frame

    mov     eax, edi                                            ; load first arg into eax
    add     eax, esi                                            ; add second arg to eax
    jo      .handle_overflow                                    ; jump if addition overflowed
    
    cdqe                                                        ; sign-extend 32-bit to 64-bit
    leave                                                       ; clean up stack frame
    ret                                                         ; return safe result in rax

.handle_overflow:
    lea     rdi, [rel err_overflow]                             ; load overflow error text
    xor     eax, eax                                            ; clear eax for printf
    call    printf                                              ; print the error warning
    
    mov     rax, INT32_MAX                                      ; clamp result to max value
    leave                                                       ; clean up stack frame
    ret                                                         ; return clamped result
