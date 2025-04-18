# Program that counts consecutive 1’s
.global _start
.text

_start:
    
    li t0, -1
    la t1, LIST
    addi t2, zero, 0             # Keep track of greatest length of string of 1s among all words in LIST
    lw a0, 0(t1)                 # First and only argument of ONES: data/word value. This changes for every iteration of the loop

    LOOP1:
        jal ONES
        ble t2, a0, UPDATE       # If t2 <= a0, then you update t2 to equal a0. Always want t2 to be the longest string of 1st from all words in LIST

    CHECK:
        addi t1, t1, 4
        lw a0, 0(t1)
        beq a0, t0, AFTER 
        j LOOP1

    ONES:
        addi t3, zero, 0         # Initialize to 0 - counter
        addi t4, zero, 0         # Initialize to 0 - stores newly shifted value
        addi t5, zero, 0         # Initialize to 0 - stores (1) previous shifted value, (2) result of AND b/w newly shifted value and previously shifted value
        add t5, t5, a0           # Set temporary register to data/word value for manipulation in LOOP

        LOOP2:
            beqz t5, END2        # Loop until data contains no more 1’s
            srli t4, t5, 1       # Perform SHIFT, followed by AND
            and t5, t5, t4
            addi t3, t3, 1       # Count the string lengths so far
            j LOOP2

        END2:
            add a0, zero, t3     # Return length of longest string
            jr ra
       
    UPDATE: 
        add t2, zero, a0
        j CHECK
        
    AFTER: 
        add s10, zero, t2         # Set s10 to the greatest length of string of 1s among all words in LIST, stored in t2
        add a0, zero, t3          # Set a0 to the return value of the last subroutine call

END: j END

.global LIST
.data
LIST:
.word 0x1fffffff, 0x12345678, -1, 0x7fffffff