//
//  LGScrollViewController.m
//  scroll嵌套Table+悬停效果
//
//  Created by carnet on 2018/10/23.
//  Copyright © 2018年 IAPTest. All rights reserved.
//

//////////////////////////////////////---定义key---////////////////////////////////////////
NSString * const INVESTINGPERSONALHOMEPAGE = @"InvestingPersonalHomepage";
NSString * const INTELLIGENTDECISIONHOMEPAGE = @"IntelligentDecisionHomepage";
//////////////////////////////////////////////////////////////////////////////////////////

#import "LGScrollHoverManager.h"
@interface LGScrollHoverManager ()
///缓存复用池
@property (nonatomic,strong) NSMutableDictionary *multiplexPool;
@end

@implementation LGScrollHoverManager

+ (LGScrollHoverManager *)sharedLGScrollHoverManager
{
    static LGScrollHoverManager *sharedLGScrollHoverManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLGScrollHoverManager = [[self alloc] init];
        sharedLGScrollHoverManager.multiplexPool = [[NSMutableDictionary alloc]init];
    });
    return sharedLGScrollHoverManager;
}
- (LGScrollHover *)getScrollHoverAboutKey:(NSString *)key
{
//    NSLog(@"缓存复用池已经存在的key:%@,当新注册时谨防重复！！！",[_multiplexPool allKeys]);
    //1,查询是否存在该key标记的对象，如果存在，直接返回对象；如果不存在，创建新对象并返回对象
    if ([[_multiplexPool allKeys] containsObject:key]) {
        return _multiplexPool[key];
    }else{
        LGScrollHover *scrollHover = [[LGScrollHover alloc]init];
        [_multiplexPool setObject:scrollHover forKey:key];
        return scrollHover;
    }
}

@end

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
///恢复初始化设置
- (void)lgDealloc
{
    bottomLayerCanMove = YES;  // 最开始的时候是可以滑动的
    upperLayerCanMove = NO;//最开始的时候是不能进行滑动的
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
