/*
 * @file itoa.s
 * @description this program tests the um_itoa library function.
 */

    .data

# Test Accessories

marker:
    .asciz "-- -- -- -- -- -- -- --"
error:
    .asciz "$$ ERROR"
failure:
    .asciz "@@ FAIL"
success:
    .asciz "@@ OK"

# Test Data

str_empty:
    .byte 0
str_1234_10:
    .asciz "1234"
str_s1048576_10:
    .asciz "-1048576"
str_DEADBEEF_2:
    .asciz "11011110101011011011111011101111"
str_DEADBEEF_16:
    .asciz "DEADBEEF"
str_777_8:
    .asciz "777"
str_644_8:
    .asciz "644"

test_array:
    # struct test {
    #   int base;  # base + 0
    #   int num;   # base + 4
    #   int len;   # base + 8
    #   char *str; # base + 12
    # };
    .long 1,  0,          -1, str_empty
    .long 37, 0,          -1, str_empty
    .long 80, 0,          -1, str_empty
    .long 10, 1234,       4,  str_1234_10
    .long 10, -1048576,   8,  str_s1048576_10
    .long 2,  0xDEADBEEF, 32, str_DEADBEEF_2
    .long 16, 0xDEADBEEF, 8,  str_DEADBEEF_16
    .long 8,  0777,       3,  str_777_8
    .long 8,  0644,       3,  str_644_8

    # end marker
    .long 0, 0, 0, 0


    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp
    subl $24, %esp # 6 dwords for locals
    # reserve 12 dwords (48 bytes) for buffer
    subl $48, %esp
    movl %esp, -4(%ebp)
    # save registers
    pushl %ebx
    pushl %esi
    pushl %edi

    # -4(%ebp) : buffer
    # -8(%ebp) : test_array
    # -12(%ebp): count
    # -16(%ebp): %ebx marker
    # -20(%ebp): %esi marker
    # -24(%ebp): %edi marker

    # initialization
    movl $0xDEADBEEF, %ebx
    movl %ebx, -16(%ebp)
    movl $0x12345678, %esi
    movl %esi, -20(%ebp)
    movl $0x87654321, %edi
    movl %edi, -24(%ebp)
    movl $0, %eax
    movl %eax, -12(%ebp)
    movl $test_array, %eax
    movl %eax, -8(%ebp)

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
    # ... last record, done!
    jmp 4f

  2:
    # print marker
    pushl $marker
    call um_puts
    addl $4, %esp

    # print expected string
    movl -8(%ebp), %eax
    pushl 12(%eax)
    call um_puts
    addl $4, %esp

    # perform conversion
    movl -8(%ebp), %eax
    pushl (%eax)
    pushl -4(%ebp)
    pushl 4(%eax)
    call um_itoa
    addl $12, %esp
    # check amount of bytes written
    movl -8(%ebp), %ecx
    cmpl 8(%ecx), %eax
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
    movl -8(%ebp), %eax
    pushl 12(%eax)
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
    incl -12(%ebp)
    # check if %ebx, %esi and %edi have been preserved...
    cmpl -16(%ebp), %ebx
    jne 2f
    cmpl -20(%ebp), %esi
    jne 2f
    cmpl -24(%ebp), %edi
    jne 2f
    # next...
    movl -8(%ebp), %eax
    addl $16, %eax # next record is 16 bytes (4 dwords) away...
    movl %eax, -8(%ebp)
    jmp 1b

  2:
    #error
    pushl $error
    call um_puts
    addl $4, %esp

  4:
    movl -12(%ebp), %eax

    popl %edi
    popl %esi
    popl %ebx
    leave
    ret
