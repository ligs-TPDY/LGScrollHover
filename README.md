# LGScrollHover
### 极简单实现UIScrollView+UITableView，有悬停功能
###### 由于底层视图和上层视图的滚动状态都依靠LGScrollHover的状态，为了在多个文件中共享某次操作的状态，所以用单例来持有一个维持状态的对象。
###### 使用时，在本文件中添加一个唯一标记，该标记会唯一对应一个记录状态的对象。并在底层视图和上层视图中使用该对象操作。(如果你是UIScrollView上放UITableView，那么底层视图就是UIScrollView，上层视图就是UITableView)
###### 记得在底层视图被释放时，初始化对应标记的状态。
    使用示例：
    1，底层滚动视图
    {   ///在初始化UI后，调用下面的方法
        ///将底层对象传入，做初始化配置
        ///设置底层视图滚动停止Y坐标
        ///调试时建议打开日志打印
        [[LGScrollHoverManager getScrollHoverAboutKey:TEST] addBottomLayerScrollView:self.scrollView bottomLayerScrollView_Y:Y isShowLog:NO];
     }
 
    ///代理方法中调用，将实时的位置变化传进去
    - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
        [[LGScrollHoverManager getScrollHoverAboutKey:TEST] lgBottomLayerScrollViewDidScroll:scrollView];
    }
 
 
    ///在底层视图的析构函数中，重置状态
    - (void)dealloc{
        [[LGScrollHoverManager getScrollHoverAboutKey:TEST] lgDealloc];
    }
 
    2,上层滚动视图
    ///代理方法中调用，将实时的位置变化传进去
    - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
        [[LGScrollHoverManager getScrollHoverAboutKey:TEST] lgUpperLayerScrollViewDidScroll:scrollView];
    }
 
