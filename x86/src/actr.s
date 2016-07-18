/*
 * @file actr.s
 * @description
 *     Ascii Case TRansform Utility
 *     Based on first command line argument, transforms case
 *     of each character from STDIN and saves to STDOUT...
 */

    .data

.L_usage:
    .string "Usage:\n    actr [UuLs] < input.txt > output.txt\n"

    .bss

    .equ BUFSZ, 4096
    .lcomm .L_buffer, BUFSZ

    .text

    .globl main
main:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp            # -4(%ebp) = case mode (0 = L, 1 = U)
                             # -8(%ebp) = read count

    movl 8(%ebp), %eax
    cmpl $2, %eax
    jge .L_main_default


    # print usage message...

  .L_main_print_usage:
    pushl $.L_usage
    call um_strlen
    addl $4, %esp
    pushl %eax
    pushl $.L_usage
    pushl $1                 # STDOUT = 1
    call um_fwrite
    addl $12, %esp
    cmpl $0, %eax
    jl 1f
    movl $0, %eax            # 0 = success...
    jmp .L_main_leave
  1:
    movl errno, %eax
    jmp .L_main_leave


    # default flow...


  .L_main_default:
    movl 12(%ebp), %eax
    movl 4(%eax), %eax
    movb (%eax), %al
    orb $0x20, %al
    cmpb $'l', %al
    jne 1f
    movl $0, -4(%ebp)
    jmp .L_main_read_loop
  1:
    cmpb $'u', %al
    jne .L_main_print_usage
    movl $1, -4(%ebp)

  .L_main_read_loop:
    # read from STDIN
    pushl $BUFSZ
    pushl $.L_buffer
    pushl $0                 # STDIN = 0
    call um_fread
    addl $12, %esp
    cmpl $0, %eax
    jg 2f
    jl 1f
    # %eax == 0 (EOF!)
    # ...also 0 in %eax means: success!
    jmp .L_main_leave

  1:
    # %eax < 0 (Error!)
    movl errno, %eax
    jmp .L_main_leave

  2:
    # %eax > 0 (Work!)
    movl %eax, -8(%ebp)     # save amount of bytes read...

    # convert to upper/lower case
    pushl %eax
    pushl $.L_buffer
    pushl -4(%ebp)           # selected case mode...
    call .L_convert_case
    addl $12, %esp

    # write to STDOUT
    pushl -8(%ebp)
    pushl $.L_buffer
    pushl $1                 # STDOUT = 1
    call um_fwrite
    addl $12, %esp
    cmpl $0, %eax
    jge .L_main_read_loop
    # %eax < 0
    movl errno, %eax

  .L_main_leave:
    leave
    ret


.L_convert_case:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl $0, %ecx            # initial index
    movl 16(%ebp), %edx      # limit
    movl 12(%ebp), %ebx      # base address
    movb $0x20, %ah          # ASCII mask

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
