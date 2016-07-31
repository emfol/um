/*
 * @file cpuinfo.s
 * @description This program simply display some information about the processor.
 * @author Emanuel F. Oliveira
 */

    .globl main

    .data

l_string_cpuidsupported:
    .string "This CPU supports the CPUID instruction!"
l_string_cpuidnotsupported:
    .string "This CPU does not support CPUID instruction..."

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
    subl $8, %esp # 2 dwords
    # -4(%ebp) = buffer address
    # -8(%ebp) = buffer limit
    # ~ buffer
    movl %esp, -8(%ebp)
    subl $256, %esp
    movl %esp, -4(%ebp)

    # save %ebx
    pushl %ebx

    call cpuid_supported     # %eax has the result
    cmpl $0, %eax
    jnz 1f

    # print error message and exit...
    pushl $l_string_cpuidnotsupported
    call um_puts
    addl $4, %esp
    movl $1, %eax # status code 1
    jmp 4f

  1:
    pushl $l_string_cpuidsupported
    call um_puts
    addl $4, %esp

    # get vendor string...
    movl $0, %eax
    cpuid
    movl -4(%ebp), %eax
    movl %ebx, (%eax)
    movl %edx, 4(%eax)
    movl %ecx, 8(%eax)
    movl $0, 12(%eax)
    # ... and print it!
    pushl %eax
    call um_puts
    addl $4, %esp

    # exit with success!
    movl $0, %eax # status code 0 (success!)

  4:

    # restore %ebx
    popl %ebx

    leave
    ret
