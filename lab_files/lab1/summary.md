# Summary

<p align="right">by 鸢一折纸</p>

1. 有几个误区：

我觉得实际上还是在用 C/C++ 这样的高层语言来思考 verilog

一个是<font color=red>多驱动问题</font>

就是说在一个always语句里面有多个并行执行体来对同一变量赋值

一个是反馈电路，就是在组合逻辑里面不能swap

比如这个就是不行的

```verilog
a = s0;
b = s1;
if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
    s0 = b;
    s1 = a;
end
```

2. 注意是有符号数比较，所以不要照抄PPT！！！
3. 用 MUX 来实现交换
4. 我觉得吧，MUX0～4也可以用ALU的输出来控制，因为最终决定是否改变寄存器的值是使能信号，所以按照我那个电路图来看，使能为1恰好MUX也选择了交换通道

