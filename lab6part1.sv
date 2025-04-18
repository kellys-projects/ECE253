# sum of the numbers should be stored in register s10, and the count of the numbers should be stored in register s11.

# for instance, consider the list: 1, 2, 3, 5, 10. your code should store the value 21 (0x15) in register s10 and the value 5 in register s11 when the program completes 

# list will be stored at the memory location labeled LIST and will consist of positive numbers (i.e., numbers>0) ending with a value of-1 (i.e.: a-1 value indicates the end of the list)


.global _start
.text

_start:
    la s2, LIST                 # load address of the list into register s2
    addi s10, zero, 0           # initialize sum (s10) and count (s11) to 0
    addi s11, zero, 0

loop:
    lw t0, 0(s2)          # load the current item from the list into register t0
    
    li t1, -1             # check if the current item is -1 (end of list)   # li = load immediate
    beq t0, t1, END       # branch if equal: if the value of t1 = t0, then go to END, otherwise go to next instruction    
    
    add s10, s10, t0      # add the current item to the sum
       
    addi s11, s11, 1      # increment the count
       
    addi s2, s2, 4        # move to the next item in the list (increment address by 4 bytes)
     
    j loop                # repeat the loop

END: j END

.global LIST
.data
 LIST:
.word 1, 2, 3, 5, 0xA, -1







