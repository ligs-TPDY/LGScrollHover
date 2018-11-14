//
//  LGScrollViewController.m
//  scroll嵌套Table+悬停效果
//
//  Created by carnet on 2018/10/23.
//  Copyright © 2018年 IAPTest. All rights reserved.
//

//////////////////////////////////////---定义key---////////////////////////////////////////
NSString * const TEST = @"test";
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
+ (LGScrollHover *)getScrollHoverAboutKey:(NSString *)key
{
//    NSLog(@"缓存复用池已经存在的key:%@,当新注册时谨防重复！！！",[_multiplexPool allKeys]);
    //1,查询是否存在该key标记的对象，如果存在，直接返回对象；如果不存在，创建新对象并返回对象
    LGScrollHoverManager *manager = [LGScrollHoverManager sharedLGScrollHoverManager];
    if ([[manager.multiplexPool allKeys] containsObject:key]) {
        return manager.multiplexPool[key];
    }else{
        LGScrollHover *scrollHover = [[LGScrollHover alloc]init];
        [manager.multiplexPool setObject:scrollHover forKey:key];
        return scrollHover;
    }
}
@end

@interface LGScrollHover ()
{
    BOOL _bottomLayerCanMove;
    BOOL _upperLayerCanMove;
    CGFloat _maxOffsetY;
    BOOL _showLog;
    
    ///上层视图是否可以下拉刷新
    BOOL _isUpperLayerCanRefresh;
    ///底层ScrollView
    UIScrollView *_bottomLayerScrollView;
    
    ///底层视图是否支持下拉刷新
    BOOL _isBottomLayerSupportRefresh;
    ///上层视图是否支持下拉刷新
    BOOL _isUpperLayerSupportRefresh;
}
@end

@implementation LGScrollHover

- (void)setBottomLayerSupportRefresh:(BOOL)supportRefresh{
    _isBottomLayerSupportRefresh = supportRefresh;
}
- (void)setUpperLayerSupportRefresh:(BOOL)supportRefresh{
    _isUpperLayerSupportRefresh = supportRefresh;
}

+ (LGScrollHover *)sharedLGScrollHover {
    static LGScrollHover *sharedLGScrollHover = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLGScrollHover = [[self alloc] init];
    });
    return sharedLGScrollHover;
}

///1，底层滚动视图基本设置
- (void)addBottomLayerScrollView:(UIScrollView *)bottomLayerScrollView bottomLayerScrollView_Y:(CGFloat)Y isShowLog:(BOOL)show;
{
    bottomLayerScrollView.tag = 7800;
    _bottomLayerScrollView = bottomLayerScrollView;
    _maxOffsetY = Y;
    _showLog = show;
}
///恢复初始化设置
- (void)lgDealloc
{
    _bottomLayerCanMove = YES;// 最开始的时候是可以滑动的
    _upperLayerCanMove = YES;//最开始的时候是不能进行滑动的
    _isUpperLayerCanRefresh = YES;//默认上层视图可以刷新
    _bottomLayerScrollView = nil;
    _isBottomLayerSupportRefresh = YES;
    _isUpperLayerSupportRefresh = YES;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _bottomLayerCanMove = YES;// 最开始的时候是可以滑动的
        _upperLayerCanMove = YES;//最开始的时候是不能进行滑动的
        _isUpperLayerCanRefresh = YES;//默认上层视图可以刷新
        _isBottomLayerSupportRefresh = YES;
        _isUpperLayerSupportRefresh = YES;
    }
    return self;
}
- (void)lgBottomLayerScrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (_showLog) {
        NSLog(@"LGScrollViewController==>scrollView的偏移量：===%f", contentOffsetY);
    }
    if (_bottomLayerCanMove == NO && !_isUpperLayerCanRefresh) {///悬停状态
        [scrollView setContentOffset:CGPointMake(0, _maxOffsetY)];
        return;
    }
    
    if (contentOffsetY <= 0) {///底部视图滚到最上面，可以进行刷新操作，此时，上层视图可以滑动刷新
        _upperLayerCanMove = _isUpperLayerSupportRefresh;
        _bottomLayerCanMove = NO;
        _isUpperLayerCanRefresh = YES;
    }else if (0 < contentOffsetY && contentOffsetY < _maxOffsetY){///底部滑动，未到达悬停状态
        _upperLayerCanMove = NO;
        _bottomLayerCanMove = YES;
        _isUpperLayerCanRefresh = NO;
    }else if (contentOffsetY >= _maxOffsetY) {///底部滑动，到达悬停状态==>底部停止滑动，上部视图开始滑动
        if (_showLog) {
            NSLog(@"到达悬停位置，底部滚动停止！！！==>%f", _maxOffsetY);
        }
        [scrollView setContentOffset:CGPointMake(0, _maxOffsetY)]; //设置最大偏移
        _upperLayerCanMove = YES;
        _bottomLayerCanMove = NO;
        _isUpperLayerCanRefresh = NO;
    }
}
- (void)lgUpperLayerScrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (_isBottomLayerSupportRefresh) {
        if (offsetY >= 0) {//////当上层视图停止刷新数据时，底层视图可以下拉刷新
            _bottomLayerScrollView.bounces = YES;
        }else{
            _bottomLayerScrollView.bounces = NO;///当上层视图尝试刷新数据时，底层视图禁止下拉刷新
        }
    }else{
        _bottomLayerScrollView.bounces = _isBottomLayerSupportRefresh;
    }
    
    if (_showLog) {
        NSLog(@"LGScrollView==>scrollView的偏移量：===%f", offsetY);
    }
    if (_upperLayerCanMove == NO) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
    
    if (!_isUpperLayerCanRefresh) {///下拉上层视图两种情况，如果是悬停后，下拉，则是滑动底层视图。如果底层视图置顶时，下滑，为刷新操作。
        if (offsetY <= 0) {
            _bottomLayerCanMove = YES;
            _upperLayerCanMove = YES;
        }
    }
}
@end
