*-----------------------------------------------------------
* name     : konrad skoczylas  date: 2/29/26
* description : the quantum quest
*-----------------------------------------------------------
            ORG    $1000               * program starts at memory address $1000
EXIT        EQU    0                   * player enters 0 to quit at the replay screen
BET_LOW     EQU    10                  * low bet option costs 10 plasma
BET_MED     EQU    25                  * medium bet option costs 25 plasma
BET_HIGH    EQU    50                  * high bet option costs 50 plasma

* ---- memory map ----------------------------------------
* $4000 =     current shield level, ranges 0 to 100
* $4002 = PLASMA     current plasma level, ranges 0 to 100
* $4004 = DARK MATTER  current dark matter level, ranges 0 to 100
* $4006 = DAY        tracks how many days the player has survived
* $4008 = SEED       holds the last value produced by the rng for the next call
* $400A = BET        temporarily holds the current bet amount during the gamble routine
* $400C = WINS       running total of gamble wins
* $400E = LOSSES     running total of gamble losses
*-----------------------------------------------------------
* INIT - set starting values for all resources and counters
*-----------------------------------------------------------
START:
            MOVE.W  #100,$4000          * shields begin full at 100
            MOVE.W  #60,$4002           * plasma starts at 60
            MOVE.W  #60,$4004           * dark matter starts at 60
            MOVE.W  #1,$4006            * day counter starts at 1
            MOVE.W  #29,$4008           * initial seed value for the random number generator
            MOVE.W  #0,$400A            * bet amount cleared to zero
            MOVE.W  #0,$400C            * win counter starts at zero
            MOVE.W  #0,$400E            * loss counter starts at zero
            BSR     CLEAR_SCREEN        * clear the screen before showing the title
            BSR     WELCOME             * show the title and wait for input
            BSR     GAMELOOP            * enter the main game loop

*-------------------------------------------------------
* ORG - remaining program code placed from $3000 onwards
*-------------------------------------------------------
            ORG     $3000

END:
            SIMHALT                     * end of program

*-----------------------------------------------------------
* WELCOME - displays the title screen and waits for a keypress
*-----------------------------------------------------------
WELCOME:
            LEA     WELCOME_ART,A1      * load address of the title banner
            MOVE.B  #14,D0
            TRAP    #15                 * print the title banner
            LEA     SCIENTIST_ART,A1    * load address of the scientist portrait
            MOVE.B  #14,D0
            TRAP    #15                 * print the portrait
            BSR     CONTINUE            * wait for the player to press a key
            RTS

*-----------------------------------------------------------
* GAMELOOP - main game loop, runs once per turn
* order: show hud, get input, run action,
*        pause, random event, pause, check for death, replay prompt
*-----------------------------------------------------------
GAMELOOP:
            BSR     CLEAR_SCREEN        * clear screen at the start of each turn
            BSR     HUD                 * display current resource values
            BSR     INPUT               * show the action menu and read the player choice
            BSR     CLEAR_SCREEN        * clear before showing the action result
            BSR     UPDATE              * run whichever action the player chose
            BSR     CONTINUE            * pause so the player can read the result
            BSR     CLEAR_SCREEN        * clear before the random event
            BSR     GAMEPLAY            * roll a random event and apply daily decay
            BSR     CONTINUE            * pause so the player can read the event
            BSR     CLEAR_SCREEN        * clear before showing the updated hud
            BSR     HUD                 * show updated resource values after all changes
            BSR     CHECKDEAD           * check if any resource has reached zero
            BSR     REPLAY              * ask the player to continue or quit
            RTS                         * not reached, replay branches back to gameloop

*-----------------------------------------------------------
* INPUT - displays the action menu and reads a valid choice
* loops until the player enters 1, 2, or 3
* stores the result in MCHOICE for UPDATE to read
*-----------------------------------------------------------
INPUT:
            LEA     MENU_MSG,A1         * print the action menu
            MOVE.B  #14,D0
            TRAP    #15
INLOOP:     LEA     PROMPT_MSG,A1       * print the input prompt
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #4,D0              * trap 4 reads an integer from the keyboard into D1
            TRAP    #15
            CMP     #1,D1               * check if input is below the valid range
            BLT     BADINP              * if so, reject it
            CMP     #3,D1               * check if input is above the valid range
            BGT     BADINP              * if so, reject it
            MOVE.W  D1,MCHOICE          * input is valid, save it to memory
            RTS
