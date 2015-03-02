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
	lw $s2, N		#s2 = N

	jal printDataArr

	# todo
	jal msd_radix_sort

	la $a0, newLine	# print \n\n
	li $v0, 4
	syscall
	syscall

	la $a0, sorted
	syscall

	li $s1, 0
	jal printDataArr

	li $v0, 10
	syscall

printDataArr:	# tested

	slt $s3, $s1, $s2
	beq $s3, $0, finishPrintDataArr	#if(i>=N) -> exit

	la $a0, printData1
	li $v0, 4
	syscall

	move $a0, $s1
	li $v0, 1
	syscall

	la $a0, printData2
	li $v0, 4
	syscall

	sll $s3, $s1, 2		# s3 = i*4
	addu $s3, $s3, $s0	# s3 = address of data[i]
	lw $s4, 0($s3)		# s4 = data[i]
	move $a0, $s4		# print data[i]
	li $v0, 1
	syscall

	la $a0, newLine
	li $v0, 4
	syscall

	#update i
	addiu $s1, $s1, 1

	j printDataArr

	finishPrintDataArr:

		jr $ra

msd_radix_sort:

	jr $ra