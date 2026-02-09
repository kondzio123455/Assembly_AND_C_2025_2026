       ORG    $1000              ; Program starts at memory address $1000

START:                            ; First instruction of program

        LEA HEALTH, A1            ; Load address of player HEALTH into A1
        MOVE.B  #$64, (A1)        ; Set player health to 100% ($64 hex)
        SUB.B   #20, (A1)         ; Reduce player health by 20 (taking damage)

        LEA ENEMIES_HEALTH, A3    ; Load address of enemy health into A3
        MOVE.L  #$120, (A3)       ; Set enemy health value

        BRA OPENING_MYSTERY_BOX   ; Branch to mystery box event
        BSR MSG_AWARDS            ; Branch to subroutine (unused here, shown as example)

OPENING_MYSTERY_BOX:

        LEA BOX_RANDOM, A2        ; Load address of random box value
        ADD.B   #1, (A2)          ; Increment box value (simulated randomness)
        ADD.B   #10, (A1)         ; Increase player health by 10

MSG_AWARDS:

        LEA MSG_AWARD, A0         ; Load address of award message
        MOVE.B  #12, D0           ; Function code for printing string
        TRAP    #15               ; System call to display message

FIGHTING_BOSS:

        MOVE.B  (A1), D1          ; Load player health into data register D1
        MOVE.L  (A3), D2          ; Load enemy health into data register D2

        SUB.B   #15, D2           ; Player attacks boss (reduce enemy health)
        MOVE.L  D2, (A3)          ; Store updated enemy health

        SUB.B   #10, D1           ; Boss attacks player (reduce player health)
        MOVE.B  D1, (A1)          ; Store updated player health

        AND.B   #$01, (A2)        ; Logical AND operation on box value
        OR.B    #$00, (A2)        ; Logical OR operation (demonstrates logic use)

        BRA     FIGHTING_BOSS     ; Loop back to continue boss fight

        SIMHALT                   ; Stop the simulator

HEALTH              dc.l    $64    ; Player health value
BOX_RANDOM          dc.b    $0     ; Mystery box random value
MSG_AWARD           dc.b 'YOU HAVE RECEIVED +10 HEALTH'
TAKING_DAMAGE       dc.w    $0     ; Placeholder damage variable
ENEMIES_HEALTH      dc.l    $0     ; Enemy health value

        END    START              ; End of program

