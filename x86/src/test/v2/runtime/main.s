/*
 * @file main.s
 * @description
 *     This program is part of every test suite. It is reponsible for making sure
 *     that values on stack and special registers have not been compromised after
 *     test execution.
 */


    .equ CONST_EBX, 0xBA987654
    .equ CONST_ESI, 0x76543210
    .equ CONST_EDI, 0xFEDCBA98

    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp
    subl $28, %esp # 7 dwords (6 register copies + 1 result)

    movl $0, %eax
    movl %eax, -4(%ebp)
    movl %ebx, -8(%ebp)
    movl %esi, -12(%ebp)
    movl %edi, -16(%ebp)
    movl $CONST_EBX, %ebx
    movl %ebx, -20(%ebp)
    movl $CONST_ESI, %esi
    movl %esi, -24(%ebp)
    movl $CONST_EDI, %edi
    movl %edi, -28(%ebp)

    # push sequence onto stack
    movl $8, %ecx
  1:
    pushl %ecx
    loop 1b

    # call test suite
    call test
    andl $0x7F, %eax # only the seven least significant bits are considered
    movl %eax, -4(%ebp)

    # check sequence on stack
    movl $8, %ecx
  1:
    cmpl -4(%esp, %ecx, 4), %ecx
    jne 2f
    loop 1b

    # check if %ebx, %esi and %edi have been preserved...
    cmpl $CONST_EBX, %ebx
    jne 2f
    cmpl $CONST_ESI, %esi
    jne 2f
    cmpl $CONST_EDI, %edi
    jne 2f
    cmpl -20(%ebp), %ebx
    jne 2f
    cmpl -24(%ebp), %esi
    jne 2f
    cmpl -28(%ebp), %edi
    jne 2f

    jmp 3f
  2:
    orl $128, -4(%ebp)
  3:
    movl -4(%ebp), %eax

    leave
    ret
