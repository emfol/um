/*
 * @file dummy.s
 * @description This test simply returns 0 to assert runtime lib is working properly.
 */

    .globl test

    .text

test:
    pushl %ebp
    movl %esp, %ebp
    movl $0, %eax
    leave
    ret
