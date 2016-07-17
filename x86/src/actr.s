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
    subl $20, %esp           # -4(%ebp)  = return value
                             # -8(%ebp)  = case mode
                             # -12(%ebp) = temporary storage
                             # -16(%ebp) = read count
                             # -20(%ebp) = write count

    movl 8(%ebp), %eax
    cmpl $2, %eax
    je .L_main_default


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
    movl $0, -4(%ebp)        # 0 = success...
    jmp .L_main_leave
  1:
    movl errno, %eax
    movl %eax, -4(%ebp)
    jmp .L_main_leave


    # default flow...


  .L_main_default:
    movl 12(%ebp), %eax
    movl 4(%eax), %eax
    movb (%eax), %al
    orb $0x20, %al
    cmpb $'l', %al
    jne 1f
    movl $0, -8(%ebp)
    jmp .L_main_read_loop
  1:
    cmpb $'u', %al
    jne .L_main_print_usage
    movl $1, -8(%ebp)

  .L_main_read_loop:
    # read from STDIN
    pushl $BUFSZ
    pushl $.L_buffer
    pushl $0                 # STDIN = 0
    call um_fread
    addl $12, %esp
    cmpl $0, $eax
    jg 2f
    jl 1f
    # %eax == 0 (EOF!)
    movl $0, -4(%ebp)        # 0 = success...
    jmp .L_main_leave

  1:
    # %eax < 0 (Error!)
    movl errno, %eax
    movl %eax, -4(%ebp)
    jmp .L_main_leave

  2:
    # %eax > 0 (Work!)
    movl %eax, -16(%ebp)     # save amount of bytes read...

    # convert to upper/lower case
    pushl %eax
    pushl $.L_buffer
    pushl -8(%ebp)
    call .L_convert_case
    addl $12, %esp

    # write to STDOUT
    pushl -16(%ebp)
    pushl $.L_buffer
    pushl $1                 # STDOUT = 1
    call um_fwrite
    addl $12, %esp
    cmpl -16(%ebp), %eax
    je .L_main_read_loop
    cmpl $0, %eax
    jge .L_main_write_loop

  .L_main_write_loop:
    movl -16(%ebp), %ecx
    subl %eax, %ecx

  .L_main_leave:
    movl -4(%ebp), %eax
    leave
    ret


.L_convert_case:
    nop
