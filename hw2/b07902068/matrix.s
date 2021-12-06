.global matrix_mul
.type matrix_mul, %function

.align 2
# void matrix_mul(unsigned int A[][], unsigned int B[][], unsinged int C[][]);
matrix_mul:
    
    # insert code here
    # Green card here: https://www.cl.cam.ac.uk/teaching/1617/ECAD+Arch/files/docs/RISCVGreenCardv8-20151013.pdf
    # Matrix multiplication: https://en.wikipedia.org/wiki/Matrix_multiplication
    addi sp, sp, -88
    sd s1, 0(sp) 
    sd s2, 8(sp) 
    sd s3, 16(sp) 
    sd s4, 24(sp) 
    sd s5, 32(sp) 
    sd s6, 40(sp) 
    sd s7, 48(sp) 
    sd s8, 56(sp) 
    sd s9, 64(sp) 
    sd s10, 72(sp) 
    sd s11, 80(sp) 
    add t0, zero, a0    # t0, t1, t2 is index of A, B, C in memory address
    add t1, zero, a1    # load to a3, a4, a5
    add t2, zero, a2
    addi t3, zero, 1024 # t3 = 1024 used for mod
    addi t5, zero, 1    
    slli t5, t5, 15     # t5 = 128*128*2 used to indicate the end of a array
    addi t6, zero, 128
    slli t6, t6, 8      # t6 = 256*128 used to reset index of B
    addi a7, t0, 256    # a7 used as end of row
    addi t4, t2, 256  # t4 = 256 * n used to indicate the end of a row
    add t5, t2, t5      # t5 is end of whole array
L1:
    addi a5, zero, 0 # C[i][k] to C[i][k+7]
    addi s1, zero, 0
    addi s2, zero, 0
    addi s3, zero, 0
    addi s4, zero, 0
    addi s5, zero, 0
    addi s6, zero, 0
    addi s7, zero, 0
    addi a0, zero, 0 # C[i][k] to C[i][k+7]
    addi a1, zero, 0
    addi a2, zero, 0
    addi a6, zero, 0
    addi s8, zero, 0
    addi s9, zero, 0
    addi s10, zero, 0
    addi s11, zero, 0
L2:
    lhu a3, 0(t0)    # load A[i][k], B[k][j]
    lhu a4, 0(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add a5, a5, a4  # C[i][j] += A[i][k] * B[k][j]
    remu a5, a5, t3  # C[i][j] %= 1024


    lhu a4, 2(t1)   # B[K][j+1]
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j+1]
    add s1, s1, a4  # C[i][j+1] += A[i][k] * B[k][j+1]
    remu s1, s1, t3  # C[i][j+1] %= 1024
    
    lhu a4, 4(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s2, s2, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s2, s2, t3  # C[i][j] %= 1024
    

    lhu a4, 6(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s3, s3, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s3, s3, t3  # C[i][j] %= 1024

    lhu a4, 8(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s4, s4, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s4, s4, t3  # C[i][j] %= 1024
    

    lhu a4, 10(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s5, s5, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s5, s5, t3  # C[i][j] %= 1024

    lhu a4, 12(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s6, s6, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s6, s6, t3  # C[i][j] %= 1024

    lhu a4, 14(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s7, s7, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s7, s7, t3  # C[i][j] %= 1024

    lhu a4, 16(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add a0, a0, a4  # C[i][j] += A[i][k] * B[k][j]
    remu a0, a0, t3  # C[i][j] %= 1024

    lhu a4, 18(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add a1, a1, a4  # C[i][j] += A[i][k] * B[k][j]
    remu a1, a1, t3  # C[i][j] %= 1024

    lhu a4, 20(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add a2, a2, a4  # C[i][j] += A[i][k] * B[k][j]
    remu a2, a2, t3  # C[i][j] %= 1024

    lhu a4, 22(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add a6, a6, a4  # C[i][j] += A[i][k] * B[k][j]
    remu a6, a6, t3  # C[i][j] %= 1024

    lhu a4, 24(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s8, s8, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s8, s8, t3  # C[i][j] %= 1024

    lhu a4, 26(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s9, s9, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s9, s9, t3  # C[i][j] %= 1024

    lhu a4, 28(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s10, s10, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s10, s10, t3  # C[i][j] %= 1024

    lhu a4, 30(t1)
    mul a4, a3, a4  # a6 = A[i][k] * B[k][j]
    add s11, s11, a4  # C[i][j] += A[i][k] * B[k][j]
    remu s11, s11, t3  # C[i][j] %= 1024

    addi t0, t0, 2   # A: next column 
    addi t1, t1, 256 # B: nest row
    blt t0, a7, L2   # A is not at end of row
    sh a5, 0(t2) 
    sh s1, 2(t2) 
    sh s2, 4(t2) 
    sh s3, 6(t2) 
    sh s4, 8(t2) 
    sh s5, 10(t2) 
    sh s6, 12(t2) 
    sh s7, 14(t2) 
    sh a0, 16(t2) 
    sh a1, 18(t2) 
    sh a2, 20(t2) 
    sh a6, 22(t2) 
    sh s8, 24(t2) 
    sh s9, 26(t2) 
    sh s10, 28(t2) 
    sh s11, 30(t2) 

    addi t0, t0, -256# reset k
    sub t1, t1, t6   # reset k for B
    addi t1, t1, 32 
    addi t2, t2, 32   # j += 1
    blt t2, t4, L1
    
    addi a7, a7, 256 # i += 1 for A
    addi t4, t4, 256 # i += 1 for C
    addi t0, t0, 256
    addi t1, t1, -256
    blt t2, t5, L1
   
    #11 point
EXIT:
    ld s1, 0(sp) 
    ld s2, 8(sp) 
    ld s3, 16(sp) 
    ld s4, 24(sp) 
    ld s5, 32(sp)
    ld s6, 40(sp) 
    ld s7, 48(sp) 
    ld s8, 56(sp) 
    ld s9, 64(sp) 
    ld s10, 72(sp) 
    ld s11, 80(sp)
    addi sp, sp, 88 
    ret
