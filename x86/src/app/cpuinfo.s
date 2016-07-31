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
# int is_cpuid_supported( void );
is_cpuid_supported:
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


# int get_cpuid_vendor( char *buf, int size );
get_cpuid_vendor:

    pushl %ebp
    movl %esp, %ebp

    # save %ebx
    pushl %ebx

    movl 12(%ebp), %ecx
    cmpl $16, %ecx
    jge 1f

    # %ecx < 16
    movl $0, %eax
    jmp 2f

  1:
    # execute cpuid...
    movl $0, %eax
    cpuid
    movl 8(%ebp), %eax
    movl %ebx, (%eax)
    movl %edx, 4(%eax)
    movl %ecx, 8(%eax)
    movl $0, 12(%eax)

    # success return value
    movl $1, %eax

  2:
    # restore %ebx
    popl %ebx

    leave
    ret


# int get_cpuid_brand( char *buf, int size );
get_cpuid_brand:

    pushl %ebp
    movl %esp, %ebp
    subl $12, %esp # 3 dwords
    # -4(%ebp)  = max cpuid
    # -8(%ebp)  = last cpuid
    # -12(%ebp) = last buffer address

    # preserve registers
    pushl %ebx
    pushl %edi

    movl 12(%ebp), %ecx
    cmpl $52, %ecx
    jge 1f

    # %ecx < 52
    movl $1, %edx
    movl $0, %eax
    jmp 3f

  1:
    movl $0x80000000, %eax
    cpuid
    cmpl $0x80000000, %eax
    ja 1f

    # extended cpuid not supported...
    movl $2, %edx
    movl $0, %eax
    jmp 3f

  1:
    # prepare for cpuid loop
    movl 8(%ebp), %eax # save copy of first argument
    movl %eax, -12(%ebp)
    movl $0x80000004, %eax # load %eax with max cpuid code
    movl %eax, -4(%ebp) # ... and store it
    subl $2, %eax # get first cpuid code
    movl %eax, -8(%ebp) # ... and store it

  2:
    # execute cpuid...
    cpuid # we assume %eax already has the correct value...
    movl -12(%ebp), %edi
    movl %eax, (%edi)
    movl %ebx, 4(%edi)
    movl %ecx, 8(%edi)
    movl %edx, 12(%edi)
    addl $16, %edi
    movl %edi, -12(%ebp)
    movl -8(%ebp), %eax
    incl %eax
    movl %eax, -8(%ebp)
    cmpl -4(%ebp), %eax
    jbe 2b
    movl $0, (%edi)

    # success return value
    movl $0, %edx
    movl $1, %eax

  3:
    # restore registers
    popl %edi
    popl %ebx

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

    call is_cpuid_supported # %eax has the result
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
    movl -4(%ebp), %eax
    movl -8(%ebp), %ecx
    subl %eax, %ecx
    pushl %ecx
    pushl %eax
    call get_cpuid_vendor
    addl $8, %esp
    cmpl $0, %eax
    jne 1f

    # %eax = 0 (Error!)
    movl $2, %eax
    jmp 4f

  1:
    # ... and print it!
    pushl -4(%ebp)
    call um_puts
    addl $4, %esp

    # get brand string...
    movl -4(%ebp), %eax
    movl -8(%ebp), %ecx
    subl %eax, %ecx
    pushl %ecx
    pushl %eax
    call get_cpuid_brand
    addl $8, %esp
    cmpl $0, %eax
    jne 1f

    # %eax = 0 (Error!)
    movl %edx, %eax
    addl $30, %eax
    jmp 4f

  1:
    # ... and print it!
    pushl -4(%ebp)
    call um_puts
    addl $4, %esp

    # exit with success!
    movl $0, %eax # status code 0 (success!)

  4:
    # restore %ebx
    popl %ebx

    leave
    ret
