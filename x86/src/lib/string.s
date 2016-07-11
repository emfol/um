/*
 * @file string.s
 * @description compilation of string utility functions for x86 plataform
 */

    .text

    .globl um_strlen
um_strlen:
    movl 4(%esp), %eax
    movl %eax, %ecx
  .Lum_strlen_loop:
    cmpb $0, (%eax)
    je .Lum_strlen_exit
    incl %eax
    jmp .Lum_strlen_loop
  .Lum_strlen_exit:
    subl %ecx, %eax
    ret

