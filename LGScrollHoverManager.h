//
//  LGBottomView.h
//  qfxtaoguwang
//
//  Created by carnet on 2018/10/23.
//  Copyright © 2018年 qfx. All rights reserved.
//

///////////////////////////////////---定义key---////////////////////////////
extern NSString * const INVESTINGPERSONALHOMEPAGE;
extern NSString * const INTELLIGENTDECISIONHOMEPAGE;
///////////////////////////////////////////////////////////////////////////

/*
    由于底层视图和上层视图的滚动状态都依靠LGScrollHover的状态，为了在多个文件中共享某次操作的状态，所以用单例来持有一个维持状态的对象。
    使用时，在该文件中添加一个LGScrollHover属性对象，并在底层视图和上层视图中使用该对象操作。
 */

#import <UIKit/UIKit.h>

@class LGScrollHover;

@interface LGScrollHoverManager : NSObject

+ (LGScrollHoverManager *)sharedLGScrollHoverManager;

- (LGScrollHover *)getScrollHoverAboutKey:(NSString *)key;

@end


/*
 使用示例：
 1，底层滚动视图：创建滚动视图时，调用1，2
 在底层滚动视图的- (void)scrollViewDidScroll:(UIScrollView *)scrollView中调用3
 2，在上层滚动视图的- (void)scrollViewDidScroll:(UIScrollView *)scrollView中调用4
 OK，
 iOS开发中实现UIScrollView及其子类嵌套UIScrollView及其子类，且上滑有悬停效果
 使用最多组合： ==>UIScrollView+UITableView
 ==>UITableView+UITableView
 */
@interface LGScrollHover : NSObject

///1，底层滚动视图悬停时的位置
- (void)setBottomLayerScrollView_Y:(CGFloat)Y;

///2，底层滚动视图基本设置
- (void)addBottomLayerScrollView:(UIScrollView *)bottomLayerScrollView;
///3，底层滚动视图调用
- (void)lgBottomLayerScrollViewDidScroll:(UIScrollView *)scrollView;

///4，上层滚动视图调用
- (void)lgUpperLayerScrollViewDidScroll:(UIScrollView *)scrollView;

///5，恢复初始化设置
- (void)lgDealloc;

///是否打印日志，调试时建议打开
- (void)isShowLog:(BOOL)show;
@end
