/*
 * @file actr.s
 * @description
 *     Ascii Case TRansform Utility
 *     Based on first command line argument, transforms case
 *     of each character from STDIN and saves to STDOUT...
 */

    .data

l_string_usage:
    .asciz "Usage:\n    actr [UuLs] < input.txt > output.txt\n"

    .bss

    .equ l_bufsz, 1024
    .lcomm l_buf, l_bufsz

    .text

    .globl main
main:

    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp # 4 dwords
    # -4(%ebp)  = case mode (0 = L, 1 = U)
    # -8(%ebp)  = read count
    # -12(%ebp) = EINTR
    # -16(%ebp) = EAGAIN

    # this reduces reference count...
    movl $EINTR, -12(%ebp)
    movl $EAGAIN, -16(%ebp)

    # check amount of arguments passed to the program...
    movl 8(%ebp), %eax
    cmpl $2, %eax
    jge 1f

    # argc < 2
    call l_print_usage
    movl $128, %eax
    jmp 4f

  1:
    # argc >= 2
    movl 12(%ebp), %eax
    movl 4(%eax), %eax
    movb (%eax), %al
    orb $0x20, %al
    cmpb $'l', %al
    jne 1f
    movl $0, -4(%ebp)
    jmp 2f
  1:
    cmpb $'u', %al
    je 1f
    call l_print_usage
    movl $129, %eax
    jmp 4f
  1:
    movl $1, -4(%ebp)

  2:
    # read loop
    pushl $l_bufsz
    pushl $l_buf
    pushl $0 # STDIN = 0
    call um_fread
    addl $12, %esp
    cmpl $0, %eax
    jg 3f
    jl 1f
    # %eax == 0 (EOF!)
    # ... also, 0 in %eax means success!
    jmp 4f

  1:
    # %eax < 0 (Error!)
    movl errno, %eax
    # check for EINTR
    cmpl -12(%ebp), %eax
    je 2b
    # check for EAGAIN
    cmpl -16(%ebp), %eax
    je 2b
    jmp 4f

  3:
    # %eax > 0 (Work!)
    movl %eax, -8(%ebp) # save amount of bytes read...

    # convert to upper/lower case
    pushl %eax
    pushl $l_buf
    pushl -4(%ebp) # selected case mode...
    call l_convert_case
    addl $12, %esp

  1:
    # write to STDOUT
    pushl -8(%ebp)
    pushl $l_buf
    pushl $1 # STDOUT = 1
    call um_fwrite
    addl $12, %esp
    cmpl $0, %eax
    jge 2b

    # %eax < 0 (Error!)
    movl errno, %eax
    # check for EINTR
    cmpl -12(%ebp), %eax
    je 1b
    # check for EAGAIN
    cmpl -16(%ebp), %eax
    je 1b

  4:
    leave
    ret


l_print_usage:

    pushl %ebp
    movl %esp, %ebp

    pushl $l_string_usage
    call um_puts
    addl $4, %esp

    leave
    ret


l_convert_case:

    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl $0, %ecx       # initial index
    movl 16(%ebp), %edx # limit
    movl 12(%ebp), %ebx # base address
    movb $0x20, %ah     # ASCII mask

    cmpl $0, 8(%ebp)
    jz 3f

    # to upper...
    notb %ah
  1:
    cmpl %ecx, %edx
    jle 5f
    movb (%ebx,%ecx,1), %al
    cmpb $'a', %al
    jl 2f
    cmpb $'z', %al
    jg 2f
    andb %ah, %al
    movb %al, (%ebx,%ecx,1)
  2:
    incl %ecx
    jmp 1b

  3:
    # to lower...
    cmpl %ecx, %edx
    jle 5f
    movb (%ebx,%ecx,1), %al
    cmpb $'A', %al
    jl 4f
    cmpb $'Z', %al
    jg 4f
    orb %ah, %al
    movb %al, (%ebx,%ecx,1)
  4:
    incl %ecx
    jmp 3b

  5:
    movl %ecx, %eax
    popl %ebx
    leave
    ret
