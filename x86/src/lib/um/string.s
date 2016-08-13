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

    # check value for base...
    movl 16(%ebp), %eax
    cmpl $2, %eax
    jl 1f # invalid base...
    cmpl $36, %eax
    jle 2f # valid base...
    # ... else, invalid base

  1:
    # invalid base...
    # ... terminate string and return -1
    movl 12(%ebp), %eax
    movb $0, (%eax)
    movl $-1, %eax
    jmp EXIT

  2:
    # valid base...
    # ... check if base is a power of 2
    bsfl %eax, %ecx
    bsrl %eax, %edx
    cmpl %ecx, %edx
    je POW2
    jne NON_POW2

  POW2:
    pushl %ebx
    movl 12(%ebp), %ebx
    movl 8(%ebp), %edx
    movb %cl, %ch
    decb %ch # bitmask ( bitindex - 1 )
    xorl %eax, %eax
  POW2_LOOP:
    movb %ch, %al
    andl %edx, %eax
    cmpb $10, %al
    jl 2f
    addb $'A', %al
    jmp 3f
  2:
    addb $'0', %al
  3:
    movb %al, (%ebx)
    incl %ebx
    cmpl $0, %edx
    je 2f
    shrl %cl, %edx
    jmp POW2_LOOP
  2:
    movb $0, (%ebx)


  NON_POW2:
    movl 12(%ebp), %eax
    movb $0, (%eax)
    movl $0, %eax

  EXIT:
    leave
    ret
