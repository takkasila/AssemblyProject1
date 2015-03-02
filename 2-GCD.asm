.data
printGCDText: .asciiz "gcd of 1890 and 3315 is "

.text

.globl	main

main:

	la $a0, printGCDText
	li $v0, 4
	syscall

	li $s0, 1890	# m
	li $s1, 3315	# n

	move $fp, $sp	#setting parametar on stack
	addiu $sp, $sp, -8
	sw $s0, 4($sp)	# m
	sw $s1, 0($sp)	# n

	jal gcd	#answer will result in $v0

	move $sp, $fp	# roll back stack

	move $a0, $v0
	li $v0, 1
	syscall

	li $v0, 10
	syscall

gcd:

	addiu $sp, $sp, -8	# setting up stack
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp

	# getting the arguments
	lw $t0, 12($fp)	# m
	lw $t1, 8($fp)	# n

	# if(m == n)
	bne $t0, $t1, caseNotEqual

	caseEqual:

		move $v0, $t0

		lw $ra, 4($fp)
		lw $fp, 0($fp)
		addiu $sp, $sp, 8
		jr $ra

	caseNotEqual:

		# else if (n < m)
		slt $t2, $t1, $t0
		beq $t2, $0, caseNMuchThanM

		caseNLessThanM:

			subu $t0, $t0, $t1	# m = m-n
			addiu $sp, $sp, -8	# setting atack parameter
			sw $t0, 4($sp)	# m
			sw $t1, 0($sp)	# n

			jal gcd

			addiu $sp, $sp, 8	# roll back and free stack
			lw $ra, 4($fp)	
			lw $fp, 0($fp)
			addiu $sp, $sp, 8

			jr $ra

		caseNMuchThanM:

			subu $t1, $t1, $t0	#n = n-m
			addiu $sp, $sp, -8
			sw $t0, 4($sp)
			sw $t1, 0($sp)

			jal gcd

			addiu $sp, $sp, 8	# roll back and free stack
			lw $ra, 4($fp)
			lw $fp, 0($fp)
			addiu $sp, $sp, 8

			jr $ra