BADINP:     LEA     BADINPUT_MSG,A1     * print an error message
            MOVE.B  #14,D0
            TRAP    #15
            BRA     INLOOP              * ask again

*-----------------------------------------------------------
* UPDATE - reads MCHOICE and branches to the chosen action
*-----------------------------------------------------------
UPDATE:
            MOVE.W  MCHOICE,D0          * load the stored player choice
            CMP     #1,D0
            BEQ     EXP1                * 1 goes to the collider run
            CMP     #2,D0
            BEQ     EXP3                * 2 goes to the dark matter raid
            BRA     GAMBLE              * 3 goes to the gamble routine

*-----------------------------------------------------------
* EXP1 - COLLIDER RUN
* gains: +20 plasma, +15 dark matter
* risk: 50% chance of taking 25 shield damage
*-----------------------------------------------------------
EXP1:       LEA     ART1,A1             * print the collider art
            MOVE.B  #14,D0
            TRAP    #15
            LEA     M1_RES,A1           * print the result message
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4002,D0            * load current plasma
            ADD.W   #20,D0              * add the plasma reward
            BSR     CAP                 * clamp to 100 max
            MOVE.W  D0,$4002            * save updated plasma
            MOVE.W  $4004,D0            * load current dark matter
            ADD.W   #15,D0              * add the dark matter reward
            BSR     CAP                 * clamp to 100 max
            MOVE.W  D0,$4004            * save updated dark matter
            BSR     COLLISION           * roll for possible shield damage
            RTS

*-----------------------------------------------------------
* EXP3 - DARK MATTER RAID
* gains: +30 dark matter, +20 plasma
* risk: 50% chance of taking 25 shield damage
*-----------------------------------------------------------
EXP3:       LEA     ART3,A1             * print the void raid art
            MOVE.B  #14,D0
            TRAP    #15
            LEA     M3_RES,A1           * print the result message
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4004,D0            * load current dark matter
            ADD.W   #30,D0              * add the dark matter reward
            BSR     CAP                 * clamp to 100 max
            MOVE.W  D0,$4004            * save updated dark matter
            MOVE.W  $4002,D0            * load current plasma
            ADD.W   #20,D0              * add the plasma reward
            BSR     CAP                 * clamp to 100 max
            MOVE.W  D0,$4002            * save updated plasma
            BSR     COLLISION           * roll for possible shield damage
            RTS

*-----------------------------------------------------------
* GAMBLE - betting mini-game using plasma as currency
* player selects a bet size: 10, 25, or 50 plasma
* a random roll determines win or loss
* win returns double the bet, loss forfeits the bet
* results are tracked in the win and loss counters
*-----------------------------------------------------------
GAMBLE:     BSR     CLEAR_SCREEN        * clear screen for the gamble menu
            LEA     ART5,A1             * print the gamble art
            MOVE.B  #14,D0
            TRAP    #15
            LEA     BET_MSG,A1          * print the bet options
            MOVE.B  #14,D0
            TRAP    #15
BETLOOP:    LEA     BETPROMPT,A1        * print the bet input prompt
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #4,D0              * read the bet choice into D1
            TRAP    #15
            CMP     #1,D1               * check for low bet
            BEQ     BETLO
            CMP     #2,D1               * check for medium bet
            BEQ     BETMD
            CMP     #3,D1               * check for high bet
            BEQ     BETHI
            LEA     BADINPUT_MSG,A1     * input was not 1, 2, or 3
            MOVE.B  #14,D0
            TRAP    #15
            BRA     BETLOOP             * ask again

* --- low bet: 10 plasma ---
BETLO:      MOVE.W  $4002,D0            * load current plasma
            CMP     #10,D0              * check if the player has at least 10
            BGE     BLO_OK              * enough plasma, proceed
            BSR     NOBETS              * not enough, print message
            BRA     BETLOOP             * return to bet selection
BLO_OK:     MOVE.W  #10,$400A           * store bet amount as 10
            BRA     BETPLACE

* --- medium bet: 25 plasma ---
BETMD:      MOVE.W  $4002,D0            * load current plasma
            CMP     #25,D0              * check if the player has at least 25
            BGE     BMD_OK
            BSR     NOBETS
            BRA     BETLOOP
