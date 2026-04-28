
 Author     : Konrad Skoczylas (C00309030)
 Description: Original code with the Integer Overflow bug.

    ORG    $1000
START:                  
    CLR.L  D3           * D3 = Running Sum (Initialize to 0)
    MOVE.L #3, D4       * D4 = Loop Counter (Set to 3)

LOOP:
    * Task 4: Read first number into D2
    MOVE.B #4, D0       
    TRAP   #15
    MOVE.L D1, D2       

    * Task 4: Read second number into D1
    MOVE.B #4, D0       
    TRAP   #15

    * The Addition (The Vulnerable Part)
    ADD.L  D2, D1       * Adds numbers. No overflow check!
    
    * Accumulate the total
    ADD.L  D1, D3       

    * Task 3: Display the result of this addition
    MOVE.L D1, D1
    MOVE.B #3, D0
    TRAP   #15

    SUBQ.L #1, D4       * Decrement loop counter
    BNE    LOOP         * If not zero, loop again

    * Task 3: Display final running sum
    MOVE.L D3, D1
    MOVE.B #3, D0
    TRAP   #15

    STOP   #$2700
    END    START
