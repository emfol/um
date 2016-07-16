/*
 * @file crt.s
 * @description
 *     C Run Time
 *     This file implements the initial C run time code...
 */

    .text

    .globl start

start:

    pushl %ebp
    movl %esp, %ebp
    andl $-16, %esp               # align stack to page boundary

    # prepare to call main

    movl 4(%ebp), %ecx            # load %ecx with argc
    leal 12(%ebp, %ecx, 4), %eax  # load %eax with envp
    pushl %eax                    # save envp
    leal 8(%ebp), %eax            # load %eax with argv
    pushl %eax                    # save argv
    pushl %ecx                    # save argc
    call main
    addl $12, %esp

    # prepare to call exit

    pushl %eax
    call exit
    addl $4, %esp                 # this point should never be reached...
    hlt                           # ... and if it does, halt!
