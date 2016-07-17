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

    .lcomm .L_buffer, 4096

    .text

    .globl main
main:
    pushl %ebp
    movl %esp, %ebp
    subl $12, %esp           # -4(%ebp)  = return value
                             # -8(%ebp)  = case mode
                             # -12(%ebp) = temporary storage

    movl 8(%ebp), %eax
    cmpl $2, %eax
    je .L_main_default


    # print usage...


    pushl $.L_usage
    call um_strlen
    addl $4, %esp
    movl %eax, -12(%ebp)
    pushl %eax
    pushl $.L_usage
    pushl $1                 # STDOUT = 1
    call write
    addl $12, %esp
    cmpl -12(%ebp), %eax
    jne 1f
    movl $0, -4(%ebp)
    jmp .L_main_leave
  1:
    cmpl $0, %eax
    jl 1f
    movl $255, -4(%ebp)
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

  .L_main_leave:
    movl -4(%ebp), %eax
    leave
    ret

.L_to_lower:
.L_to_upper:
    nop
