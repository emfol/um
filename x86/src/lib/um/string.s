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
    movb (%ecx), %al
    movb (%edx), %ah
    subb %ah, %al
    jne 2f
    cmpb $0, %ah
    je 2f
    incl %ecx
    incl %edx
    jmp 1b
  2:
    movsx %al, %eax

    leave
    ret


# int um_itoa( int num, char *buf, int base );
um_itoa:
    pushl %ebp
    movl %esp, %ebp

    movl 16(%ebp), %eax
    cmpl $2, %eax
    jl 1f
    cmpl $36, %eax
    jle 2f
  1:
    movl $0, %eax
    jmp 3f

  2:
    movl $0, %eax
    movl 12(%ebp), %ecx
    movb %al, (%ecx)

  3:
    leave
    ret
