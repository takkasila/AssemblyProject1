.data
aArray: .word 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
bArray: .word 0x7fffffff, 0x7ffffffe, 0x7ffffffd, 0x7ffffffc,0x7ffffffb, 0x7ffffffa, 0x7ffffff9, 0x7ffffff8, 0x7ffffff7,0x7ffffff6
printA: .asciiz "Sum a = "
printB: .asciiz "\nSum b = "

.text
.globl	main

main:

	li	$s0, 0 	#i
	li	$s1, 0 	#sum
	la 	$s2, aArray
	la 	$s3, bArray

	loopArrayA:

		slti	$t0, $s0, 20
		beq		$t0, $0, exitLoopArrayA

		#get a[i]
		sll		$t0, $s0, 2
		addu 	$t0, $t0, $s2
		lw		$t1, 0($t0)

		addu	$s1, $s1, $t1
		addiu	$s0, $s0, 1

		j	loopArrayA

		exitLoopArrayA:


	#print out section
	la 	$a0, printA
	li	$v0, 4
	syscall

	move $a0, $s1
	li	$v0, 1
	syscall

	#reset
	li	$s0, 0 	#i
	li	$s1, 0 	#sum

	loopArrayB:

		slti	$t0, $s0, 10
		beq		$t0, $0, exitLoopArrayB

		#get b[i]
		sll 	$t0, $s0, 2
		addu 	$t0, $t0, $s3
		lw 		$t1, 0($t0)

		addu 	$s1, $s1, $t1
		addiu	$s0, $s0, 1

		j loopArrayB

		exitLoopArrayB:

	#print out section
	la 	$a0, printB
	li 	$v0, 4
	syscall

	move $a0, $s1
	li 	$v0, 1
	syscall


	li $v0, 10
	syscall

