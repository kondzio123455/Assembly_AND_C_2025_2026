*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    MOVE.L  #%100,  D0        ; Load binary 100 (4 decimal) into register D0
    MOVE.L  #$100,  D1        ; Load hexadecimal 100 (256 decimal) into register D1
    MOVE.L  #100,   D2        ; Load decimal 100 into register D2

    MOVE.L  D0, $3000         ; Store the value of D0 (4) as a LONG (4 bytes) at memory address $3000
    MOVE.L  D1, $3010         ; Store the value of D1 (256) as a LONG at memory address $3010
    MOVE.L  D2, $3020         ; Store the value of D2 (100) as a LONG at memory address $3020
    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
