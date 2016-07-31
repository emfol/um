/*
 * @file test.s
 * @description this program exists to test library code
 */

    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax   # load %eax with argc
    cmpl $2, %eax
    jl 1f

    # prepare to call um_strlen

    movl 12(%ebp), %eax
    pushl 4(%eax)
    call um_strlen
    addl $4, %esp
    jmp 2f

  1:
    movl $0, %eax
  2:
    leave
    ret
