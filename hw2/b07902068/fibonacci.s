.global fibonacci
.type fibonacci, %function

.align 2
# unsigned long long int fibonacci(int n);
fibonacci:  
    
    # insert code here
    # Green card here: https://www.cl.cam.ac.uk/teaching/1617/ECAD+Arch/files/docs/RISCVGreenCardv8-20151013.pdf
    addi t2, zero, 2 # t2 = 2
    addi t3, a0, 0 # t3 is the answer Fn
    blt a0, t2, EXIT # if n < 2 goto exit
    addi t0, zero, 1 # t0 be the counter i
    addi t1, zero, 0 # set  Fi-2
    addi t2, zero, 1 # set  Fi-1
   
LOOP:
    addi t0, t0, 1 # i += 1
    add t3, t1, t2 # Fi = Fi-2 + Fi-1
    addi t1, t2, 0 # set next Fn-2
    addi t2, t3, 0 # set next Fn-1
    bne t0, a0, LOOP
EXIT: 
    add a0, zero, t3 # set return value
    ret
    
