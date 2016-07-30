/*
 * @file strlen.s
 * @description this program tests the um_strlen library function.
 */

    .data

string1:
    .asciz "abcdefghijklmnopqrstuvwxyz" # 26
string2:
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .byte 0 # 288
string3:
    .asciz "@x*&@!%^$#(8)%;:/?<>|\\~" # 23

    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp

    pushl $string1
    call um_strlen
    addl $4, %esp
    cmpl $26, %eax
    je 1f
    movl $1, %eax
    jmp 2f

  1:
    pushl $string2
    call um_strlen
    addl $4, %esp
    cmpl $288, %eax
    je 1f
    movl $2, %eax
    jmp 2f

  1:
    pushl $string3
    call um_strlen
    addl $4, %esp
    cmpl $23, %eax
    je 1f
    movl $3, %eax
    jmp 2f

  1:
    movl $0, %eax

  2:
    leave
    ret
