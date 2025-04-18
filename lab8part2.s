# lab8part2.s

# counter should increment every 0.25 seconds 
# when counter reaches 255, start again at 0
# counter stops/starts when any pushbutton KEY is pressed

# manual recommends a 500,000 delay for CPUlator and 10,000,000 delay for DE1-SoC Board        

# s0: keys address
# s1: LEDs address
# s2: value to be displayed on LEDs, incrementing every 0.25 s unless button is pressed to stop counter 
# s3: contains max value to be counted (255)
# s4: check if a button pressed
# s5: check if button released after pressed
# s6: used to flag if a button was pressed to stop the counter to allow the second button to start the counter
# t0: used in delay loop (since clock on FPGA board is 100MHz, t0 = 25,000,000 for 0.25s delay) 
# t1: value indicating which key pressed


.global _start
.text

_start:
    
    li s0, 0xFF200050                           
    li s1, 0xFF200000                           
    li s2, 0                                     
    li s3, 255                                  
    li s6, 0                                     

DISPLAY:
    sw s2, 0(s1)                        # store s2 into s1 (LEDs address)

DO_DELAY: 
    li t0, 500000                       # start DELAY_LOOP from t0 = 500000 (for CPUlator)

DELAY_LOOP:
    addi t0, t0, -1                     # -1 every time DELAY_LOOP is executed until t0 = 0

    lw s4, 0(s0)                        # check if a button is pressed 
    bnez s4, BUTTON_PRESSED             # if s4 != 0 then at least one button pressed 

    bnez t0, DELAY_LOOP                 # if no button pressed, keep cycling through DELAY_LOOP until t0 = 0

COUNTER:
    beq s2, s3, RESET                   # if s2 = s3 = 255, reset counter 
    addi s2, s2, 1                      # otherwise, increment counter and display new value
    j DISPLAY

RESET:
    li s2, 0                            # reset counter to 0 (s2 = 0) after reaching 255 and display value
    j DISPLAY

BUTTON_PRESSED:
    lw s5, 0(s0)                        # check if key is released (s5 = 0b0000)
    bnez s5, BUTTON_PRESSED

    li s5, 1                            # key released, so set s5 = 0b0001 to check if KEY0 pressed
    and t1, s4, s5                      # mask other key presses (only checking if KEY0 pressed)
    bne s5, t1, CHECK_1                 # if KEY0 not pressed (s5 != t1), check if KEY1 pressed
    sw t1, 12(s0)                       # since KEY0 has been pressed, reset relevant bit in the edgecapture register
    beqz s6, STOP_COUNTER               # if s6 = 0, then stop the counter
    j START_COUNTER                     # if s6 = 1, start the counter

CHECK_1:
    li s5, 2                            # s5 = 0b0010 used to check if KEY1 pressed
    and t1, s4, s5                      # mask other key presses (only checking if KEY1 pressed)
    bne s5, t1, CHECK_2                 # if s5 != t1 then KEY1 not pressed, so check if KEY2 or KEY3 pressed
    sw t1, 12(s0)                       # KEY1 pressed, reset relevant bit in edgecapture register
    beqz s6, STOP_COUNTER               # if s6 = 0, then stop the counter
    j START_COUNTER                     # if s6 = 1, start the counter

CHECK_2:
    li s5, 4                            # s5 = 0b0100 used to check if KEY2 pressed
    and t1, s4, s5                      # mask other key presses (only checking if KEY2 pressed)
    bne s5, t1, CHECK_3                 # if s5 != t1 then KEY2 not pressed, so check if KEY3 pressed
    sw t1, 12(s0)                       # KEY2 pressed, reset relevant bit in edgecapture register
    beqz s6, STOP_COUNTER               # if s6 = 0, then stop the counter
    j START_COUNTER                     # if s6 = 1, start the counter

CHECK_3:
    li s5, 8                            # s5 = 0b1000 used to see if KEY3 pressed
    and t1, s4, s5                      # mask other key presses (only checking if KEY3 pressed)
    sw t1, 12(s0)                       # KEY3 pressed, reset relevant bit in Edgecapture register
    beqz s6, STOP_COUNTER               # if s6 = 0, then stop the counter
    j START_COUNTER                     # if s6 = 1, start the counter


START_COUNTER:
    li s6, 0                            # reset s6 to 0 to indicate that a button has been pressed to start the counter
    j DISPLAY

STOP_COUNTER:
    li s6, 1                            # set s6 to 1 to indicate that a button has been pressed to stop the counter

POLL:
    lw s4, 0(s0)
    bnez s4, BUTTON_PRESSED
    j POLL