/* @file linux.s
 * @description this is a library to implement linux system calls
 */

    .text

    .globl um_exit
um_exit:
    movl 4(%esp), %ebx
    movl $1, %eax
    int $0x80
    ret                 # should never be exected...
