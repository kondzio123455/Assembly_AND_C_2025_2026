    ORG     $1000       ;START CODE AT MEMORY LOCATION $1000
    
    START:
    MOVE.B  #$64, D1    ;LOAD IMMEDIATE VALUE 100 IN DECIMEL INTO D1
    LEA text,   A1      ;LOAD ADDRESS OF TEXT INTO A1
    MOVE    #14,    D0  ;LOAD IMMEDIATE VALUE 14 INTO D0
    TRAP    #15         ;EXECUTE TRAP OUTPUT D0 TO CONSOLE
    
    MOVE #3, D0         ;LOAD IMMEDIATE VALUE 3 INTO D0
    TRAP #15            ;EXECUTE TRAP OUTPUT D0 TO CONSOLE
    
    SIMHALT
    
text:   dc.b 'Data Register: ', 0
    END START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
