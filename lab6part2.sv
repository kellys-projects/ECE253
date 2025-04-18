# program that counts consecutive 1’s

.global _start
.text

_start:
   la s2, LIST            # load the address of LIST into register s2
   lw s3, 0(s2)           # load the word at address s2 into register s3  # s3 now holds the word 0x103fe00f (binary: 0001 0000 0011 1111 1110 0000 0000 1111)                       
   addi s4, zero, 0       # initialize s4 to 0, it will hold the count of the longest string of 1s
  

# Main Loop to count consecutive 1s

LOOP: 
   beqz s3, END           # if s3 is zero, branch to END (however, s3 is not zero here)
   srli s2, s3, 1         # shift right logical s3 by 1 bit, store the result in s2
   and s3, s3, s2         # perform bitwise AND between s3 and s2, store result back in s3
   addi s4, s4, 1         # increment s4 by 1 (counting a consecutive 1)
   j LOOP                 # jump back to LOOP to repeat the process

END: j END                  

.global LIST
.data
 LIST:
.word 0x103fe00f


.data
LIST:
.word 0x103fe00f       # the word of data to be analyzed
