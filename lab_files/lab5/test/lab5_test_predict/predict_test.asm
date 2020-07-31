_test0:
	add $t0, $0, $0			# $t0 = 0		0
	addi $t1, $0, 100		# $t1 = 100		4
	j _test1			#			8

_test1:
	addi $t0, $t0, 1		# $t0++			12
	bne $t0, $t1, _test1		#			16

_success:
	j _success			#			20
