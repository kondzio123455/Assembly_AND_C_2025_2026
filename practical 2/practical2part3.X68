*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.L  #%100,  D0        ; Load binary 100 (4 decimal) into D0
    MOVE.L  #$100,  D1        ; Load hexadecimal 100 (256 decimal) into D1
    MOVE.L  #100,   D2        ; Load decimal 100 into D2

    MOVE.L  D0,     $3000     ; Store D0 (4) as LONG (4 bytes) at memory $3000
    MOVE.L  D1,     $3010     ; Store D1 (256) as LONG at memory $3010
    MOVE.L  D2,     $3020     ; Store D2 (100) as LONG at memory $3020

    MOVE.W  #100,   $3020     ; Store 100 as WORD (2 bytes) at $3020 (overwrites lower 2 bytes)
    MOVE.W  #$100,  $3010     ; Store 256 as WORD at $3010 (overwrites lower 2 bytes)
    MOVE.W  #%100,  $3000     ; Store 4 as WORD at $3000 (overwrites lower 2 bytes)

    MOVE.B  #100,    $3020    ; Store 100 as BYTE (1 byte) at $3020 (overwrites lowest byte)
    MOVE.B  #$64,   $3010     ; Store 0x64 (100 decimal) as BYTE at $3010 (overwrites lowest byte)
    MOVE.B  #%10001111, $3000 ; Store binary 10001111 (143 decimal) as BYTE at $3000
   ;the memory is only read in bytes 
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
