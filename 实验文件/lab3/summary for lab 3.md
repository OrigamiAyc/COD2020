# summary for lab 3

<p align="right">by 鸢一折纸</p>

## Single Cycle CPU

### About PC

PC (program counter)

- Why PC + 4 in memory?
	- 因为，实现的时候有偏移啊。。。
	- ![Screenshot 2020-05-13 at 1.30.28 PM](/Users/lapland/Library/Application Support/typora-user-images/Screenshot 2020-05-13 at 1.30.28 PM.png)
	- 然后，从指令ROM里面取指令的时候，要做一个地址截断`assign pc_addr = PC[9:2]`
- 扩展 extend
	- 用一次三目运算符即可
- control unit
	- `ALUOp`
	- COD第五版的261页（英文版）如下表：emm这个不写了（用下面那个就行）

<table>
    <tr>
        <th colspan="2">ALUOp</th>
        <th colspan="6">Funct field</th>
        <th rowspan="2">Operation</th>
    </tr>
    <tr>
        <td>ALUOp1</td>
        <td>ALUOp0</td>
        <td>F5</td>
        <td>F4</td>
        <td>F3</td>
        <td>F2</td>
        <td>F1</td>
        <td>F0</td>
    </tr>
    <tr>
        <td>0</td>
        <td>0</td>
        <td>X</td>
        <td>X</td>
        <td>X</td>
        <td>X</td>
        <td>X</td>
        <td>X</td>
        <td>0010</td>
    </tr>
</table>

- control unit
	- `addi`指令是我自己这么认为的

| Instruction | RegDst | ALUSrc | MemtoReg | RegWrite | MemRead | MemWrite | Branch | ALUOp |
| ----------- | ------ | ------ | -------- | -------- | ------- | -------- | ------ | ----- |
| R-format    | 1      | 0      | 0        | 1        | 0       | 0        | 0      | 10    |
| `addi`      | 0      | 1      | 0        | 1        | 0       | 0        | 0      | 00    |
| `lw`        | 0      | 1      | 1        | 1        | 1       | 0        | 0      | 00    |
| `sw`        | X      | 1      | X        | 0        | 0       | 1        | 0      | 00    |
| `beq`       | X      | 0      | X        | 0        | 0       | 0        | 1      | 01    |

`j`：只有**jump**是**1'b1**


- ALU control
	- COD第五版的260页（英文版）如下表：

|Instruction opcode|ALUOp|Instruction operation|Funct field|Desired ALU action|ALU control input|
|-|-|-|-|-|-|
|LW|00|load word|XXXXXX|add|0010|
|SW|00|store word|XXXXXX|add|0010|
|Branch equal|01|branch equal|XXXXXX|subtract|0110|
|R-type|10|add|100000|add|0010|
|R-type|10|subtract|100010|subtract|0110|
|R-type|10|AND|100100|AND|0000|
|R-type|10|OR|100101|OR|0001|
|R-type|10|set on less than|101010|set on less than|0111|

> The last one refers to the `slt $1, $2, $3` instruction, which means the following :
>
> `(rs < rt) ? rd = 1 : rd = 0`
>
> `rs = $2, rt = $3, rd = $1`

- 关于`lw`和`lb` (load byte)
	- 在指令`lw`里面，32位地址取的是`[9:2]`这8位，那么，低两位干什么了？
	- 包括`PC`也有这个情况，是因为32位是4个字节啊。。。
	- 那么，这两位的用处是：
		- 对于`lb`指令，取出来的还是4个字节，然后$A_0A_1$两位就用于选择是哪一个字节