BMD_OK:     MOVE.W  #25,$400A           * store bet amount as 25
            BRA     BETPLACE

* --- high bet: 50 plasma ---
BETHI:      MOVE.W  $4002,D0            * load current plasma
            CMP     #50,D0              * check if the player has at least 50
            BGE     BHI_OK
            BSR     NOBETS
            BRA     BETLOOP
BHI_OK:     MOVE.W  #50,$400A           * store bet amount as 50

* --- deduct the bet and resolve the outcome ---
BETPLACE:   MOVE.W  $4002,D0            * load current plasma
            SUB.W   $400A,D0            * subtract the bet amount
            MOVE.W  D0,$4002            * save the reduced plasma value
            BSR     CLEAR_SCREEN        * clear screen for the result
            LEA     BETPLACE_MSG,A1     * print the bet confirmation message
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $400A,D1            * load bet amount into D1 for printing
            MOVE.B  #3,D0              * trap 3 prints an integer
            TRAP    #15
            BSR     RANDOM              * generate a random number 0 to 255
            CMP.W   #128,D0             * 128 or above is a win, below is a loss
            BGE     BWIN

* --- loss path ---
            MOVE.W  $400E,D0            * load loss counter
            ADD.W   #1,D0              * increment by one
            MOVE.W  D0,$400E            * save updated loss counter
            LEA     LOST_MSG,A1         * print the loss message
            MOVE.B  #14,D0
            TRAP    #15
            RTS

* --- win path ---
BWIN:       MOVE.W  $400A,D0            * load the original bet amount
            MULU    #2,D0              * multiply by 2 to get the payout
            MOVE.W  $4002,D1            * load current plasma into D1
            ADD.W   D0,D1              * add the winnings to current plasma
            BSR     CAP                 * clamp plasma to 100 max
            MOVE.W  D1,$4002            * save updated plasma
            MOVE.W  $400C,D0            * load win counter
            ADD.W   #1,D0              * increment by one
            MOVE.W  D0,$400C            * save updated win counter
            LEA     WIN_MSG,A1          * print the win message
            MOVE.B  #14,D0
            TRAP    #15
            RTS

* --- not enough plasma to place the chosen bet ---
NOBETS:     LEA     NOBETS_MSG,A1       * print the insufficient plasma message
            MOVE.B  #14,D0
            TRAP    #15
            RTS

*-----------------------------------------------------------
* GAMEPLAY - rolls a random event each turn and applies daily resource decay
* picks one of three events based on a random number mod 3
* decay and day increment happen at the end regardless of which event fired
*-----------------------------------------------------------
GAMEPLAY:   LEA     EV_HEADER,A1        * print the event section header
            MOVE.B  #14,D0
            TRAP    #15
            BSR     RANDOM              * generate a random number 0 to 255
            DIVU    #3,D0              * divide by 3, we need the remainder to select the event
            SWAP    D0                  * after swap the remainder is in the lower word
            AND.W   #$000F,D0           * mask to lower nibble to isolate the remainder cleanly
            CMP     #0,D0
            BEQ     EV0                 * remainder 0 = void rift
            CMP     #1,D0
            BEQ     EV1                 * remainder 1 = particle surge
            BRA     EV2                 * remainder 2 = radiation burst

* --- event 0: void rift, dark matter is reduced ---
EV0:        LEA     EV0_MSG,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4004,D0            * load dark matter
            SUB.W   #20,D0              * reduce by 20
            BSR     CAP                 * clamp so it does not go below 0
            MOVE.W  D0,$4004            * save updated dark matter
            BRA     DECAY

* --- event 1: particle surge, both plasma and dark matter increase ---
EV1:        LEA     EV1_MSG,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4002,D0            * load plasma
            ADD.W   #20,D0              * add 20 plasma
            BSR     CAP
            MOVE.W  D0,$4002            * save updated plasma
            MOVE.W  $4004,D0            * load dark matter
            ADD.W   #20,D0              * add 20 dark matter
            BSR     CAP
            MOVE.W  D0,$4004            * save updated dark matter
            BRA     DECAY

* --- event 2: radiation burst, shields are reduced ---
EV2:        LEA     EV2_MSG,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4000,D0            * load shields
            SUB.W   #25,D0              * reduce by 25
            BSR     CAP
            MOVE.W  D0,$4000            * save updated shields

