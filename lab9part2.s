.global _start
_start:

	.equ LEDs,  	  0xFF200000
	.equ TIMER, 	  0xFF202000
	.equ PUSH_BUTTON, 0xFF200050
	.equ TOP_COUNT, 25000000
        .equ MAX_COUNT, 800000000
        .equ MIN_COUNT, 390625
	
	li sp, 0x20000                   # set up the stack pointer
	
	jal    CONFIG_TIMER              # configure the Timer
        jal    CONFIG_KEYS               # configure the KEYs port
	
	/*Enable Interrupts in the NIOS V processor, and set up the address handling
	location to be the interrupt_handler subroutine*/
	
        csrw mstatus, zero               # turn off interrupts in case an interrupt is called before correct set up

        li t0, 0x50000
        csrw mie, t0                     # activate interrupts from IRQ16 (Timer) and IRQ18 (Pushbuttons)

        la t0, interrupt_handler
        csrw mtvec, t0                   # set the mtvec register to be the interrupt_handler location

        li t0, 0b1000
        csrw mstatus, t0                 # turn the interrupts back on	
	
	la s0, LEDs
	la s1, COUNT

	LOOP:
            lw s2, 0(s1)                 # get current count
	    sw s2, 0(s0)                 # store count in LEDs
	j LOOP


interrupt_handler:
	addi sp, sp, -16
        sw s0, 0(sp)
        sw s1, 4(sp)
        sw s2, 8(sp)
        sw s3, 12(sp)

        csrr s0, mcause
        
        li s1, 0x80000010
        li s2, 0x80000012
  
        beq s0, s1, Timer_ISR            # check to see if timer caused interrupt
        beq s0, s2, KEYs_ISR             # check to see if pushbuttons caused interrupt
        
        return:
            lw s0, 0(sp)
            lw s1, 4(sp)
            lw s2, 8(sp)
            lw s3, 12(sp)
            addi sp, sp, 16
            mret
        
        Timer_ISR:
            la s0, COUNT
            lw s1, 0(s0)
            li s2, 255
            li s3, TIMER

            beq s1, s2, RESET            # check to see if COUNT value has reached 255, if it has then reset COUNT to 0
            addi s1, s1, 1               # increment current COUNT value by 1 (hasn't reached the maximum yet)
            sw s1, 0(s0)                 # store new COUNT value in COUNT
            sw zero, 0(s3)               # reset TO bit in timer to 0

        j return

        RESET:
            li s2, 0
            sw s2, 0(s0)                 # reset COUNT to 0
            sw zero, 0(s3)               # reset TO bit in timer to 0

        j return

        KEYs_ISR:
            li s0, PUSH_BUTTON
            la s1, RUN
            lw s2, 12(s0)

            li s3, 0b0010
            beq s3, s2, KEY_1            # check if KEY 1 was pressed

            li s3, 0b0100
            beq s3, s2, KEY_2            # check if KEY 2 was pressed

            lw s2, 0(s1)
            bnez s2, STOP_COUNTER        # check if the counter is currently running (i.e., RUN is not equal to 0)

            li s3, TIMER
            li s2, 1                     
            sw s2, 0(s1)                 # set RUN = 1 to start the counter (previously RUN = 0 - the counter was not running)
            
            li s2, 0b0111                # s2 = 0b0111 (STOP = 0 | START = 1 | CONT = 1 | ITO = 1)
            sw s2, 4(s3)                 # start the timer

            li s2, 0b1111
            sw s2, 12(s0)                # clear edgecapture register bits
        
        j return

        STOP_COUNTER:
            li s2, 0 
            li s3, TIMER
            sw s2, 0(s1)                 # set RUN = 0 to stop the counter (previously RUN = 1 - the counter was running)

            li s2, 0b1011                # s2 = 0b1011 (STOP = 1 | START = 0 | CONT = 1 | ITO = 1)
            sw s2, 4(s3)                 # stop the timer

            li s2, 0b1111
            sw s2, 12(s0)                # clear edgecapture register bits

        j return 

        KEY_1:
            li s0, TIMER
            
            lw s1, 12(s0)                # load upper 16 bits of timer period in s1
            lw s2, 8(s0)                 # load lower 16 bits of timer period in s2
            slli s1, s1, 16              
            or s3, s1, s2                # current timer period

            li s1, MIN_COUNT             # load the minimum value of the timer period to s1
            beq s1, s3, return           # if the current timer period has reached the minimum timer period, don't change it and go to return

            li s1, 0b1011                # s1 = 0b1011 (STOP = 1 | START = 0 | CONT = 1 | ITO = 1)
            sw s1, 4(s0)                 # stop the timer

            srli s3, s3, 1               # to double the rate of the counter, reduce the period by a factor of 2 (period * 0.5)
            li s1, 0x0000FFFF            # load immediate to split period value into two sets of 16 bits
            srli s2, s3, 16              # upper 16 bits of s3 (period value) shifted to the lower 16 bits of s2
            and s1, s1, s3               # extract the lower 16 bits of s3 (period value)
            sw s1, 8(s0)                 # store lower 16 bits of s3 in 8(s0)
            sw s2, 12(s0)                # store upper 16 bits of s3 in 12(s0)
			
            li s1, 0b0111                # s1 = 0b0111 (STOP = 0 | START = 1 | CONT = 1 | ITO = 1)
            sw s1, 4(s0)                 # start the timer
			
	    li s2, PUSH_BUTTON
            li s1, 0b1111
            sw s1, 12(s2)                # clear edgecapture register bits

        j return


        KEY_2:
            li s0, TIMER
            
            lw s1, 12(s0)                # load upper 16 bits of timer period in s1
            lw s2, 8(s0)                 # load lower 16 bits of timer period in s2
            slli s1, s1, 16              
            or s3, s1, s2                # current timer period

            li s1, MAX_COUNT             # load the minimum value of the timer period to s1
            beq s1, s3, return           # if the current timer period has reached the minimum timer period, don't change it and go to return

            li s1, 0b1011                # s1 = 0b1011 (STOP = 1 | START = 0 | CONT = 1 | ITO = 1)
            sw s1, 4(s0)                 # stop the timer

            slli s3, s3, 1               # to halve the rate of the counter, increase the period by a factor of 2 (period * 2)
            li s1, 0x0000FFFF            # load immediate to split period value into two sets of 16 bits
            srli s2, s3, 16              # upper 16 bits of s3 (period value) shifted to the lower 16 bits of s2
            and s1, s1, s3               # extract the lower 16 bits of s3 (period value)
            sw s1, 8(s0)                 # store lower 16 bits of s3 in 8(s0)
            sw s2, 12(s0)                # store upper 16 bits of s3 in 12(s0)

            li s1, 0b0111                # s1 = 0b0111 (STOP = 0 | START = 1 | CONT = 1 | ITO = 1)
            sw s1, 4(s0)                 # start the timer
			
            li s2, PUSH_BUTTON
	    li s1, 0b1111
            sw s1, 12(s2)                # clear edgecapture register bits

        j return


