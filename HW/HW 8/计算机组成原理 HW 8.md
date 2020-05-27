# 计算机组成原理 HW 8

<p align="right">PB18000227 艾语晨</p>

## 唐书 5.4

> Q :
>
> **试比较程序查询方式、程序中断方式和DMA方式对CPU工作效率对影响**

> A :

程序查询方式：由于在有I/O操作的时候，计算机就会暂停主程序，转而执行I/O，加以I/O的低效率，会浪费很多CPU周期和资源

程序中断方式：由于采用了CPU和I/O设备并行的结构，故占用很少的CPU周期（每一次I/O请求用一个时钟周期）

DMA方式：数据交换不经过CPU，占用CPU不访问内存的时间，几乎不占用CPU周期

综上所述，对CPU工作效率的降低程度：DMA < 程序中断 < 程序查询

## 唐书 5.8

> Q :
>
> **某计算机的I/O设备采用异步串行传送方式传送字符信息。字符信息的格式为1位起始位、7位数据位、1位检验位和1位停止位。若要求每秒钟传送480个字符，那么该设备的数据传输速率为多少**

> A :
>
> ch7 Page8：即总线带宽

$480\times(1+7+1+1)=4800\ bits/s$

## 唐书 4.38

> Q :
>
> **磁盘组有6片磁盘，最外两侧盘面可以记录，存储区域内径22cm，外径33cm，道密度为40道/cm，内层密度为400位/cm，转速3600转/分**
>
> **(1) 共有多少存储面可用**
>
> **(2) 共有多少柱面**
>
> **(3) 盘组总存储容量是多少**
>
> **(4) 数据传输率是多少**

> A :

盗一张图：

![from_mbinary_on_jianshu](https://upload-images.jianshu.io/upload_images/7130568-50fae3ad59f3cbe3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

取 $\pi=3$

（1）$2\times6=12$ 个面可以用

（2）$(33-22+1)\times40=480$ 个柱面

（3）$\begin{align}2\pi\times22\times400\times480\times12&=304128000\ bits\\&=38016000\ B\\&=37125\ kiB\\&\approx36.25\ MiB\end{align}$

（4）$\begin{gather}3600 r/min = 60 r/s\\60\times2\pi\times22\times400=3168000\ bits/s\end{gather}$

