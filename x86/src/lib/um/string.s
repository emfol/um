/*
 * @file string.s
 * @description compilation of string utility functions for x86 plataform
 */

    .globl um_strlen
    .globl um_strcmp
    .globl um_itoa

    .text

# unsigned int um_strlen( const char *buf );
um_strlen:
    movl 4(%esp), %eax
    movl %eax, %ecx
  1:
    cmpb $0, (%eax)
    je 2f
    incl %eax
    jmp 1b
  2:
    subl %ecx, %eax
    ret


# int um_strcmp( const char *a, const char *b );
um_strcmp:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %ecx
    movl 12(%ebp), %edx
  1:
    movb (%ecx), %ah
    movb (%edx), %al
    subb %al, %ah
    jne 2f
    cmpb $0, %al
    je 2f
    incl %ecx
    incl %edx
    jmp 1b
  2:
    movzbl %ah, %eax
    jnc 3f
    subl $0x100, %eax

  3:
    leave
    ret


# int um_itoa( int num, char *buf, int base );
um_itoa:
    pushl %ebp
    movl %esp, %ebp

    # check supplied base...
    movl 16(%ebp), %eax
    cmpl $2, %eax
    jl 1f # invalid base...
    cmpl $36, %eax
    jle 2f # valid base...

  1:
    # invalid base...
    # ... terminate string and return -1
    movl 12(%ebp), %eax
    movb $0, (%eax)
    movl $-1, %eax
    jmp 7f

  2:
    # valid base...
    # ... preserve registers and initialize buffer pointers
    pushl %ebx
    pushl %esi
    pushl %edi
    movl 12(%ebp), %ebx
    movl %ebx, %esi
    movl %ebx, %edi

    # ... check if base is a power of 2
    bsfl %eax, %ecx
    bsrl %eax, %edx
    cmpl %ecx, %edx
    movl 8(%ebp), %edx
    jne 4f

    # algorithm for powers of 2
    movb %al, %ch
    decb %ch # mask = base - 1
  3:
    movb %ch, %al
    andl %edx, %eax
    cmpb $10, %al
    jl 2f
    addb $7, %al
  2:
    addb $48, %al
    movb %al, (%ebx)
    incl %ebx
    shrl %cl, %edx
    jnz 3b
  2:
    movb $0, (%ebx)
    leal -1(%ebx), %edi
    jmp 6f

  4:
    # algorithm for non powers of 2
    cmpl $10, %eax
    jne 2f
    # if base 10, add minus sign for negative numbers...
    test %edx, %edx
    jns 2f
    # ... number is negative
    negl %edx
    movb $'-', (%ebx)
    incl %ebx
    movl %ebx, %esi
  2:
    movl %eax, %ecx # copy base to %ecx
    movl %edx, %eax # copy number to %eax
  5:
    # divide loop
    cdq
    divl %ecx
    xchgl %edx, %eax
    cmpb $10, %al
    jl 2f
    addb $7, %al
  2:
    addb $48, %al
    movb %al, (%ebx)
    incl %ebx
    cmpl $0, %edx
    je 2f
    xchgl %edx, %eax
    jmp 5b
  2:
    movb $0, (%ebx)
    leal -1(%ebx), %edi

  6:
    # reverse loop
    cmpl %esi, %edi
    jbe 2f
    movb (%esi), %al
    movb (%edi), %ah
    movb %al, (%edi)
    movb %ah, (%esi)
    incl %esi
    decl %edi
    jmp 6b
  2:
    # calculate return value (amount of digits written)
    subl 12(%ebp), %ebx
    movl %ebx, %eax
    # restore saved registers
    popl %edi
    popl %esi
    popl %ebx

  7:
    leave
    ret
