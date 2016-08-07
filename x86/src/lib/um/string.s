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


# char *um_itoa( int num, char *buf, int base );
um_itoa:

    pushl %ebp
    movl %esp, %ebp

    movl 16(%ebp), %eax
    cmpl $2, %eax
    jl 1f
    cmpl $36, %eax
    jle 2f
  1:
    movl $0, %eax
    jmp 3f

  2:
    movl 12(%ebp), %eax

  3:
    leave
    ret
