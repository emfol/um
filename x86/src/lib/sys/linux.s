/* @file linux.s
 * @description this is a library to implement linux system calls
 */

    .text

    .globl exit
exit:
    movl 4(%esp), %ebx
    movl $1, %eax
    int $0x80
    ret                 # this point should never be reached...