* --- daily decay applied after every event ---
DECAY:      LEA     DECAY_MSG,A1        * print the end of day message
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4002,D0            * load plasma
            SUB.W   #8,D0              * subtract daily upkeep cost
            BSR     CAP
            MOVE.W  D0,$4002            * save updated plasma
            MOVE.W  $4004,D0            * load dark matter
            SUB.W   #8,D0              * subtract daily upkeep cost
            BSR     CAP
            MOVE.W  D0,$4004            * save updated dark matter
            MOVE.W  $4006,D0            * load the day counter
            ADD.W   #1,D0              * increment by one
            MOVE.W  D0,$4006            * save updated day counter
            RTS

*-----------------------------------------------------------
* HUD - prints all current resource and counter values
* skips the gamble stats section if the player has not gambled yet
*-----------------------------------------------------------
HUD:        LEA     HUD_MSG,A1          * print the hud header
            MOVE.B  #14,D0
            TRAP    #15
            LEA     DAY_MSG,A1          * print day label
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4006,D1            * load the current day number
            MOVE.B  #3,D0              * trap 3 prints an integer
            TRAP    #15
            LEA     CRLF,A1
            MOVE.B  #14,D0
            TRAP    #15
            LEA     SHD_MSG,A1          * print shields label
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4000,D1            * load shields value
            MOVE.B  #3,D0
            TRAP    #15
            LEA     CRLF,A1
            MOVE.B  #14,D0
            TRAP    #15
            LEA     PLA_MSG,A1          * print plasma label
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4002,D1            * load plasma value
            MOVE.B  #3,D0
            TRAP    #15
            LEA     CRLF,A1
            MOVE.B  #14,D0
            TRAP    #15
            LEA     DM_MSG,A1           * print dark matter label
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4004,D1            * load dark matter value
            MOVE.B  #3,D0
            TRAP    #15
            LEA     CRLF,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $400C,D0            * load wins
            ADD.W   $400E,D0            * add losses to check if any bets have been placed
            CMP     #0,D0               * if total is zero the player has not gambled yet
            BEQ     HUDEND              * skip the gamble stats
            LEA     WIN_HDR,A1          * print wins label
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $400C,D1            * load win count
            MOVE.B  #3,D0
            TRAP    #15
            LEA     CRLF,A1
            MOVE.B  #14,D0
            TRAP    #15
            LEA     LOS_HDR,A1          * print losses label
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $400E,D1            * load loss count
            MOVE.B  #3,D0
            TRAP    #15
            LEA     CRLF,A1
            MOVE.B  #14,D0
            TRAP    #15
HUDEND:     RTS

*-----------------------------------------------------------
* COLLISION - 50/50 shield damage check used by exp1 and exp3
* a random number below 128 means the shockwave connects for 25 damage
* 128 or above means the impact was avoided
*-----------------------------------------------------------
COLLISION:  BSR     RANDOM              * generate a random number 0 to 255
            CMP.W   #128,D0             * check if it falls in the safe range
            BGE     CMISS               * 128 or above, no damage taken
            LEA     HIT_MSG,A1          * print the shockwave hit message
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4000,D0            * load shields
            SUB.W   #25,D0              * apply 25 damage
            BSR     CAP                 * clamp so shields do not go below 0
            MOVE.W  D0,$4000            * save updated shields
            RTS
CMISS:      LEA     MISS_MSG,A1         * print the avoided hit message
            MOVE.B  #14,D0
            TRAP    #15
            RTS

*-----------------------------------------------------------
* CHECKDEAD - checks all three resources for zero
* if any resource is at or below zero the game ends
*-----------------------------------------------------------
CHECKDEAD:  MOVE.W  $4000,D0            * load shields
            CMP     #0,D0
            BLE     GAMEOVER            * shields at zero, game over
            MOVE.W  $4002,D0            * load plasma
            CMP     #0,D0
            BLE     GAMEOVER            * plasma at zero, game over
            MOVE.W  $4004,D0            * load dark matter
            CMP     #0,D0
            BLE     GAMEOVER            * dark matter at zero, game over
            RTS                         * all resources above zero, continue

