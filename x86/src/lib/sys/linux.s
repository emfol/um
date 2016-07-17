/* @file linux.s
 * @description this is a library to implement linux system calls
 */

    .globl errno
    .globl exit
    .globl write
    .globl read

    .data
errno:
    .long 0

    .text
exit:
    movl 4(%esp), %ebx
    movl $1, %eax            # sys_exit = 1
    int $0x80
    ret                      # this point should never be reached...

write:
    movl $4, %eax            # sys_write = 4
    jmp 1f
read:
    movl $3, %eax            # sys_read = 3
  1:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx               # %ebx should always be preserved...
    movl 8(%ebp), %ebx
    movl 12(%ebp), %ecx
    movl 16(%ebp), %edx
    int $0x80
    cmpl $0, %eax
    jge 2f
    negl %eax
    movl %eax, errno
    movl $-1, %eax
  2:
    popl %ebx
    leave
    ret
