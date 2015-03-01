.data

printText: .asciiz "Sorted string is "
RANGE: .word 255
N: .word 1000
str: .asciiz "cadljgarhtoxAHdgdsJKhYEasduwBRLsdgHoptxnaseurh"

.text

.globl main

main:

	la $s0, str		# getting define variable
	lw $s1, N
	lw $s2, RANGE
	move $fp, $sp

	jal countSort	# pass by ref

	la $a0, printText	# result text
	li $v0, 4
	syscall

	move $a0, $s0
	li $v0, 4
	syscall

	li $v0, 10
	syscall


countSort:

	addiu $sp, $sp, -8	# setting stack up
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp

	#char output[N]
	subu $sp, $sp, $s1
	la $t0, 0($sp)	# $t0 = output[size N]

	#int count[RANGE + 1]
	addiu $t1, $s2, 1	# $t1 = range + 1
	li $t2, 4
	mul $t2, $t2, $t1	# $t2 = 4*(range + 1)
	subu $sp, $sp, $t2
	la $t2, 0($sp)		# $t2 = count [size Range+1]

	#int i
	addiu $sp, $sp, -4
	la $t3, 0($sp)	# t3 = i
	li $t4, 0
	sw $t4, 0($t3)	# i = 0

	move $fp, $sp

	initializeCountArr:	# tested

		lw $t4, 0($t3)	# get current i
		slt $t5, $t4, $t1	#if(i < RANGE + 1) -> t5 = 1
		beq $t5, $0, finishInitializeCountArr

		# get count[i]
		sll $t5, $t4, 2	# i << 2
		addu $t5, $t5, $t2	# address a[i]
		sw $0, 0($t5)	# a[i] = 0

		# update i
		addiu $t4, $t4, 1
		sw $t4, 0($t3)	# store i to memory

		j initializeCountArr

		finishInitializeCountArr:


	# set i = 0
	sw $0, 0($t3)

	storeCountOfStrArr:	# tested

		# get current i
		lw $t1, 0($t3)

		# get str[i]
		addu $t4, $s0, $t1	# t4 = address str[i]
		lbu $t5, 0($t4)		# t5 = str[i]

		beq $t5, $0, finishStoreCountOfStrArr #if (str[i] == 0) -> exit

		sll $t7, $t5, 2	# t7 = str[i]*4
		addu $t7, $t7, $t2	# t7 = address count[str[i]]
		lw $t6, 0($t7)		# t6 = count[str[i]]
		addiu $t6, $t6, 1	# count ++
		sw $t6, 0($t7)		# store count back to memory

		#update i
		addiu $t1, $t1, 1
		sw $t1, 0($t3)

		j storeCountOfStrArr

		finishStoreCountOfStrArr:


	# set i = 1
	li $t1, 1
	sw $t1, 0($t3)

	updateCountArr:	# tested 50%

		lw $t1, 0($t3)	# get current i
		slt $t4, $s2, $t1	# if(RANGE < i) --> t4 = 1
		bne $t4, $0, finishUpdateCountArr # if(t4 != 0) -> exit

		# get count[i-1]
		addiu $t1, $t1, -1	# i--
		sll $t4, $t1, 2	# t4 = i*4
		addu $t4, $t4, $t2	# t4 = address count[i-1]
		lw $t4, 0($t4)	# t4 = count[i-1]

		# get count[i]
		addiu $t1, $t1, 1	# i++
		sll $t5, $t1, 2	# t5 = i*4
		addu $t5, $t2, $t5	# t5 = address count[i]
		lw $t6, 0($t5)	# t6 = count[i]

		# count[i] += count[i-1]
		addu $t6, $t6, $t4
		sw $t6, 0($t5)

		#update
		addiu $t1, $t1, 1	# i++
		sw $t1, 0($t3)

		j updateCountArr

		finishUpdateCountArr:


	# set i = 0
	sw $0, 0($t3)

	buildOutputArr:

		# get current i
		lw $t1, 0($t3)

		# get str[i] 
		addu $t4, $s0, $t1	# t4 = address str[i]
		lbu $t5, 0($t4)		# t5 = str[i]

		beq $t5, $0, finishBuildOutputArr #if (str[i] == 0) -> exit

		# get count[str[i]]
		sll $t6, $t5, 2	# t6 = str[i] * 4
		addu $t6, $t6, $t2	# t6 = address count[str[i]]
		lw $t7, 0($t6)	# t7 = count[str[i]]

		addiu $t7, $t7, -1	# t7 = count[str[i]]-1

		# get output[count[str[i]]-1] address
		addu $t8, $t7, $t0	# t8 = address of output[count[str[i]]-1]

		sb $t5, 0($t8)	# output[count[str[i]]-1] = str[i]

		# count[str[i]] = count[str[i]] -1
		sw $t7, 0($t6)

		# update i
		addiu $t1, $t1, 1
		sw $t1, 0($t3)

		j buildOutputArr

		finishBuildOutputArr:

	# set i = 0
	sw $0, 0($t3)

	copyOutputToStr:

		# get current i
		lw $t1, 0($t3)

		# get str[i] 
		addu $t4, $s0, $t1	# t4 = address of str[i]
		lbu $t5, 0($t4)		# t5 = str[i]

		beq $t5, $0, finishCopyOutputToStr #if (str[i] == 0) -> exit

		# get output[i]
		addu $t6, $t0, $t1	# t6 = address of output[i]
		lbu $t6, 0($t6)		# t6 = output[i]

		sb $t6, 0($t4)	# str[i] = output[i]

		# update i
		addiu $t1, $t1, 1
		sw $t1, 0($t3)

		j copyOutputToStr

		finishCopyOutputToStr:

	# free i
	addiu $sp, $sp, 4

	# free int count[RANGE + 1]
	addiu $t1, $s2, 1
	sll $t1, $t1, 2
	addu $sp, $sp, $t1

	# free char output[N]
	addu $sp, $sp, $s1

	# free stack setting
	lw $ra, 4($sp)
	lw $fp, 0($sp)
	addiu $sp, $sp, 8

	jr $ra
