# Press KEY0: 1
# Press KEY1: +1  (can't let number go above 15 - pressing key when at 15 will remain at 15)
# Press KEY2: -1  (can't let number go below 1 - pressing key when at 1 will remain at 1)
# Press KEY3: blank display (0) - press any key to return to 1

# s0: keys address
# s1: LEDs address
# s2: check if key is pressed, contains value indicating which key is pressed 
# s3: check if key is released
# s4: update LED based on relevant key pressed
# s5: mask keys to check for single key being pressed
# s6: check if KEY3 was pressed previously  


.global _start
.text

_start:
    
    li s0, 0xFF200050                           
    li s1, 0xFF200000                           
    li s6, 0                                    

POLL:
    lw s2, 0(s0)                            # use s2 to poll for key press
    beqz s2, POLL                           # if s2=0b0000, no key is pressed, so keep polling

WAIT: 
    lw s3, 0(s0)                            # use s3 to check if key is released 
    bnez s3, WAIT                           # if s3!=0b0000, key is not released, so keep waiting               

    li s3, 1                                # key is released, so set s3 = 0b0001 
    andi s5, s2, 0x1                        # mask other key presses (check one key at a time, starting with KEY0)
    bne s5, s3, check_KEY1                  # if s5!=0x1, KEY0 not pressed, so check if KEY1 pressed         
    beq s6, s3, KEY3_pressed                # KEY0 is pressed, if s6=s3=1, KEY3 is previously pressed, so go to KEY3_pressed
    li s4, 1                                # KEY3 was not pressed previously, LED0 will light up, display 1 (0b0000000001)
    j update_LED                                

check_KEY1:
    li s3, 2                                # use s3=0b0010 to check if KEY1 pressed
    and s5, s2, s3                          # mask other key presses (only check if KEY1 pressed)
    bne s5, s3, check_KEY2                  # if s5!=s3, KEY1 not pressed, so check if KEY2 or KEY3 pressed
    li s3, 1                                # KEY1 pressed, so load s3 with value of 1
    beq s6, s3, KEY3_pressed                # KEY1 pressed, if s6=s3=1, KEY3 is previously pressed, so go to KEY3_pressed
    li s3, 15                               # load s3 with value of 15 to check if s4=15 (0b1111)
    beq s4, s3, update_LED                  # if s4=s3, s4 remains same, so "update to" same value
    addi s4, s4, 1                          # otherwise, s4+=1
    j update_LED

check_KEY2:
    li s3, 4                                # use s3=0b0100 to check if KEY2 is pressed
    and s5, s3, s2                          # mask other key presses (only check if KEY2 pressed)
    bne s5, s3, check_KEY3                  # if s5!=s3, KEY2 not pressed, so if KEY3 pressed
    li s3, 1                                # load s3 with value of 1
    beq s6, s3, KEY3_pressed                # KEY2 pressed, if s6=s3=1, KEY3 is previously pressed, so go to KEY3_pressed
    beq s4, s3, update_LED                  # if s4=s3, s4 remains same, so "update to" same value
    addi s4, s4, -1                         # otherwise, s4-=1
    j update_LED

check_KEY3:
    li s4, 0                                # KEY3 pressed, no LEDs will light up, display 0 (0b0000000000)
    li s6, 1                                # KEY3 previously pressed, so s4=1 after pressing any other key
    j update_LED

KEY3_pressed:
    li s4, 1
    li s6, 0

update_LED:
    sw s4, 0(s1)
    j POLL