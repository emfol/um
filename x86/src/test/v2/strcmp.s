/*
 * @file strcmp.s
 * @description this program tests the um_strcmp library function.
 */

    .data

# Test Data

str_a:
    .asciz "a"
str_b:
    .asciz "b"
str_aa:
    .asciz "aa"
str_ab:
    .asciz "ab"
str_0:
    .asciz "abcdefghijklmnopqrstuvwxyz0123456789"
str_1:
    .ascii "abcd"
    .byte 0xC3, 0xA9
    .ascii "fghijklmnopqrstuvwxyz"
    .byte 0x00
str_2:
    .asciz "abcd"
str_3:
    .ascii "abcd"
    .byte 0xC3, 0xA9
    .byte 0x00
str_4:
    .byte 0xCF, 0x80, 0x00
str_5:
    .byte 0xCF, 0x80, 0xF0, 0x9F, 0x92, 0xA9, 0x00
str_6:
    .ascii "abcdefghijklmnopqrstuvwxyz"
    .asciz "0123456789"
str_7:
    .byte 255, 0
str_8:
    .byte 0

.balign 16, 0

test_array:

    # struct test {
    #   int flag; # base + 0 if flag == -1 then valid structure
    #   int diff; # base + 4
    #   char *s1; # base + 8
    #   char *s2; # base + 12
    # }

    .long -1, -1,   str_a, str_b
    .long -1, -97,  str_a, str_aa
    .long -1, -98,  str_a, str_ab
    .long -1, 1,    str_b, str_a
    .long -1, 1,    str_b, str_aa
    .long -1, 1,    str_b, str_ab
    .long -1, 0,    str_aa, str_aa
    .long -1, 0,    str_ab, str_ab
    .long -1, -1,   str_aa, str_ab
    .long -1, 1,    str_ab, str_aa
    .long -1, -94,  str_0, str_1
    .long -1, 94,   str_1, str_0
    .long -1, -195, str_2, str_3
    .long -1, 195,  str_3, str_2
    .long -1, -240, str_4, str_5
    .long -1, 240,  str_5, str_4
    .long -1, 0,    str_0, str_6
    .long -1, 0,    str_6, str_0
    .long -1, 255,  str_7, str_8
    .long -1, -255, str_8, str_7

    # end marker
    .long 0


    .text

    .globl test
test:

    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp # 4 dwords for locals

    # -4(%ebp) : total test count
    # -8(%ebp) : completed test count
    # -12(%ebp): array pointer
    # -16(%ebp): tmp

    # initialize locals
    movl $test_array, %edx
    movl %edx, -12(%ebp)
    movl $0, %ecx
    movl %ecx, -8(%ebp)
    movl $-1, %eax
    movl %eax, -4(%ebp)
    jmp 2f
  1:
    # advance test_array pointer
    addl $16, %edx
  2:
    cmpl %eax, (%edx)
    loopz 1b
    subl %ecx, %eax
    movl %eax, -4(%ebp) # amount of tests to be executed

  1:
    # payload
    movl -4(%ebp), %eax
    cmpl -8(%ebp), %eax
    jbe 2f
    movl -12(%ebp), %edx
    movl 4(%edx), %eax
    movl %eax, -16(%ebp) # save expected result to tmp
    movl 12(%edx), %eax
    pushl %eax
    movl 8(%edx), %eax
    pushl %eax
    call um_strcmp
    addl $4, %esp
    # compare returned value to tmp
    cmpl -16(%ebp), %eax
    jne 2f
    # success
    addl $1, -8(%ebp)
    addl $16, -12(%ebp)
    jmp 1b
  2:
    # leave
    movl -4(%ebp), %eax
    subl -8(%ebp), %eax

    leave
    ret
