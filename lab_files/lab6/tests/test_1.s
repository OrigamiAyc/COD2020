# 采用类似于斐波那契数列的计算方式
# 用开关和按键输入两个数，作为数列的 a0 和 a1，求 a9
# s0, s1 用来存储两个计算数据，s0 < s1
# t1 是循环变量，记录当前最大的数是第几个，最后取出来 s0 就行

_Input:
		lw		$s0, -32768($0)		# read from I/O					0
		lw		$s1, -32768($0)		# read from I/O again			4
		addi	$sp, $0, 0x7fc		# $sp = $t1 + 0x7fc				8
		addi	$t1, $0, 1			# $t1 = $0 + 1					12
		addi	$t2, $0, 1			# $t2 = $0 + 1					16
		addi	$t3, $0, 9			# $t3 = $0 + 9					20
_Stack:
		sw		$s0, 0($sp)			# store to stack top			24
		sw		$s1, -4($sp)		# store to stack				28
		j		_Sort				# jump to _Sort					32
_Sort:
		slt		$t0, $s0, $s1		# if $s0 < $s1, $t0 = 1			36
		beq		$t0, $t2, _Cal		# if $t0 == $t1 then _Cal		40
				# SWAP
				lw		$s0, -4($sp)# save primary $s1 to $s0		44
				lw		$s1, 0($sp)	# save primary $s0 to $s1		48
_Cal:
		add		$s0, $s1, $s0		# $s0 = $s1 + $s0				52
		addi	$t1, $t1, 1			# $t1 = $t1 + 1					56
		bne		$t1, $t3, _Stack	# if $t1 != $t3 then _Stack		60
_Output:
		sw		$s0, -32768($0)		# to LED						64
		j		_Success			# jump to _Success				68
_Success:
		j		_Success			# jump to _Success				72
