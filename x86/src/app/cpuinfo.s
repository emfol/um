/*
 * @file cpuinfo.s
 * @description This program simply display some information about the processor.
 * @author Emanuel F. Oliveira
 */

    .globl main

    .data

l_string_cpuidnotsupported:
    .string "This CPU does not support CPUID instruction...\n"

    .text

# This function returns 1 if CPU supports CPUID instruction and 0 otherwise...
cpuid_supported:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    pushfl
    pushfl
    xorl $0x200000, (%esp)   # invert bit 21
    popfl
    pushfl
    popl %eax
    xorl (%esp), %eax
    movl %eax, -4(%ebp)
    popfl
    movl -4(%ebp), %eax
    andl $0x200000, %eax
    jz 1f
    movl $1, %eax
  1:
    leave
    ret

main:
    pushl %ebp
    movl %esp, %ebp
    subl $128, %esp          # reserve 16 dwords

    call cpuid_supported     # %eax has the result
    cmpl $0, %eax
    jnz 1f
  1:

    leave
    ret
