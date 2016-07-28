/*
 * @file io.s
 * @description Commonly used I/O funtions...
 */

    .globl um_fread
    .globl um_fwrite
    .globl um_puts

    .bss

    .equ l_um_puts_bufsz, 256
    .lcomm l_um_puts_buf, l_um_puts_bufsz

    .text

um_fread:
    pushl %ebp
    movl %esp, %ebp
  1:
    pushl 16(%ebp)
    pushl 12(%ebp)
    pushl 8(%ebp)
    call read
    addl $12, %esp
    cmpl $0, %eax
    jge 2f
    movl errno, %ecx
    cmpl $EINTR, %ecx
    je 1b
    cmpl $EAGAIN, %ecx
    je 1b
  2:
    leave
    ret


um_fwrite:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    movl 16(%ebp), %eax
    movl %eax, -4(%ebp)      # -4(%ebp) = buffer size
    movl 12(%ebp), %eax
    movl %eax, -8(%ebp)      # -8(%ebp) = buffer address

  1:
    pushl -4(%ebp)
    pushl -8(%ebp)
    pushl 8(%ebp)            # file descriptor...
    call write
    addl $12, %esp
    cmpl $0, %eax
    jge 2f

    # %eax < 0
    movl errno, %ecx
    cmpl $EINTR, %ecx
    je 1b
    cmpl $EAGAIN, %ecx
    je 1b
    jmp 3f

  2:
    # %eax >= 0
    movl -4(%ebp), %ecx      # load amount of bytes that SHOULD be written...
    subl %eax, %ecx
    jle 3f
    movl %ecx, -4(%ebp)
    addl %eax, -8(%ebp)
    jmp 1b

  3:
    leave
    ret


um_puts:

    pushl %ebp
    movl %esp, %ebp
    subl $20, %esp # 5 dwords
    ## alloc space for locals
    # buffer_base   -4(%ebp)  { %edx }
    # buffer_limit  -8(%ebp)  { %ebx }
    # source_base   -12(%ebp) { %ecx }
    # context       -16(%ebp) { %al: char_read, %ah: end_of_input }
    # flush_count   -20(%ebp)
    ## alloc space for buffer
    movl %esp, -8(%ebp) # buffer_limit
    subl $256, %esp     # 64 dwords (keep the stack dword aligned)
    movl %esp, -4(%ebp) # buffer_base
    # save registers as per C calling convetion
    pushl %ebx

    # initialization
    movl 8(%ebp), %ecx # save source buffer address (first argument)
    movl %ecx, -12(%ebp)
    movl -4(%ebp), %edx
    movl -8(%ebp), %ebx
    movl $0, %eax
    movl %eax, -16(%ebp)
    movl %eax, -20(%ebp)

  1:
    cmpl %edx, %ebx
    jbe 3f # flush
    movb (%ecx), %al
    incl %ecx
    cmpb $0, %al
    jne 2f
    movb $'\n', %al
    movb $1, %ah
  2:
    movb %al, (%edx)
    incl %edx
    cmpb $0, %ah
    je 1b
  3: # flush
    # save registers
    movl %ecx, -12(%ebp)
    movl %edx, -16(%ebp)
    movl %ebx, -20(%ebp)
    movl %eax, -24(%eax)
    # call um_fwrite
    subl -4(%ebp), %edx      # subtract base address to get byte count
    jz EXIT                  # playing safe...
    pushl %edx
    pushl -4(%ebp)
    pushl $1
    call um_fwrite
    addl $12, %esp
    cmpl $0, %eax
    jl EXIT
    movl -12(%ebp), %ecx

do {
    while ( addr_dst <= addr_dst_last ) {
        char_read = *addr_src;
        if ( char_read == 0 ) {
            end_of_input = 1;
            char_read = '\n';
        }
        *addr_dst = char_read;
        if ( end_of_input == 1 )
            break;
        addr_src++;
        addr_dst++;
    }
    flush();
} while ( end_of_input == 0 );


    # clean up
    popl %ebx
    leave
    ret

