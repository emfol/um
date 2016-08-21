/*
 * @file strcpy.s
 * @description this program tests the um_strcp library function.
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

str_1:
    .asciz "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
str_2:
    .asciz "Sed euismod consectetur purus ut sodales. Phasellus vitae lobortis lacus."
str_3:
    .ascii "Aliquam vel lacus in metus molestie tristique id ac felis.\n"
    .ascii "    ... Etiam aliquam rutrum tincidunt.\n"
    .asciz "    ... Donec hendrerit at finibus nibh, pulvinar laoreet augue."
str_4:
    .byte 0
str_5:
    .asciz "Fibonacci..."

.balign 16, 0

test_array:

    .long str_1
    .long str_2
    .long str_3
    .long str_4
    .long str_5
    # end marker
    .long 0


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
    # ... last record, done!
    jmp 4f

  2:
    # print marker
    pushl $marker
    call um_puts
    addl $4, %esp

    # push expected string onto stack
    movl -12(%ebp), %eax
    pushl (%eax)
    # ... calculate length and save it
    call um_strlen
    movl %eax, -8(%ebp)
    # ... and then print
    call um_puts
    addl $4, %esp

    # apply format
    movl -12(%ebp), %eax
    pushl (%eax)
    pushl -4(%ebp)
    call um_strcp
    addl $8, %esp
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
    pushl (%eax)
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
    addl $4, %eax # next record is 4 bytes (1 dword) away...
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
