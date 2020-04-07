li $v0, 5				# service 5 is read integer
syscall 
add $s0, $v0, $zero			# load return value into register $s0: total number

slti $t0, $v0, 1			# if the number of data < 1, terminate the program
beq $t0, 1, Exit

add $t0, $zero, $zero			# the loop varible
add $s1, $sp, $zero			# store the initial address of the $sp, so that we can get the boundary then

Init:	addi $t0, $t0, 1
	li $v0, 5
	syscall
	sw $v0, 0($sp)
	addi $sp, $sp, -4		# the stack moves to one lower store
	
	bne $t0, $s0, Init		# if the loop varible is not equal with the total number, continue the loop
	
beq $s0, 1, Print				# if there's only one number, just print it

addi $s2, $sp, 4				# the last statistic of the stack, stored for promoting speed
addi $s3, $s0, -1				# number 'n-1'
addi $s4, $s1, 4				# aimed for a faster print
addi $sp, $sp, 4				# to point to the last statistic again

# start sorting (use $sp to point to the comparing bubble)
add $t0, $zero, $zero				# loop varible
li $v0, 30					# 30 shows the system time
syscall
add $s7, $a0, $zero				# lower return value is in $a0

Cycle_i:addi $t0, $t0, 1			# loop varible increment
	Cycle_j:lw $t1, 0($sp)
		lw $t2, 4($sp)			# load one statistic and the one in higher addr
		slt $t3, $t1, $t2		# if $t1 < $t2
		beq $t3, 1, NOSWAP		# put the larger one on the top
			# SWAP
			sw $t1, 4($sp)
			sw $t2, 0($sp)
		NOSWAP:	addi $sp, $sp, 4	# move to the next level
		bne $sp, $s1, Cycle_j
	add $sp, $s2, $zero			# reinit the $sp
	addi $s1, $s1, -4			# update the surface (the largest is already there!)
	bne $t0, $s3, Cycle_i
	
li $v0, 30					# 30 shows the system time
syscall
sub $a0, $a0, $s7
li $v0, 1
syscall						# print total time

li $v0, 11					# print a character
addi $a0, $zero, 10				# 10 is '\n'
syscall

add $sp, $s2, $zero
add $t0, $zero, $zero				# loop varible
Print:	add $t0, $t0, 1
	li, $v0, 1				# print integer
	lw $a0, 0($sp)
	syscall
	# build table
	li, $v0, 11				# print a character
	addi $a0, $zero, 9				# 9 is '\t'
	syscall
	# loop ctrl
	addi $sp, $sp, 4			# move to the upper level
	bne $sp, $s4, Print

Exit:	li, $v0, 10				# 10 is exit
	syscall