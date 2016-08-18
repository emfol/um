/*
 * @file strlen.s
 * @description this program tests the um_strcmp library function.
 */

    .data

marker:
    .asciz "-- -- -- -- -- -- -- --"
error:
    .asciz "$$ ERROR"
failure:
    .asciz "++ FAIL"
success:
    .asciz "++ OK"

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
    #   int diff; # base + 0
    #   char *s1; # base + 4
    #   char *s2; # base + 8
    # }
    .long -1,   str_a, str_b
    .long -97,  str_a, str_aa
    .long -98,  str_a, str_ab
    .long 1,    str_b, str_a
    .long 1,    str_b, str_aa
    .long 1,    str_b, str_ab
    .long 0,    str_aa, str_aa
    .long 0,    str_ab, str_ab
    .long -1,   str_aa, str_ab
    .long 1,    str_ab, str_aa
    .long -94,  str_0, str_1
    .long 94,   str_1, str_0
    .long -195, str_2, str_3
    .long 195,  str_3, str_2
    .long -240, str_4, str_5
    .long 240,  str_5, str_4
    .long 0,    str_0, str_6
    .long 0,    str_6, str_0
    .long 255,  str_7, str_8
    .long -255, str_8, str_7

    # end marker
    .long 0, 0, 0

    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp
    subl $12, %esp # 3 dwords
    pushl %ebx

    # -4(%ebp) : test_array
    # -8(%ebp) : count
    # -12(%ebp): %ebx marker

    # initialization
    movl $0xFEDCBA98, %ebx
    movl %ebx, -12(%ebp)
    movl $0, %eax
    movl %eax, -8(%ebp)
    movl $test_array, %eax
    movl %eax, -4(%ebp)

  1:
    # check for if last record...
    cmpl $0, (%eax)
    jne 2f
    cmpl $0, 4(%eax)
    jne 2f
    cmpl $0, 8(%eax)
    jne 2f
    # ... last record, done!
    jmp 4f
  2:
    # print marker
    pushl $marker
    call um_puts
    addl $4, %esp
    # print first string
    movl -4(%ebp), %eax
    pushl 4(%eax)
    call um_puts
    addl $4, %esp
    # print second string
    movl -4(%ebp), %eax
    pushl 8(%eax)
    call um_puts
    addl $4, %esp
    # call um_strcmp
    movl -4(%ebp), %eax
    pushl 8(%eax)
    pushl 4(%eax)
    call um_strcmp
    addl $8, %esp
    movl -4(%ebp), %ecx
    cmpl (%ecx), %eax
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
    incl -8(%ebp)
    # check if %ebx has been preserved...
    cmpl -12(%ebp), %ebx
    jne 2f
    # next...
    movl -4(%ebp), %eax
    addl $12, %eax # next record is 12 bytes (3 dwords) away...
    movl %eax, -4(%ebp)
    jmp 1b

  2:
    #error
    pushl $error
    call um_puts
    addl $4, %esp

  4:
    movl -8(%ebp), %eax

    popl %ebx
    leave
    ret