CONFIG_TIMER: 
        li t0, TIMER                     # load base address of timer

        li t1, TOP_COUNT                 # load period value to configure
        li t2, 0x0000FFFF                # load immediate to split period value into two sets of 16 bits
        srli t3, t1, 16                  # upper 16 bits of t1 (period value) shifted to the lower 16 bits of t3
        and t1, t1, t2                   # extract the lower 16 bits of t1 (period value)
        sw t1, 8(t0)                     # store lower 16 bits of t1 in 8(t0)
        sw t3, 12(t0)                    # store upper 16 bits of t1 in 12(t0)

        li t1, 0b0111                    # t1 = 0b0111 (STOP = 0 | START = 1 | CONT = 1 | ITO = 1)
        sw t1, 4(t0)                     # start the timer, ensure it resets once the count reaches 0, and enable timer to generate interrupts
        
        jr ra

CONFIG_KEYS: 
        li t0, PUSH_BUTTON               # load base address of pushbuttons
        li t1, 0b1111                    # configure all 4 keys to interrupt

        sw t1, 8(t0)                     # set interrupt bit for all 4 keys to 1
        sw t1, 12(t0)                    # reset edgecapture register bits to 0

        jr ra

.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0                     # used by timer
.global  RUN                             # used by pushbutton KEYs
RUN:    .word    0x1                     # initial value to increment COUNT
.end
