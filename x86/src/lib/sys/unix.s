/* @file unix.s
 * @description this is a library to implement standard unix system calls
 */


    .globl errno
    .globl exit
    .globl read
    .globl write

    .globl EINTR
    .globl EAGAIN

    .equ EINTR, 4
    .equ EAGAIN, 35

    .data

errno:
    .long 0

    .text

trap:
    int $0x80
    jnc 1f
    clc
    movl %eax, errno
    movl $-1, %eax
  1:
    ret

exit:
    movl $1, %eax
    jmp trap

read:
    movl $3, %eax
    jmp trap

write:
    movl $4, %eax
    jmp trap

