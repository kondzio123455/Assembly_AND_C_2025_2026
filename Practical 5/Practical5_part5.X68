POWER_UPS DC.L 10, 55, 220, 0 ; Terminate Array with a 0

        ORG     $1000

; D0 Used for Trap Codes, and Counting ENEMIES
; D1 Used for Players Health
; D2 Used for Enemy Positions
; D3 used for Enemy Count
; D4 for counting enemies
; D5 loop counter
; D6 power-up position
; D7 temp
; A0 for counting arrays
; A1 for progress messages
; A2 used for PLAYER_X
; A3 used for ENEMY_POSITIONS
; A4 used for POWER_UPS

DAMAGE      EQU     10              ; Damage when collisions occur
POWER_HEAL  EQU     20              ; Health gained from power-up

START:
        LEA     PLAYER_X, A2        ; Player will move along X axis
        LEA     ENEMY_POSITIONS, A3 ; Enemy positions or spawn points
        BRA     GAME_LOOP

GAME_LOOP:
        BSR     COUNT_ENEMIES       ; Size of the ENEMY_POSITIONS Array
        MOVE.B  D0, D4              ; Reset Enemy count at beginning of loop

        LEA     MSG_GAMELOOP, A1    ; Load and Draw Game Loop message
        BSR     DRAW

        BSR     UPDATE              ; Call UPDATE
        BRA     GAME_LOOP            ; Call GAME_LOOP

UPDATE:
        MOVE.B  PLAYER_HEALTH, D1   ; Move Player Health into D1

        LEA     MSG_HEALTH, A1      ; Load and Draw Health Message
        BSR     DRAW

        MOVE.B  D1, D0              ; Display signed number in D1 in decimal in smallest field.
        TRAP    #15

        LEA     CRLF, A1            ; Load and Carriage Return and Line feed
        BSR     DRAW

        CMP     #0, D1              ; Check if Health is 0
        BLE     GAME_OVER           ; Game Over

        ADD.L   #1, PLAYER_X        ; Change x position of Player
        BSR     CHECK_POWERUPS      ; Check for Power Ups
        BSR     COLLISION           ; Check for Collisions with ENEMIES
        RTS

DRAW:
        MOVE.B  (A1)+, D0
        TRAP    #15
        RTS
        
CHECK_POWERUPS:
        LEA     POWER_UPS, A4       ; Load Power Up Array

PU_LOOP:
        MOVE.L  (A4)+, D6           ; Get Power Up position
        BEQ     PU_END              ; End of array

        MOVE.L  PLAYER_X, D7        ; Get Player position
        CMP.L   D6, D7
        BEQ     GIVE_HEALTH         ; If equal give health
        BRA     PU_LOOP

GIVE_HEALTH:
        ADD.B   #POWER_HEAL, PLAYER_HEALTH

        LEA     MSG_POWERUP, A1
        BSR     DRAW

PU_END:
        RTS


COLLISION:
        MOVE.B  #0, D5              ; Loop through Array
        LEA     ENEMY_POSITIONS, A3 ; Load Enemy POSITIONS Array

ITERATE:
        CMP     D5, D4              ; Counter for ENEMY_POSITIONS
        ADDQ.B  #1, D5              ; Subtract one
        BNE     GAME_LOOP           ; If 0 goto GAME_LOOP
        BSR     CHECK_ENEMIES       ; If not Check for Enemy Collisions
        RTS

CHECK_ENEMIES:
        MOVE.L  (A3)+, D2           ; Move ENEMIES position to D2
        MOVE.L  PLAYER_X, D3        ; Move Player position to D3

        CMP.L   D2, D3              ; Compare Player and Enemy position
        BEQ     REDUCE_HEALTH       ; If Equal reduce health
        BNE     ITERATE             ; Iterate to next Enemy

REDUCE_HEALTH:
        LEA     MSG_COLLISION, A1   ; Load and Draw Collision Message
        BSR     DRAW

        SUB.B   #DAMAGE, PLAYER_HEALTH

        LEA     MSG_DAMAGE, A1      ; Load and Draw Damage Message
        BSR     DRAW

        BRA     GAME_LOOP

GAME_OVER:
        LEA     MSG_GAMEOVER, A1
        BSR     DRAW
        SIMHALT

COUNT_ENEMIES:
        MOVE.B  #0, D0              ; Initialize counter to 0
        LEA     ENEMY_POSITIONS, A0 ; Load the address of the array into A0

COUNT_ENEMIES_LOOP:
        TST.L   (A0)+               ; Test the byte at the address in A0 (Check if 0) and increment A0
        BEQ     END_COUNTING        ; If the byte is zero, it's the end of the array
        ADDQ.B  #1, D0              ; Increment the counter
        BRA     COUNT_ENEMIES_LOOP  ; Repeat the loop

END_COUNTING:
        RTS

CRLF            DC.B    13, 10
PLAYER_X        DC.L    1
PLAYER_HEALTH   DC.B    100

MSG_HEALTH      DC.B    'Health: ', 0
MSG_GAMELOOP    DC.B    'Game Loop', 0
MSG_COLLISION   DC.B    'Collision', 0
MSG_GAMEOVER    DC.B    'Game Over', 0
MSG_DAMAGE      DC.B    'Taking Damage', 0
MSG_POWERUP     DC.B    'Power Up! +Health', 0

ENEMY_POSITIONS DC.L    20, 50, 90, 60, 70, 80, 90, 200, 300, 500, 0 ; Terminate array with 0

        END     START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
