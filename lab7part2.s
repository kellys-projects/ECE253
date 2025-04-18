.global _start
.text

_start:
li sp, 0x20000              # initialize sp
la t0, LIST
add a1, zero, t0
lw t1, 0(a1)                # let this be n
addi t2, zero, 0            # let this be index i
addi t3, zero, 0            # let this be index j
sub t4, t1, t2              # let this be n - i, need to do this several times
addi t4, t4, -1             # let this be n - i - 1, need to do this several times
addi a1, a1, 4              # move to the element after the first element, this (a1) is my argument to SWAP


LOOP1:
    
    LOOP2:
        beq t3, t4, AFTER   # check if j = n - i - 1, if it is then you end the loop
        jal SWAP
        addi t3, t3, 1      # update index j, j++
        addi a1, a1, 4
        j LOOP2
    
    AFTER:
        addi t2, t2, 1      # update index i, i++ 
        beq t2, t1, END     # check if i = n, if it is then you end the loop
        add a1, zero, t0    # reset a0 to the first element of list
        addi a1, a1, 4      # reset a0 to the second element of list
        addi t3, zero, 0    # reset index j to 0
        sub t4, t1, t2      # let this be n - i, need to do this several times
        addi t4, t4, -1     # let this be n - i - 1, need to do this several times

    j LOOP1

SWAP:
    lw t5, 0(a1)
    lw t6, 4(a1)
    
    ble t5, t6, END2        # if t5 <= t6, no need to swap
    sw t6, 0(a1)            # move t6 to 0(a0)
    sw t5, 4(a1)            # move s0 to 4(a0), where s0 is the previous value at 0
    addi a0, zero, 1        # returns 1 in a0 because values were swapped

    END2: 
        addi a0, zero, 0    # returns 0 in a0 because nothing was swapped
        jr ra

END: j END

.global LIST
.data
LIST:
.word 10, 1400, 45, 23, 5, 3, 8, 17, 4, 20, 33