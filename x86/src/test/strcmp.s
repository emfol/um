/*
 * @file strlen.s
 * @description this program tests the um_strcmp library function.
 */

    .data

str_a:
    .asciz "a"
str_b:
    .asciz "b"
str_aa:
    .asciz "aa"
str_ab:
    .asciz "ab"


    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp

    # um_strcmp( "a", "b" );
    pushl $str_b
    pushl $str_a
    call um_strcmp
    addl $8, %esp
    cmpl $-1, %eax
    je 1f
    movl $1, %eax
    jmp 2f

    # um_strcmp( "a", "aa" );
  1:
    pushl $str_aa
    pushl $str_a
    call um_strcmp
    addl $8, %esp
    cmpl $-97, %eax
    je 1f
    movl $2, %eax
    jmp 2f

    # um_strcmp( "a", "ab" );
  1:
    pushl $str_ab
    pushl $str_a
    call um_strcmp
    addl $8, %esp
    cmpl $-98, %eax
    je 1f
    movl $3, %eax
    jmp 2f

    # um_strcmp( "b", "a" );
  1:
    pushl $str_a
    pushl $str_b
    call um_strcmp
    addl $8, %esp
    cmpl $1, %eax
    je 1f
    movl $4, %eax
    jmp 2f

    # um_strcmp( "b", "aa" );
  1:
    pushl $str_aa
    pushl $str_b
    call um_strcmp
    addl $8, %esp
    cmpl $1, %eax
    je 1f
    movl $5, %eax
    jmp 2f

    # um_strcmp( "b", "ab" );
  1:
    pushl $str_ab
    pushl $str_b
    call um_strcmp
    addl $8, %esp
    cmpl $1, %eax
    je 1f
    movl $6, %eax
    jmp 2f

    # um_strcmp( "aa", "aa" );
  1:
    pushl $str_aa
    pushl $str_aa
    call um_strcmp
    addl $8, %esp
    cmpl $0, %eax
    je 1f
    movl $7, %eax
    jmp 2f

    # um_strcmp( "ab", "ab" );
  1:
    pushl $str_ab
    pushl $str_ab
    call um_strcmp
    addl $8, %esp
    cmpl $0, %eax
    je 1f
    movl $8, %eax
    jmp 2f

    # um_strcmp( "aa", "ab" );
  1:
    pushl $str_ab
    pushl $str_aa
    call um_strcmp
    addl $8, %esp
    cmpl $-1, %eax
    je 1f
    movl $9, %eax
    jmp 2f

    # um_strcmp( "ab", "aa" );
  1:
    pushl $str_aa
    pushl $str_ab
    call um_strcmp
    addl $8, %esp
    cmpl $1, %eax
    je 1f
    movl $10, %eax
    jmp 2f

  1:
    movl $0, %eax

  2:
    leave
    ret