*-----------------------------------------------------------
* GAMEOVER - displays the end screen and halts the simulation
* shows the scientist portrait, a failure message, and the final day count
*-----------------------------------------------------------
GAMEOVER:   BSR     CLEAR_SCREEN        * clear screen for the game over display
            LEA     SCIENTIST_ART,A1    * print the scientist portrait
            MOVE.B  #14,D0
            TRAP    #15
            LEA     DEAD_MSG,A1         * print the game over banner
            MOVE.B  #14,D0
            TRAP    #15
            LEA     SCORE_MSG,A1        * print the final score label
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.W  $4006,D1            * load the final day count
            MOVE.B  #3,D0              * print it as an integer
            TRAP    #15
            SIMHALT                     * halt the simulation

*-----------------------------------------------------------
* REPLAY - end of turn prompt asking the player to continue or quit
* entering 0 exits to END, anything else restarts the game loop
* uses BRA instead of BSR to avoid growing the call stack each turn
*-----------------------------------------------------------
REPLAY:     LEA     REPLAY_MSG,A1       * print the replay prompt
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #4,D0              * read player input
            TRAP    #15
            CMP     #EXIT,D1            * check if the player entered 0
            BEQ     END                 * if so, jump to END and halt
            BRA     GAMELOOP            * otherwise restart the game loop

*-----------------------------------------------------------
* CAP - clamps the value in D0 to the range 0 to 100
* call this before saving any resource value back to memory
*-----------------------------------------------------------
CAP:        CMP     #100,D0             * check if value exceeds the maximum
            BLE     CAPLO               * within range, check the lower bound
            MOVE.W  #100,D0             * value too high, force it to 100
CAPLO:      CMP     #0,D0               * check if value is below zero
            BGE     CAPOK               * value is fine, return
            MOVE.W  #0,D0              * value too low, force it to 0
CAPOK:      RTS

*-----------------------------------------------------------
* RANDOM - linear congruential generator
* formula: seed = (seed * 75 + 74) AND 255
* returns a value between 0 and 255 in D0
* CLR.L clears the full 32 bit register before loading the seed
* skipping this causes leftover bits in the upper word to corrupt the multiply result
*-----------------------------------------------------------
RANDOM:     CLR.L   D0                  * clear the full 32 bit register, not just the lower word
            MOVE.W  $4008,D0            * load the current seed
            MULU    #75,D0              * multiply by the lcg multiplier
            ADD.W   #74,D0              * add the lcg increment
            AND.W   #$00FF,D0           * mask to 8 bits, keeping the result in range 0 to 255
            MOVE.W  D0,$4008            * save the new seed for next time
            RTS

*-----------------------------------------------------------
* CONTINUE - prints a prompt and blocks until the player presses a key
* placed after every major screen so the player has time to read it
*-----------------------------------------------------------
CONTINUE:
            LEA     CONTINUE_MSG,A1     * load the continue prompt
            MOVE.B  #14,D0
            TRAP    #15
            MOVE.B  #4,D0              * trap 4 blocks here until the player enters something
            TRAP    #15
            RTS

*-----------------------------------------------------------
* ENDL - prints a newline
* saves and restores D0 and A1 so it does not interfere with the caller
*-----------------------------------------------------------
ENDL:
            MOVEM.L D0/A1,-(A7)         * push D0 and A1 onto the stack
            MOVE    #14,D0              * trap 14 prints a string
            LEA     CRLF,A1             * point A1 at the newline bytes
            TRAP    #15
            MOVEM.L (A7)+,D0/A1         * restore D0 and A1 from the stack
            RTS

*-----------------------------------------------------------
* CLEAR_SCREEN - clears the easy68k output window
*-----------------------------------------------------------
CLEAR_SCREEN:
            MOVE.B  #11,D0              * trap 11 is the display control trap
            MOVE.W  #$FF00,D1           * $FF00 is the command code to clear the screen
            TRAP    #15
            RTS

*===========================================================
* data section - all strings and ascii art
*===========================================================
MCHOICE     DS.W    1                   * one word of storage for the player menu choice
CRLF        DC.B    $0D,$0A,0           * carriage return and line feed followed by null terminator

CONTINUE_MSG DC.B   $0D,$0A,'[ press any key, Dr. Quantum is waiting... ]',0

