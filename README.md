# RJViewFrame


2017-12-17 20:00
1.2更新:
1.增加swift
2.swift中增加直接修改frame的扩展.

----------分割线----------

2017-12-17 18:00
1.1 更新：
1.增加了left right origin设置方法 删除了x和y方法.
并且优化了setter和getter。
增加了工程Demo，包含了测试方法。

----------分割线----------

鸡(fei)汤(hua)给大家补一补。

Champions have the courage to keep turning the pages because they know a better chapter lies ahead.

首先这些代码有什么用：就是方便大家设置UIView的坐标(origin)和大小（size）

	view.left = 0;
	view.top = 0;
	view.size = CGSizeMake(100, 100);
	view.width = 100;
	view.height = 100;
	
是不是方便多了，不用再用一个frame变量来接了。

相信这些代码大家都懂，都会写，而且github上也有不少可以说是一模一样的，但是我还是要写。因为我可以拿来向菜b装B啊。

![file](https://raw.githubusercontent.com/Jeremy1221/Jeremy1221.github.io/master/img/JER_Frame/000100.gif)
![file](https://raw.githubusercontent.com/Jeremy1221/Jeremy1221.github.io/master/img/JER_Frame/001000.gif)
![file](https://raw.githubusercontent.com/Jeremy1221/Jeremy1221.github.io/master/img/JER_Frame/010000.gif)
![file](https://raw.githubusercontent.com/Jeremy1221/Jeremy1221.github.io/master/img/JER_Frame/100000.gif)


首先这是一个UIView(JER_Frame)的类别，这里建议大家在创建自己的类别时都加上三个字母的前缀，当然是为了防命名冲突啊。

然后在类别中声明属性，这里和在类中声明属性可不一样。在类中声明属性可是会自动创建实例变量和获取方法的。而在类别中只是一个简单的属性，并没有其他任何作用，不能存储值。
然后在类别的实现文件中实现属性的存取方法来设置UIView的frame。

----------沉底----------

email: r913218338@163.com
# XcodeSnippets
