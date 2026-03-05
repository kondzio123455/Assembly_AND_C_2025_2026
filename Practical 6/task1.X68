
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVE.B  #2, D0
    TRAP    #15
    
    LEA MESSAGE ,   A1
    MOVE.B  #13,    D0
    TRAP    #15
    
    END_PROG:
    MESSAGE:    DC.B    'TRAP TASK TEST',   0

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
