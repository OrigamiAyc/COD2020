# Test cases for MIPS 5-Stage pipeline

.data
	.word 0,1,2,3,0x80000000,0x80000100,0x100,5,0

_start:
	add $t1, $0, $0			# $t1 = 0						0
	j _test0				#								4

_test0:
	addi $t2, $0, 1			# $t2 = 1						8
	addi $t2, $t2, 1		# $t2 = 2						12
	add $t2, $t2, $t2		# $t2 = 4						16
	addi $t2, $t2, -4		# $t2 = 0						20
	beq $t2, $0, _next0		# if $t2 == $0: $t1++, go next testcase, else: go fail	24
	j _fail					#								28
_next0:
	addi $t1, $t1, 1		# $t1++							32
	j _test1				#								36

_test1:
	addi $0, $0, 4			# $0 += 4						40
	lw $t2, 4($0)			# $t2 = MEM[1]					44
	lw $t3, 8($0)			# $t3 = MEM[2]					48
	add $t4, $t2, $t3		#			 					52
	sw $t4, 0($0)			# MEM[0] = $t4					56
	lw $t5, 0($0)			# $t5 = MEM[0]					60
	lw $t6, 12($0)			# $t6 = MEM[3]					64
	beq $t5, $t6, _next1	#								68
	j _fail					#								72
	
_next1:
	addi $t1, $t1, 1		#								76
	j _success				#								80

_fail:
	j _fail					#								84

_success: 
	j _success				# if success: $t1 == 2			88
