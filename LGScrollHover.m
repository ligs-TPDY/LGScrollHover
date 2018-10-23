//
//  LGScrollViewController.m
//  scroll嵌套Table+悬停效果
//
//  Created by carnet on 2018/10/23.
//  Copyright © 2018年 IAPTest. All rights reserved.
//

#import "LGScrollHover.h"
@interface LGScrollHover ()
{
    BOOL bottomLayerCanMove;
    BOOL upperLayerCanMove;
    CGFloat maxOffsetY;
    BOOL showLog;
}
@end

@implementation LGScrollHover

+ (LGScrollHover *)sharedLGScrollHover {
    static LGScrollHover *sharedLGScrollHover = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLGScrollHover = [[self alloc] init];
    });
    return sharedLGScrollHover;
}

- (void)addBottomLayerScrollView:(UIScrollView *)bottomLayerScrollView
{
    bottomLayerScrollView.tag = 7800;
}
///悬停时底层滚动视图的位置
- (void)setBottomLayerScrollView_Y:(CGFloat)Y
{
    maxOffsetY = Y;
}
- (void)isShowLog:(BOOL)show
{
    showLog = show;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        bottomLayerCanMove = YES;  // 最开始的时候是可以滑动的
        upperLayerCanMove = NO;//最开始的时候是不能进行滑动的
    }
    return self;
}

- (void)lgBottomLayerScrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (showLog) {
        NSLog(@"LGScrollViewController==>scrollView的偏移量：===%f", contentOffsetY);
    }
    if (bottomLayerCanMove == NO) {
        [scrollView setContentOffset:CGPointMake(0, maxOffsetY)];
        return;
    }
    if (contentOffsetY > maxOffsetY) {
        if (showLog) {
            NSLog(@"到达悬停位置，底部滚动停止！！！==>%f", maxOffsetY);
        }
        [scrollView setContentOffset:CGPointMake(0, maxOffsetY)]; //设置最大偏移
        upperLayerCanMove = YES;
        bottomLayerCanMove = NO;//自己不能滑动了
    }
}

- (void)lgUpperLayerScrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (showLog) {
        NSLog(@"LGScrollView==>scrollView的偏移量：===%f", offsetY);
    }
    if (upperLayerCanMove == NO) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
    if (offsetY <= 0) {
        bottomLayerCanMove = YES;
        upperLayerCanMove = NO;//自己不能滑动了
    }
}
@end

