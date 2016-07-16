/*
 * @file test.s
 * @description this program exists to test library code
 */

    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp        # -4(%ebp) = exit status
    andl $-16, %esp      # align stack

    movl $0, -4(%ebp)    # default exit status

    movl 4(%ebp), %eax   # load %eax with argc
    cmpl $2, %eax
    jl 1f

    pushl 12(%ebp)
    call um_strlen
    addl $4, %esp
    movl %eax, -4(%ebp)  # update exit status

  1:
    pushl -4(%ebp)
    call um_exit
    addl $4, %esp

    hlt                  # segmentation fault! :-)
