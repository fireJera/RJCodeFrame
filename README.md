# RJViewFrame

废话不多说，直接鸡(fei)汤(hua)给大家补一补。

Champions have the courage to keep turning the pages because they know a better chapter lies ahead.

首先这些代码有什么用：就是方便大家设置UIView的坐标(origin)和大小（size）

	view.x = 0;
	view.y = 0;
	view.size = CGSizeMake(100, 100);
	view.width = 100;
	view.height = 100;
	
是不是方便多了，不用再用一个frame变量来接了。

相信这些代码大家都懂，都会写，而且github上也有不少可以说是一模一样的，但是我还是要写。因为我可以拿来向菜b装B啊。

好了，下面向菜B(不是侮辱，而是警醒)认真讲一下原理，有基础的自行跳过:

首先这是一个UIView(JER_Frame)的类别，这里建议大家在创建自己的类别时都加上三个字母的前缀，当然是为了防命名冲突啊。

然后在类别中声明属性，这里和在类中声明属性可不一样。在类中声明属性可是会自动创建实例变量和获取方法的(获取方法我猜的还没验证)。而在类别中只是一个简单的属性，并没有其他任何作用，不能存储值。
然后在类别的实现文件中实现属性的存取方法来设置UIView的frame。