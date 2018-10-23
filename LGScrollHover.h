//
//  LGBottomView.h
//  qfxtaoguwang
//
//  Created by carnet on 2018/10/23.
//  Copyright © 2018年 qfx. All rights reserved.
//
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

#import <UIKit/UIKit.h>

@interface LGScrollHover : NSObject

+ (LGScrollHover *)sharedLGScrollHover;

///1，底层滚动视图悬停时的位置
- (void)setBottomLayerScrollView_Y:(CGFloat)Y;

///2，底层滚动视图基本设置
- (void)addBottomLayerScrollView:(UIScrollView *)bottomLayerScrollView;
///3，底层滚动视图调用
- (void)lgBottomLayerScrollViewDidScroll:(UIScrollView *)scrollView;

///4，上层滚动视图调用
- (void)lgUpperLayerScrollViewDidScroll:(UIScrollView *)scrollView;


///是否打印日志，调试时建议打开
- (void)isShowLog:(BOOL)show;
@end
