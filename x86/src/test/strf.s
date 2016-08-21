/*
 * @file strf.s
 * @description this program tests the um_strf library function.
 */

    .data

# Test Accessories

marker:
    .asciz " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
error_rg:
    .asciz "$$ REGISTER CORRUPTION ERROR"
error_st:
    .asciz "$$ STACK CORRUPTION ERROR"
failure:
    .asciz "@@ FAIL"
success:
    .asciz "@@ OK"

# Test Data

s_fmt1:
    .asciz "Shu, Ha, Ri: %s, %s, %s!"
s_arg1_0:
    .asciz "Imitate"
s_arg1_1:
    .asciz "Assimilate"
s_arg1_2:
    .asciz "Innovate"
s_xre1:
    .asciz "Shu, Ha, Ri: Imitate, Assimilate, Innovate!"

.balign 16, 0

test_array:
    # struct test {
    #   char *fmt;  (base)
    #   void *arg0; (base + 4)
    #   void *arg1; (base + 8)
    #   void *arg2; (base + 12)
    #   void *arg3; (base + 16) # up to 4 args for testing purposes
    #   char *xre;  (base + 20)
    # };
    .long s_fmt1, s_arg1_0, s_arg1_1, s_arg1_2, 0, s_xre1

    # end marker
    .long 0, 0, 0, 0, 0, 0


    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp
    subl $40, %esp # 10 dwords for locals

    # reserve 256 dwords (1024 bytes) for buffer
    subl $1024, %esp
    movl %esp, -4(%ebp)

    # save registers
    pushl %ebx
    pushl %esi
    pushl %edi

    # -4(%ebp) : buffer
    # -8(%ebp) : length
    # -12(%ebp): test_array pointer
    # -16(%ebp): count
    # -20(%ebp): %ebx backup
    # -24(%ebp): %esi backup
    # -28(%ebp): %edi backup
    # -32(%ebp): %ebx marker
    # -36(%ebp): %esi marker
    # -40(%ebp): %edi marker

    # initialization
    movl $0, %eax
    movl %eax, -16(%ebp)
    # ... %ebx, %esi, %edi
    movl %ebx, -20(%ebp)
    movl %esi, -24(%ebp)
    movl %edi, -28(%ebp)
    movl $0x76543210, %ebx
    movl %ebx, -32(%ebp)
    movl $0xFEDCBA98, %esi
    movl %esi, -36(%ebp)
    movl $0xBA987654, %edi
    movl %edi, -40(%ebp)
    # ... test array pointer
    movl $test_array, %eax
    movl %eax, -12(%ebp)

  1:
    # check for if last record...
    cmpl $0, (%eax)
    jne 2f
    cmpl $0, 4(%eax)
    jne 2f
    cmpl $0, 8(%eax)
    jne 2f
    cmpl $0, 12(%eax)
    jne 2f
    cmpl $0, 16(%eax)
    jne 2f
    cmpl $0, 20(%eax)
    jne 2f
    # ... last record, done!
    jmp 4f

  2:
    # print marker
    pushl $marker
    call um_puts
    addl $4, %esp

    # push expected string onto stack
    movl -12(%ebp), %eax
    pushl 20(%eax)
    # ... calculate length and save it
    call um_strlen
    movl %eax, -8(%ebp)
    # ... and then print
    call um_puts
    addl $4, %esp

    # apply format
    movl -12(%ebp), %eax
    pushl 16(%eax)
    pushl 12(%eax)
    pushl 8(%eax)
    pushl 4(%eax)
    pushl (%eax)
    pushl -4(%ebp)
    call um_strf
    addl $24, %esp
    # check length of resulting string
    cmpl -8(%ebp), %eax
    jne 2f
    # success
    movl $success, %eax
    jmp 3f
  2:
    # failure
    movl $failure, %eax
  3:
    # print result string for length test
    pushl %eax
    call um_puts
    addl $4, %esp

    # print returned string
    pushl -4(%ebp)
    call um_puts
    addl $4, %esp

    # compare strings (expected vs returned)
    movl -12(%ebp), %eax
    pushl 20(%eax)
    pushl -4(%ebp)
    call um_strcmp
    addl $8, %esp
    cmpl $0, %eax
    jne 2f
    # success
    movl $success, %eax
    jmp 3f
  2:
    # failure
    movl $failure, %eax
  3:
    #print result
    pushl %eax
    call um_puts
    addl $4, %esp

    # increment test count
    incl -16(%ebp)
    # check if %ebx, %esi and %edi have been preserved...
    cmpl -32(%ebp), %ebx
    jne 2f
    cmpl -36(%ebp), %esi
    jne 2f
    cmpl -40(%ebp), %edi
    jne 2f
    # next...
    movl -12(%ebp), %eax
    addl $24, %eax # next record is 24 bytes (6 dwords) away...
    movl %eax, -12(%ebp)
    jmp 1b

  2:
    # register error
    pushl $error_rg
    call um_puts
    addl $4, %esp

  4:

    # check original values of %ebx, %esi, %edi
    movl %esp, %eax
    movl (%eax), %edx
    cmpl -28(%ebp), %edx
    jne 2f
    movl 4(%eax), %edx
    cmpl -24(%ebp), %edx
    jne 2f
    movl 8(%eax), %edx
    cmpl -20(%ebp), %edx
    je 3f

  2:
    # stack error
    pushl $error_st
    call um_puts
    addl $4, %esp

  3:
    movl -16(%ebp), %eax

    popl %edi
    popl %esi
    popl %ebx

    leave
    ret
