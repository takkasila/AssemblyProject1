.data

data: .word 132470, 324545, 73245, 93245, 80324542, 244, 2, 66, 236, 327, 236, 21544
N: .word 12
printData1: .asciiz "data ["
printData2: .asciiz "] = "
newLine: .asciiz "\n"
sorted: .asciiz "Sorted\n"

.text

.globl main

main:

	la $s0, data	#s0 = data array
	li $s1, 0		#s1 = i


	li $v0, 10
	syscall