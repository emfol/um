/* @file unix.s
 * @description this is a library to implement standard unix system calls
 */

    .text

    .globl exit
exit:
    movl $1, %eax
    int $0x80
    ret                 # this point should never be reached...
