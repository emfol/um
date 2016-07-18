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
    subl $8, %esp            # -4(%ebp) = case mode
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
    nop
    ret
