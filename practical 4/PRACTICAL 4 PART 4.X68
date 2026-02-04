*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    LEA HEALTH,    A1
    MOVE.B  #$64, (A1)
    SUB.B   #20,  (A1)
    LEA ENEMIES_HEALTH, A3
    MOVE.L  #$120,   (A3)   
    
    BRA OPENING_MYSTERY_BOX
    BSR MSG_AWARDS
    
OPENING_MYSTERY_BOX:   ;player either gets 1 or 0
                       ;1 = getting power up , 0 = losing health      
    LEA BOX_RANDOM, A2
    ADD.B   #1, (A2)
    ADD.B   #10, (A1)
    
MSG_AWARDS:
    LEA MSG_AWARD, A0
    MOVE.B  #12,    D0
    TRAP    #15
    
FIGHTING_BOSS:
    
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here
HEALTH              dc.l    $64
BOX_RANDOM          dc.b    $0
MSG_AWARD           dc.b 'YOU HAVE RECEIVED +10 HEALTH'
TAKING_DAMAGE       dc.w    $0
ENEMIES_HEALTH      dc.l    $0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
