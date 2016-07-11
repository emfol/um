/*
 * @file test.s
 * @description this program exists to test library code
 */

    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp

    movl $0, %ebx # default exit status
    movl 4(%ebp), %eax
    cmpl $2, %eax
    jl .Lmain_exit

    pushl 12(%ebp)
    call um_strlen
    addl $4, %esp
    movl %eax, %ebx

  .Lmain_exit:
    movl $1, %eax
    int $0x80
