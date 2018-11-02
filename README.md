# LGScrollHover
极简单实现UIScrollView+UITableView，有悬停功能


    由于底层视图和上层视图的滚动状态都依靠LGScrollHover的状态，为了在多个文件中共享某次操作的状态，所以用单例来持有一个维持状态的对象。
    使用时，在本文件中添加一个唯一标记，该标记会唯一对应一个记录状态的对象。并在底层视图和上层视图中使用该对象操作。
    (如果你是UIScrollView上放UITableView，那么底层视图就是UIScrollView，上层视图就是UITableView)
    记得在底层视图被释放时，初始化对应标记的状态。
