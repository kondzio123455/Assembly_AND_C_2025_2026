*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.L  #%111,  D0        ; Load binary 111 (7 decimal) into D0
    MOVE.L  #$912,  D1        ; Load hexadecimal 912 (2322 decimal) into D1
    MOVE.L  #311,   D2        ; Load decimal 311 into D2

    MOVE.L  D2,     $4200     ; Store D2 (311) as a LONG (4 bytes) at memory $4200
    MOVE.L  D1,     $5000     ; Store D1 (2322) as LONG at memory $5000
    MOVE.L  D0,     $3090     ; Store D0 (7) as LONG at memory $3090

    MOVE.W  #311,   $9000     ; Store 311 as WORD (2 bytes) at $9000
    MOVE.W  #$912,  $1010     ; Store $912 (2322) as WORD at $1010
    MOVE.W  #%111,  $2016     ; Store 7 as WORD at $2016

    MOVE.B  D0,     $1200     ; Store lower byte of D0 (7) at $1200
    MOVE.B  D1,     $9010     ; Store lower byte of D1 (0x912 ? 0x12) at $9010
    MOVE.B  D2,     $2020     ; Store lower byte of D2 (311 ? 0x37) at $2020

    MOVE.L  #%111,  D0        ; Load 7 into D0
    MOVE.L  #$912,  D1        ; Load 2322 into D1
    MOVE.L  #311,   D2        ; Load 311 into D2

    MOVE.W  #311,   $4020     ; Store 311 as WORD at $4020
    MOVE.W  #$912,  $6010     ; Store 2322 as WORD at $6010
    MOVE.W  #%111,  $2005     ; Store 7 as WORD at $2005

    MOVE.B  #42, $1020
    MOVE.L  #280, $1070
    LEA     $1070, A4
    MOVE.L  (A4), $5252

    
    

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

