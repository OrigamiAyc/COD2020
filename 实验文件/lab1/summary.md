有几个误区：

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

