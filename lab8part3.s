.global _start
.text

# t0: timer value
# t1: period value

# s0: keys address
# s1: LEDs address
# s2: value to be displayed on LEDs, incrementing every 0.25 s unless button is pressed to stop counter 
# s3: contains max value to be counted (255)
# s4: check if a button pressed
# s5: check if button released after pressed
# s6: used to flag if a button was pressed to stop the counter to allow the second button to start the counter
# s7: edgecapture register


_start:
    .equ PERIOD, 25000000
    .equ TIMER, 0xFF202000
    .equ LEDR, 0xFF200000
    .equ KEYS, 0xFF200050

    li t0, TIMER                                 
    li t1, PERIOD                               
    li s0, KEYS                                 
    li s1, LEDR                                 
    li s2, 0                                    
    li s3, 255                                  
    li s6, 0                                    


    li t2, 0x0000FFFF
    srli t3, t1, 16                             # upper 16 bits of t1 (period value) shifted to the lower 16 bits of t3
    and t1, t1, t2                              # extract the lower 16 bits of t1 (period value)

    sw t1, 8(t0)                                # store lower 16 bits of t1 in 8(t0)
    sw t3, 12(t0)                               # store upper 16 bits of t1 in 12(t0)

    addi t4, zero, 6                            # t4 = 0b0110 (STOP = 0 | START = 1 | CONT = 1 | ITO = 0)
    sw t4, 4(t0)                                # start the timer

DISPLAY:
    sw s2, 0(s1)

POLL1:
    lw t5, 0(t0)                                # load RUN and TO values from 0(t0) to t5
    andi t5, t5, 1                              # extract TO bit from 0(t0)

    lw s4, 0(s0)                                # within POLL1, want to check to see if a button is pressed 
    bnez s4, BUTTON_PRESSED                     # if s4 != 0 then at least one button has been pressed 

    beqz t5, POLL1                              # if tO = 0, then keep looping

    beq s2, s3, RESET                           # resets the counter if it reached a value of s2 = 255
    addi s2, s2, 1                              # otherwise, it increments the counter by own and displays the new value
    sw zero, 0(t0)                              # storing zero to timer status register will reset TO bit to 0
    j DISPLAY

RESET:
    li s2, 0                                    # resets the counter to 0 (s2 = 0) after reaching 255 and displays the value
    sw zero, 0(t0)                              # storing zero to timer status register will reset TO bit to 0
    j DISPLAY

BUTTON_PRESSED:
    lw s5, 0(s0)                                # use s5 to monitor if key is released (key released if s5 = 0b0000)
    bnez s5, BUTTON_PRESSED

    li s5, 1                                    # key has been released, so set s5 = 0b0001 (relevant immediate)
    and s7, s4, s5                              # mask other key presses (only checking if kEY0 pressed), t1 contains value indicating which key pressed
    bne s5, s7, CHECK_1                         # if KEY0 is not pressed (s5 != s7), then check if KEY1 was pressed
    sw s7, 12(s0)                               # since KEY0 has been pressed, reset relevant bit in the edgecapture register
    beqz s6, STOP_COUNTER                       # if s6 = 0, stop counter
    j START_COUNTER                             # if s6 = 1, start counter

CHECK_1:
    li s5, 2                                    # s5 = 0b0010 used to check if KEY1 pressed
    and s7, s4, s5                              # mask other key presses (only checking if KEY1 pressed)
    bne s5, s7, CHECK_2                         # if s5 != s7 then KEY1 not pressed, so check if KEY2 or KEY3 pressed
    sw s7, 12(s0)                               # KEY1 pressed, reset relevant bit in edgecapture register
    beqz s6, STOP_COUNTER                       # if s6 = 0, stop counter
    j START_COUNTER                             # if s6 = 1, start counter

CHECK_2:
    li s5, 4                                    # s5 = 0b0100 used to check if KEY2 pressed
    and s7, s4, s5                              # mask other key presses (only checking if KEY2 pressed)
    bne s5, s7, CHECK_3                         # if s5 != s7, KEY2 not pressed, so check if KEY3 pressed
    sw s7, 12(s0)                               # KEY2 pressed, reset relevant bit in edgecapture register
    beqz s6, STOP_COUNTER                       # if s6 = 0, stop counter
    j START_COUNTER                             # if s6 = 1, start counter

CHECK_3:
    li s5, 8                                    # s5 = 0b1000 used to check if KEY3 pressed
    and s7, s4, s5                              # mask other key presses (only checking if KEY3 pressed)
    sw s7, 12(s0)                               # KEY3 pressed, reset relevant bit in edgecapture register
    beqz s6, STOP_COUNTER                       # if s6 = 0, stop counter
    j START_COUNTER                             # if s6 = 1, start counter

START_COUNTER:
    li s6, 0                                    # reset s6 to 0 to indicate that a button has been pressed to start counter
    addi t4, zero, 6                            # t4 = 0b0110 (STOP = 0 | START = 1 | CONT = 1 | ITO = 0)
    sw t4, 4(t0)                                # start the timer
    j DISPLAY

STOP_COUNTER:
    li s6, 1                                    # set s6 to 1 to indicate that a button has been pressed to stop counter
    addi t4, zero, 10                           # t4 = 0b1010 (STOP = 1 | START = 0 | CONT = 1 | ITO = 0)
    sw t4, 4(t0)                                # stop the timer

POLL2:
    lw s4, 0(s0)
    bnez s4, BUTTON_PRESSED                     # if s4 != 0, button pressed
    j POLL2