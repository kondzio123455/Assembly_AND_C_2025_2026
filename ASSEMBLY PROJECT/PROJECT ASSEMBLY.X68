*-----------------------------------------------------------
* Title      :Konrad Skoczylas
* Date       :2/16/26
* Description:a game like jetpack joyride current idea but made alot more simpler 
*-----------------------------------------------------------
    ORG    $1000                  ; first instruction of program
PLAYER_Y    DC.W    100 ;STARTING Y POSTITON                                                ;VARAIBLESSSSSSSS
VELOCITY_Y  DC.W    0   ;VERTICVAL SPEED
GRAVITY     DC.W    1   ;GRAVITY DIRECTION 1 = DOWN -1 = UP
POWER       DC.W    100 ;

TOP_OF_SCREEN   EQU 0                           ;CONSTANTS/FINALS
BOTTOM_OF_SCREEN    EQU 200

START:
GAMELOOP:
    JSR READINPUT
    JSR PHYSICS
    JSR DRAWPLAYER
    BRA GAMELOOP
    
PHYSICS:
    MOVE.W  VELOCITY_Y, D0
    ADD.W   GRAVITY,    D0
    MOVE.W  D0, PLAYER_Y
    
    MOVE.W  PLAYER_Y,   D0
    ADD.W   VELOCITY_Y, D0
    MOVE.W  D0, PLAYER_Y
    
    CMP.W   PLAYER_Y,   #0
    BGE INSIDE_TOP
    MOVE.W  #0, PLAYER_Y

INSIDE_TOP:
    CMP.W   PLAYER_Y,   #200
    BLE INSIDE_BOTTOM
    MOVE.W  #200,   PLAYER_Y
    
INSIDE_BOTTOM:

    RTS
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
