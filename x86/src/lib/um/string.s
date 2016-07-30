/*
 * @file string.s
 * @description compilation of string utility functions for x86 plataform
 */

    .text

    .globl um_strlen
um_strlen:
    movl 4(%esp), %eax
    movl %eax, %ecx
  1:
    cmpb $0, (%eax)
    je 2f
    incl %eax
    jmp 1b
  2:
    subl %ecx, %eax
    ret

