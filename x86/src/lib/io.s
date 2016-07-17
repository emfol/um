/*
 * @file io.s
 * @description Commonly used I/O funtions...
 */

    .globl um_fread
    .globl um_fwrite

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
    pushl 8(%ebp)
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
