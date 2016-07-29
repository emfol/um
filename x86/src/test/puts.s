/*
 * @file test/um_puts.s
 * @description test um_puts library function
 * @author Emanuel F. Oliveira
 */

    .globl main

    .data

string1:
    .asciz "abcdefghijklmnopqrstuvwxyz" # 26 + 1 = 27 (1)
string2:
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .byte 0 # 4 * 36 + 1 = 144 + 1 = 145 (2)
string3:
    .asciz "Hi!" # 3 + 1 = 4 (1)
string4:
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .ascii "abcdefghijklmnopqrstuvwxyz0123456789"
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    .byte 0 # 12 * 36 + 1 = 432 + 1 = 433 (4)

    .text

main:

    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp # reserve storage to save one copy of %ebx
    movl %ebx, -4(%ebp)

    # save %ebx (again)
    pushl %ebx

    # string1
    movl $0x12345678, %ebx
    pushl $string1
    call um_puts
    addl $4, %esp
    cmpl $27, %eax
    je 1f
    movl $1, %eax
    jmp 2f
  1:
    cmpl $1, %edx
    je 1f
    movl $2, %eax
    jmp 2f
  1:
    cmpl $0x12345678, %ebx
    je 1f
    movl $21, %eax
    jmp 2f

    # string2
  1:
    movl $0xffffffff, %ebx
    pushl $string2
    call um_puts
    addl $4, %esp
    cmpl $145, %eax
    je 1f
    movl $3, %eax
    jmp 2f
  1:
    cmpl $2, %edx
    je 1f
    movl $4, %eax
    jmp 2f
  1:
    cmpl $0xffffffff, %ebx
    je 1f
    movl $22, %eax
    jmp 2f

    # string3
  1:
    movl $0x87654321, %ebx
    pushl $string3
    call um_puts
    addl $4, %esp
    cmpl $4, %eax
    je 1f
    movl $5, %eax
    jmp 2f
  1:
    cmpl $1, %edx
    je 1f
    movl $6, %eax
    jmp 2f
  1:
    cmpl $0x87654321, %ebx
    je 1f
    movl $23, %eax
    jmp 2f

    # string4
  1:
    movl $0, %ebx
    pushl $string4
    call um_puts
    addl $4, %esp
    cmpl $433, %eax
    je 1f
    movl $7, %eax
    jmp 2f
  1:
    cmpl $4, %edx
    je 1f
    movl $8, %eax
    jmp 2f
  1:
    cmpl $0, %ebx
    je 1f
    movl $24, %eax
    jmp 2f

  1:
    popl %ebx
    cmpl -4(%ebp), %ebx
    je 1f
    movl $25, %eax
    jmp 2f

  1:
    movl $0, %eax

  2:
    leave
    ret