* --- title screen art ---
WELCOME_ART:
            DC.B    $0D,$0A
            DC.B    ' +================================================+',$0D,$0A
            DC.B    ' ||                                              ||',$0D,$0A
            DC.B    ' ||    QUANTUM QUEST: PHYSICS LAB SURVIVAL       ||',$0D,$0A
            DC.B    ' ||    "What could possibly go wrong?"           ||',$0D,$0A
            DC.B    ' ||                                              ||',$0D,$0A
            DC.B    ' ||  >>--[o]--[*]--[CORE]--[*]--[o]-->>         ||',$0D,$0A
            DC.B    ' ||  Manage Plasma, Dark Matter.                 ||',$0D,$0A
            DC.B    ' ||  Run experiments. Try not to explode.        ||',$0D,$0A
            DC.B    ' ||  Option 3: gamble! Ethics board not watching.||',$0D,$0A
            DC.B    ' +================================================+',$0D,$0A
            DC.B    $0D,$0A,0

* --- scientist portrait, shown on title screen and game over screen ---
SCIENTIST_ART:
            DC.B    $0D,$0A
            DC.B    '         _____                                    ',$0D,$0A
            DC.B    '        /     \    DR. QUANTUM                    ',$0D,$0A
            DC.B    '       | o   o |   "I have a PhD for this."       ',$0D,$0A
            DC.B    '       |   ^   |   Speciality: Not dying          ',$0D,$0A
            DC.B    '        \ \_/ /                                   ',$0D,$0A
            DC.B    '      ---|   |---  ___                            ',$0D,$0A
            DC.B    '     /  _|   |_  \|+-+|  <- grant application    ',$0D,$0A
            DC.B    '    /  / |   | \  |+-+|       (mostly denied)    ',$0D,$0A
            DC.B    '          |   |        "If the shield hits 0      ',$0D,$0A
            DC.B    '         /|   |\        thats on YOU."            ',$0D,$0A
            DC.B    $0D,$0A,0

* --- action selection menu ---
MENU_MSG:
            DC.B    $0D,$0A
            DC.B    ' ---- WHAT DOES DR. QUANTUM DO TODAY? ------------',$0D,$0A
            DC.B    ' 1. COLLIDER RUN   +20pla +15dm   (risky)        ',$0D,$0A
            DC.B    ' 2. DM RAID        +30dm  +20pla  (good luck o7) ',$0D,$0A
            DC.B    ' 3. QUANTUM GAMBLE the ethics board wont find out ',$0D,$0A
            DC.B    ' -------------------------------------------------',$0D,$0A
            DC.B    $0D,$0A,0

PROMPT_MSG   DC.B   'Your call, doc (1-3): ',0
BADINPUT_MSG DC.B   'Dr. Quantum stares blankly cuh. Try 1-3.',$0D,$0A,0

* --- collider run art ---
ART1:
            DC.B    $0D,$0A
            DC.B    ' +==========================================+',$0D,$0A
            DC.B    ' |   o       o       o       o       o     |',$0D,$0A
            DC.B    ' | >>--[o]--[o]-->>[CORE]<<--[o]--[o]--<< |',$0D,$0A
            DC.B    ' |       PARTICLE   COLLIDER   RUN         |',$0D,$0A
            DC.B    ' | <<--[o]--[o]-->>[CORE]<<--[o]--[o]-->> |',$0D,$0A
            DC.B    ' |   o       o       o       o       o     |',$0D,$0A
            DC.B    ' +==========================================+',$0D,$0A
            DC.B    $0D,$0A,0

* --- dark matter raid art ---
ART3:
            DC.B    $0D,$0A
            DC.B    ' *  .  *  .  *  .  *  .  *  .  *  .  *',$0D,$0A
            DC.B    ' .    ((  D A R K   V O I D   R A I D  ))',$0D,$0A
            DC.B    ' *   . /==============================\ . *',$0D,$0A
            DC.B    ' .    | #  #  #  #  #  #  #  #  #  # |   .',$0D,$0A
            DC.B    ' *   . \==============================/ . *',$0D,$0A
            DC.B    ' .  *  .  *  .  *  .  *  .  *  .  *  .',$0D,$0A
            DC.B    $0D,$0A,0

