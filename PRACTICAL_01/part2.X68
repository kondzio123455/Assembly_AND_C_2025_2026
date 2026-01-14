*-----------------------------------------------------------
* Title      :Konrad skoczylas
*-----------------------------------------------------------
    ORG    $3000
START:

    ; first instruction of program
    MOVE.L #%00001111, D1

    ; load immediate value into D1
    MOVE.B D1, D2

    ;copy byte from d1 to d2
    MOVE.B D1, $2000
    
    MOVE.B $2000, D3    
    ;load byte from memory location $2000 into d2
    
    MOVE.B $2000, $3000 
    ;copy byte from $2000 to memory location $3000
    
    SIMHALT
 
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
