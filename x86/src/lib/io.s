/*
 * @file io.s
 * @description Commonly used I/O funtions...
 */

    .globl um_fread
    .globl um_fwrite
    .globl um_puts

    .text

# int um_fread( int fd, void *buffer, int size);
um_fread:

    pushl %ebp
    movl %esp, %ebp

    # simply calls read...
    pushl 16(%ebp)
    pushl 12(%ebp)
    pushl 8(%ebp)
    call read
    addl $12, %esp

    leave
    ret

# int um_fwrite( int fd, void *buffer, int size );
um_fwrite:

    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp # 2 dwords
    # buffer address -4(%ebp)
    # buffer size    -8(%ebp)

    # initialization
    movl 16(%ebp), %eax
    movl %eax, -8(%ebp)
    movl 12(%ebp), %eax
    movl %eax, -4(%ebp)

  1:
    pushl -8(%ebp)
    pushl -4(%ebp)
    pushl 8(%ebp) # file descriptor...
    call write
    addl $12, %esp
    cmpl $0, %eax
    jl 2f

    # %eax >= 0
    movl -8(%ebp), %ecx # load amount of bytes that SHOULD be written...
    subl %eax, %ecx # subtract the amount of bytes that were ACTUALLY written...
    jle 2f
    movl %ecx, -8(%ebp)
    addl %eax, -4(%ebp)
    jmp 1b

  2:
    leave
    ret

# int um_puts( char *buffer );
um_puts:

    pushl %ebp
    movl %esp, %ebp

    subl $24, %esp # 6 dwords
    # buffer base   -4(%ebp)  { %edx }
    # buffer limit  -8(%ebp)  { %ebx }
    # source base   -12(%ebp) { %ecx }
    # context       -16(%ebp) { %al: char_read, %ah: end_of_input }
    # bytes written -20(%ebp)
    # flush count   -24(%ebp)
    # [ alloc space for buffer ]
    movl %esp, -8(%ebp) # buffer limit
    subl $128, %esp     # 32 dwords (keep the stack dword aligned)
    movl %esp, -4(%ebp) # buffer base

    # save registers as per C calling convetion
    pushl %ebx

    # initialization
    movl 8(%ebp), %ecx  # save source buffer address (first and only argument)
    movl %ecx, -12(%ebp)
    movl -4(%ebp), %edx
    movl -8(%ebp), %ebx
    movl $0, %eax
    movl %eax, -16(%ebp) # 0
    movl %eax, -20(%ebp) # 0
    movl %eax, -24(%ebp) # 0

  1:
    cmpl %edx, %ebx
    jbe 3f
    # %ebx > %edx
    movb (%ecx), %al
    incl %ecx
    cmpb $0, %al
    jne 2f
    movb $'\n', %al
    movb $1, %ah
  2:
    movb %al, (%edx)
    incl %edx
    cmpb $1, %ah
    jne 1b

  3:
    # %ebx <= %edx
    # save registers which need to be preserved
    movl %ecx, -12(%ebp)
    movl %eax, -16(%ebp)
    # call um_fwrite
    subl -4(%ebp), %edx # amount of bytes in buffer ( should never be zero )
    pushl %edx
    pushl -4(%ebp)
    pushl $1
    call um_fwrite
    addl $12, %esp
    cmpl $0, %eax
    jl 5f # abort...
    # update amount of bytes written and flush count
    addl %eax, -20(%ebp)
    incl -24(%ebp)
    # restore context and check for end of input
    movl -16(%ebp), %eax
    cmpb $1, %ah
    je 4f
    # restore input and output pointers
    movl -12(%ebp), %ecx
    movl -4(%ebp), %edx
    movl -8(%ebp), %ebx
    jmp 1b

  4:
    # end of input
    movl -20(%ebp), %eax
    movl -24(%ebp), %edx

  5:
    # clean up
    popl %ebx
    leave
    ret

