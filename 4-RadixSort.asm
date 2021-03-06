.data

data: .word 132470, 324545, 73245, 93245, 80324542, 244, 2, 66, 236, 327, 236, 21544
N: .word 12
printData1: .asciiz "data ["
printData2: .asciiz "] = "
newLine: .asciiz "\n"
sorted: .asciiz "Sorted\n"

.text

.globl main

main:	# tested

	la $s0, data	#s0 = data array
	li $s1, 0		#s1 = i
	lw $s2, N		#s2 = N

	jal printDataArr

	# passing argument on stack
	move $fp, $sp
	# first
	addiu $sp, $sp, -4
	la $t0, 0($s0)		# data
	sw $t0, 0($sp)

	# last
	addiu $sp, $sp, -4
	sll $s3, $s2, 2		# N*4
	addu $t0, $t0, $s3
	addiu $t0, $t0, -4	# data+N-1
	sw $t0, 0($sp)

	# msb : Most Significant Bit
	addiu $sp, $sp, -4
	li $t0, 31			# 31
	sw $t0, 0($sp)

	jal msd_radix_sort

	# free stack
	move $sp, $fp

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

		move $a0, $s1	# print i
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

	# setup return address
	addiu $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 0($sp)
	move $fp, $sp

	# get parameters
	lw $t0, 16($fp)	# t0 = *first
	lw $t1, 12($fp)	# t1 = *last
	lw $t2, 8($fp)	# t2 = msb

	# if(first < last)
	slt $t3, $t0, $t1
	beq $t3, $0, finish_msd_radix_sort

		# if(msb >= 0)
		bltz $t2, finish_msd_radix_sort

			# int *mid -> t3
			# $t3 = partition(first, last, msb)
			# save temp register to stack
			li $a0, 0
			jal store_arguments

			# pass parameter through temp register
			jal partition	# will result in $v0
			
			move $t3, $v0	

			# load back true parameters
			li $a0, 0
			jal load_arguments

			addiu $t2, $t2, -1	# msb --

			# sort left partition
				li $a0, 1
				jal store_arguments

				# passing arguments on stack
				addiu $sp, $sp, -12
					
					# first
					sw $t0, 8($sp)

					# mid
					sw $t3, 4($sp)

					# msb
					sw $t2, 0($sp)

					jal msd_radix_sort

				# free stack arguments
				addiu $sp, $sp, 12

				li $a0, 1
				jal load_arguments

			# sort right partition
				li $a0, 1
				jal store_arguments

				# passing arguments on stack
				addiu $sp, $sp, -12

					# mid+1
					addiu $t4, $t3, 4	# t4 = mid+1
					sw $t4, 8($sp)

					# last
					sw $t1, 4($sp)

					# msb
					sw $t2, 0($sp)

					jal msd_radix_sort

				# free stack arguments
				addiu $sp, $sp, 12

				li $a0, 1
				jal load_arguments

	finish_msd_radix_sort:

		lw $ra, 4($fp)
		lw $fp, 0($fp)
		addiu $sp, $sp, 8

		jr $ra

	# utility purpose
	store_arguments:

		# if($a0 == 0) -> not store $t3
		# else -> store $t3
		bgtz $a0, storeT3

		not_storeT3:

			addiu $sp, $sp, -12
			sw $t0, 8($sp)
			sw $t1, 4($sp)
			sw $t2, 0($sp)
			jr $ra

		storeT3:

			addiu $sp, $sp, -16
			sw $t0, 12($sp)
			sw $t1, 8($sp)
			sw $t2, 4($sp)
			sw $t3, 0($sp)
			jr $ra


	load_arguments:

		# if($a0 == 0) -> not store $t3
		# else -> store $t3
		bgtz $a0, loadT3

		not_loadT3:

			lw $t0, 8($sp)
			lw $t1, 4($sp)
			lw $t2, 0($sp)
			addiu $sp, $sp, 12
			jr $ra

		loadT3:

			lw $t0, 12($sp)
			lw $t1, 8($sp)
			lw $t2, 4($sp)
			lw $t3, 0($sp)
			addiu $sp, $sp, 16
			jr $ra

partition:
# get arguments through register
# t0 = *first
# t1 = *last
# t2 = msb
# store result in $v0
	
	move $t3, $t0	# f = first
	move $t4, $t1	# l = last

	loopWhileLF:

	# if(f<l)
	slt $t5, $t3, $t4
	beq $t5, $0, finishLoopWhileLF

		loopFIncreas:

			# get *f
			lw $t6, 0($t3)	# t6 = *f

			# shift *f right for msb
			srlv $t6, $t6, $t2	# t6 = *f >> msb

			andi $t6, $t6, 0x1	# t6 = (*f >> msb) & 0x1
			bne $t6, $0, finishLoopFIncreas	# if(!=0) -> exit

				# f < last
				slt $t6, $t3, $t1
				beq $t6, $0, finishLoopFIncreas

					addiu $t3, $t3, 4	# f++ (int pointer)
					j loopFIncreas

		finishLoopFIncreas:

		loopLdecrease:

			# get *l
			lw $t6, 0($t4)

			srlv $t6, $t6, $t2	# t6 = *l >> msb

			andi $t6, $t6, 0x1	# t6 = (*l >> msb) & 0x1

			li $t7, 1
			bne $t6, $t7, finishLoopLdecrease

				# first < l
				slt $t6, $t0, $t4
				beq $t6, $0, finishLoopLdecrease

					addiu $t4, $t4, -4
					j loopLdecrease

		finishLoopLdecrease:

		# if(f<l)
		slt $t6, $t3, $t4
		beq $t6, $0, notLessThan

		lessThan:
			# swap *l, *f
			lw $t6, 0($t3)	# t6 = *f
			move $t5, $t6	# t5 = temp = *f

			# *f = *l
			# get *l
			lw $t7, 0($t4)	# t7 = *l
			# store *l to f
			sw $t7, 0($t3)	# *f = *l

			# *l = temp
			# store temp to l
			sw $t5, 0($t4)

		notLessThan:

		j loopWhileLF

	finishLoopWhileLF:
	# store l to $v0
	move $v0, $t4

	jr $ra