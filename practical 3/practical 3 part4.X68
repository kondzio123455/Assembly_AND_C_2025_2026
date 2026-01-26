        ORG     $1000              ; program starts at memory address $1000
START:                             ; entry point


        LEA     PLAYER_HEALTH, A0  ; load address of PLAYER_HEALTH into A0
        MOVE.B  #$64, (A0)         ; store 100% health in memory
        SUB.B   #20, (A0)          ; subtract 20 from player health

        LEA     PLAYER_POINTS, A1  ; load address of PLAYER_POINTS into A1
        MOVE.W  #32, (A1)           ; set player points to 50
        ADD.W   #14, (A1)           ; add 20 points

        LEA     PLAYER_X, A2       ; load address of PLAYER_X into A2
        MOVE.B  #$10, (A2)         ; set player X position to 16

        LEA     PLAYER_Y, A3       ; load address of PLAYER_Y into A3
        MOVE.B  #$08, (A3)         ; set player Y position to 8

        LEA     BOSS_HP, A4        ; load address of BOSS_HP into A4
        MOVE.L  #$00006400, (A4)   ; set boss health to 25600
        SUB.L   #$00001000, (A4)   ; reduce boss health by 4096

        LEA     BOSS_X, A5         ; load address of BOSS_X into A5
        MOVE.W  #$0120, (A5)       ; set boss X position to 288

        LEA     BOSS_Y, A6         ; load address of BOSS_Y into A6
        MOVE.W  #$00F0, (A6)       ; set boss Y position to 240


        MOVE.B  (A2), D0           ; copy PLAYER_X value into D0
        MOVE.B  D0, (A3)           ; store D0 value into PLAYER_Y

        SIMHALT                    ; stop simulator execution


PLAYER_HEALTH   dc.b    $00        ; 1 byte for player health
PLAYER_POINTS   dc.w    $0000      ; 2 bytes for player points
PLAYER_X        dc.b    $00        ; 1 byte for player X position
PLAYER_Y        dc.b    $00        ; 1 byte for player Y position

BOSS_HP         dc.l    $00000000  ; 4 bytes for boss health
BOSS_X          dc.w    $0000      ; 2 bytes for boss X position
BOSS_Y          dc.w    $0000      ; 2 bytes for boss Y position

        END     START              ; end of program

        MOVE.B  (A2), D0
        MOVE.B  D0, (A3)

        SIMHALT          

PLAYER_HEALTH   dc.b    $00
PLAYER_POINTS   dc.w    $0000
PLAYER_X        dc.b    $00
PLAYER_Y        dc.b    $00

BOSS_HP         dc.l    $00000000
BOSS_X          dc.w    $0000
BOSS_Y          dc.w    $0000

        END     START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
