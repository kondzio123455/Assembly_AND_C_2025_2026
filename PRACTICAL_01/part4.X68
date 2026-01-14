*-----------------------------------------------------------
* Title      :Konrad skoczylas
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    LEA text , A1       ;load address of text into A1
    MOVE #4, D0         ;load immediate value (4) into D0
    TRAP #15            ;execute trap (output d0 to console)
    
    MOVE #14, D0        ;load immediate value 14 into d0
    TRAP #15            ;execute trap output d0 to console 
    
    MOVE #3, D0         ;load immediate value 3 into d0
    TRAP #15            ;execute trap output d0 to console

    SIMHALT             ; halt simulator


    text:   dc.b 'Data Register: ', 0
    
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
