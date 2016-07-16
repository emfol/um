/* @file unix.s
 * @description this is a library to implement standard unix system calls
 */

    .text

    .globl um_exit
um_exit:
    movl $1, %eax
    int $0x80
    ret                 # should never be exected...
