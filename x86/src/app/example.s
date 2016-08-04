/*
 * @file example.s
 * @description This file is an example of how to use bytes instead of assembly code...
 */

    .globl main

    .text

main:

    pushl %ebp
    movl %esp, %ebp

    # load %eax with %eip
    .byte 0xE8, 0x00, 0x00, 0x00, 0x00
    .byte 0x58 # %eax has the address of this instruction...

    # load %ecx with %eip
    call 1f
  1:
    popl %ecx # %ecx has the address of this instruction...

    # these bytes will produce the same code below...
    .byte 0xB8, 0x00, 0x00, 0x00, 0x80
    .byte 0x0F, 0xA2

    movl $0x80000000, %eax
    cpuid

    # return error code 127
    movl $127, %eax

    leave
    ret
