.global convert
.type matrix_mul, %function

.align 2
# int convert(char *);
convert:

    # insert your code here
    # Green card here: https://www.cl.cam.ac.uk/teaching/1617/ECAD+Arch/files/docs/RISCVGreenCardv8-20151013.pdf
    
    addi t0, zero, 10  # t0 = 10
    addi t1, zero, 0   # t1 is i
    add t2, a0, t1     # t2 = &string[i]
    lb t3, 0(t2)       # t3 = string[i]
    addi t4, zero, 0  # t4 is the return value
    addi t5, zero, 45 # t5 is ascii
    # ascii: - = 45, + = 43, 0 = 48, 9 = 57

    addi t6, zero, 0 # t6 flag for negative
    
    bne t3, t5, L1
    addi t6, zero, 1 # t6 indicate that it is negative
L1:
    beq t3, t5, READ  # check if it is +/-
    addi t5, zero, 43
    beq t3, t5, READ

    addi t5, zero, 48 # check for non-digit, t4 = -1
    blt t3, t5, ERROR
    addi t5, zero, 58
    bge t3, t5, ERROR


    addi t3, t3, -48
    add t4, zero, t3

READ:
    addi t1, t1, 1   # i = i + 1
    add t2, a0, t1     # t2 = &string[i]
    lb t3, 0(t2)       # t3 = string[i]
    
    beq t3, zero, L2 # check end of the string

    addi t5, zero, 48 # check for non-digit, t4 = -1
    blt t3, t5, ERROR
    addi t5, zero, 58
    bge t3, t5, ERROR

    mul t4, t4, t0 # t4 = 10*t4 + (t3-48)
    addi t3, t3, -48
    add t4, t4, t3
    beq zero, zero, READ 
    
L2:
    beq t6, zero, EXIT # check negative
    sub t4, zero, t4
    beq zero, zero, EXIT
ERROR:
    addi t4, zero, -1
EXIT:
    addi a0, t4, 0
    ret