* --- gamble art ---
ART5:
            DC.B    $0D,$0A
            DC.B    '      ___________________________________        ',$0D,$0A
            DC.B    '     /                                   |  <>  <>',$0D,$0A
            DC.B    '    |   \O/  -  -  -  -  -  -  -  - ->X |<><><><>',$0D,$0A
            DC.B    '    |    |>      still digging!!!        X| <><><>',$0D,$0A
            DC.B    '    |   / \  -  -  -  -  -  -  -  - ->X |<><><><>',$0D,$0A
            DC.B    '     \___________________________________|  <>  <>',$0D,$0A
            DC.B    '      ___________________________________ DIAMONDS',$0D,$0A
            DC.B    '     /                                   |<><><><>',$0D,$0A
            DC.B    '    |  <- <- <- <- <- <-   o/            | <><><>',$0D,$0A
            DC.B    '    |    walked away :(     |>            |<><><><>',$0D,$0A
            DC.B    '    |  <- <- <- <- <- <-   / \            | <><><>',$0D,$0A
            DC.B    '     \_____________________________________|<><><>',$0D,$0A
            DC.B    '   99% of gamblers quit before the Max winnn....    ',$0D,$0A
            DC.B    $0D,$0A,0

* --- gamble menu and result strings ---
BET_MSG:
            DC.B    ' ---- TOTALLY LEGITIMATE SCIENCE TRIP FUNDING ---------',$0D,$0A
            DC.B    ' 1. LOW BET    10 plasma  (respectable)           ',$0D,$0A
            DC.B    ' 2. MEDIUM BET 25 plasma  (bold move)             ',$0D,$0A
            DC.B    ' 3. HIGH BET   50 plasma  (insurance not covered) ',$0D,$0A
            DC.B    ' -------------------------------------------------',$0D,$0A
            DC.B    $0D,$0A,0

BETPROMPT    DC.B   'Place your "scientific" bet (1-3): ',0
BETPLACE_MSG DC.B   'Dr. Q slides the plasma across the table: ',0
NOBETS_MSG   DC.B   'Not enough plasma! start a onlyfans',$0D,$0A,0
WIN_MSG      DC.B   $0D,$0A,'** WINNER! Dr. Q respects the gamble **',$0D,$0A,0
LOST_MSG     DC.B   $0D,$0A,'** LOST. Dr. Q side eyes . **',$0D,$0A,0

* --- experiment result messages ---
M1_RES      DC.B   'Collider fired! Particles are GOING FOR IT.',$0D,$0A,0
M3_RES      DC.B   'Dark matter extracted. Smells like burnt toast.',$0D,$0A,0

* --- collision result messages ---
HIT_MSG     DC.B   $0D,$0A,'** SHOCKWAVE! Dr. Q was NOT ready. -25 shields **',$0D,$0A,0
MISS_MSG    DC.B   '** Contained! Dr. Q: "I meant to do that." **',$0D,$0A,0

* --- random event messages ---
EV_HEADER   DC.B   $0D,$0A,'=== SOMETHING IS HAPPENING ===',$0D,$0A,0
EV0_MSG     DC.B   '** Void rift! Dark matter just LEFT.   -20 dm **',$0D,$0A,0
EV1_MSG     DC.B   '** Particle surge! Lab is humming. +20pla +20dm **',$0D,$0A,0
EV2_MSG     DC.B   '** Radiation burst! Dr. Q dives for cover. -25shd **',$0D,$0A,0
DECAY_MSG   DC.B   'End of day: resources used. Dr. Q skips dinner.',$0D,$0A,0

* --- hud label strings ---
HUD_MSG     DC.B   $0D,$0A,'=== DR. QUANTUM CHECK-IN ===',$0D,$0A,0
DAY_MSG     DC.B   'EXPERIMENT DAY  : ',0
SHD_MSG     DC.B   'SHIELDS         : ',0
PLA_MSG     DC.B   'PLASMA          : ',0
DM_MSG      DC.B   'DARK MATTER     : ',0
WIN_HDR     DC.B   'CASINO WINS     : ',0
LOS_HDR     DC.B   'CASINO LOSSES   : ',0

* --- game over screen ---
DEAD_MSG:
            DC.B    $0D,$0A
            DC.B    ' +=============================================+',$0D,$0A
            DC.B    ' || LAB DESTROYED. Dr. Q is fine. Probably.  ||',$0D,$0A
            DC.B    ' || Ethics board is NOT fine with this.       ||',$0D,$0A
            DC.B    ' +=============================================+',$0D,$0A
            DC.B    $0D,$0A,0

SCORE_MSG   DC.B   'Days survived before catastrophe: ',0
REPLAY_MSG  DC.B   $0D,$0A,'0 = quit and reflect. Anything else = retry: ',0

            END    START               * entry point is START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
