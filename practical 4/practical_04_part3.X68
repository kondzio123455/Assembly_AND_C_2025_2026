*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.B  #100,   $3000
    LEA $3000,  A1
    
    BSR TAKING_DAMAGE
    
BACK_IN_THE_GAME:
    BSR HEALTH_PICKUP
    BRA GAME_END
    
TAKING_DAMAGE:
    SUB.B   #20,    (A1)
    BRA     BACK_IN_THE_GAME
    
HEALTH_PICKUP:
    ADD.B   #10,    (A1)
    RTS
    
GAME_END:
    MOVE.B  #$00,   (A1)

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
