/*
 * @file strlen.s
 * @description this program tests the um_strlen library function.
 */

    .data

# Test Data

str_1:
    .ascii "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
str_1z:
    .byte 0

str_2:
    .ascii "Sed euismod consectetur purus ut sodales. Phasellus vitae lobortis lacus."
str_2z:
    .byte 0

str_3:
    .ascii "Aliquam vel lacus in metus molestie tristique id ac felis.\n"
    .ascii "    ... Etiam aliquam rutrum tincidunt.\n"
    .ascii "    ... Donec hendrerit at finibus nibh, pulvinar laoreet augue."
str_3z:
    .byte 0

str_4:
str_4z:
    .byte 0

str_5:
    .ascii "Fibonacci..."
str_5z:
    .byte 0

.balign 16, 0

test_array:

    # struct test {
    #   int flag; # (base + 0) if flag == -1 then valid structure
    #   char *string; # (base + 4)
    #   unsigned long length; # (base + 8)
    # }

    .long -1, str_1, str_1z - str_1
    .long -1, str_2, str_2z - str_2
    .long -1, str_3, str_3z - str_3
    .long -1, str_4, str_4z - str_4
    .long -1, str_5, str_5z - str_5

    # end marker
    .long 0


    .text

    .globl test
test:

    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp # 4 dwords for locals

    # -4(%ebp) : total test count
    # -8(%ebp) : completed test count
    # -12(%ebp): array pointer
    # -16(%ebp): tmp

    # initialize locals
    movl $test_array, %edx
    movl %edx, -12(%ebp)
    movl $0, %ecx
    movl %ecx, -8(%ebp)
    movl $-1, %eax
    movl %eax, -4(%ebp)
    jmp 2f
  1:
    # advance test_array pointer
    addl $12, %edx
  2:
    cmpl %eax, (%edx)
    loopz 1b
    subl %ecx, %eax
    movl %eax, -4(%ebp) # amount of tests to be executed

  1:
    # payload
    movl -4(%ebp), %eax
    cmpl -8(%ebp), %eax
    jbe 2f
    movl -12(%ebp), %edx
    movl 8(%edx), %eax
    movl %eax, -16(%ebp) # save expected length to tmp
    movl 4(%edx), %eax
    pushl %eax
    call um_strlen
    addl $4, %esp
    # compare returned value to tmp
    cmpl -16(%ebp), %eax
    jne 2f
    # success
    addl $1, -8(%ebp)
    addl $12, -12(%ebp)
    jmp 1b
  2:
    # leave
    movl -4(%ebp), %eax
    subl -8(%ebp), %eax

    leave
    ret
