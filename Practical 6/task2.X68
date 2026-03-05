*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.B      #13, D0             ; MOVE TRAP TASK TO D0
    LEA         ASK_NAME, A1        ; ASK USER FOR THEIR NAME
    TRAP        #15                 ; INTERRUPT AND TRAP TASK
                       
    MOVE.B      #2, D0              ; MOVE TRAP TASK TO D0
    LEA         NAME, A1            ; LOAD NAME TO A1
    TRAP        #15                 ; INTERRUPT AND TRAP TASK

ASK_NAME:       DC.B        'Welcome stranger, please state your name'
                DC.B        $0D, $0A, 0
NAME:           DS.W        30       ; DEFINE STORAGE TO A MAX OF 30
* Put program code here
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
