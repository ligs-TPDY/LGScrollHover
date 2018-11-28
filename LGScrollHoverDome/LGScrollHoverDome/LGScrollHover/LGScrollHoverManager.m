//
//  LGScrollViewController.m
//  scroll嵌套Table+悬停效果
//
//  Created by carnet on 2018/10/23.
//  Copyright © 2018年 IAPTest. All rights reserved.
//

//////////////////////////////////////---定义key---////////////////////////////////////////
NSString * const TEST = @"test";
NSString * const TEST2 = @"test2";
//////////////////////////////////////////////////////////////////////////////////////////

#define lgScreenWidth [UIScreen mainScreen].bounds.size.width
#define lgScreenHeight [UIScreen mainScreen].bounds.size.height

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
    CGFloat _maxOffsetY;///悬浮位置
    CGFloat _bottomLayerScrollViewContentOffsetY;///底部滚动的实时位置
    CGFloat _MiddleLayerScrollViewContentOffsetX;///中部滚动的实时位置
    BOOL _showLog;
    
    ///上层视图是否【可以】下拉刷新
    BOOL _isUpperLayerCanRefresh;
    ///底层ScrollView
    UIScrollView *_bottomLayerScrollView;
    
    ///底层视图是否【支持】下拉刷新
    BOOL _isBottomLayerSupportRefresh;
    ///上层视图是否【支持】下拉刷新
    BOOL _isUpperLayerSupportRefresh;
}
@end

@implementation LGScrollHover

- (void)setBottomLayerSupportRefresh:(BOOL)supportRefresh{
    _isBottomLayerSupportRefresh = supportRefresh;
    _bottomLayerScrollView.bounces = _isBottomLayerSupportRefresh;
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
        _upperLayerCanMove = YES;//最开始的时候是能进行滑动的
        _isUpperLayerCanRefresh = YES;//默认上层视图可以刷新
        _isBottomLayerSupportRefresh = YES;
        _isUpperLayerSupportRefresh = YES;
    }
    return self;
}
///2，底层滚动视图调用
- (void)lgBottomLayerScrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat offsetX = scrollView.contentOffset.x;
    if (_showLog) {
        NSLog(@"BottomLayerScrollView==>scrollView的偏移量Y：===%f", offsetY);
        NSLog(@"BottomLayerScrollView==>scrollView的偏移量X：===%f", offsetX);
    }
    
    {///场景：当左右滑动时，此时如果底部视图也可以上下滑，体验不好，现在要当分类左右滑时，限制底部视图的上下滑。
        NSString *offsetXX =[NSString stringWithFormat:@"%lf",(_MiddleLayerScrollViewContentOffsetX/lgScreenWidth)];
        if ([offsetXX floatValue]==[offsetXX intValue]){
            _bottomLayerScrollViewContentOffsetY =  offsetY;
        }else{
            [scrollView setContentOffset:CGPointMake(0, _bottomLayerScrollViewContentOffsetY)];
        }
    }
    
    
    {
        /**触发悬停的状态：1，底部视图不能滚动
                        2，上层视图不可刷新:因为悬停后，不管上层视图是否支持下拉刷新，下拉上层视图，对应操作都是解除悬停状态
         */
        if (_bottomLayerCanMove == NO && !_isUpperLayerCanRefresh) {///悬停状态
            [scrollView setContentOffset:CGPointMake(0, _maxOffsetY)];
            return;
        }
    }
    
    {
        /**
         状态：底部视图滚动到起始位置或者下拉底部视图
         可以进行的操作：1，底部视图下拉刷新
                      2，上层视图下拉刷新
         */
        if (offsetY <= 0) {
            _upperLayerCanMove = _isUpperLayerSupportRefresh;///如果支持滑动，则上部视图可滑动，反之亦然。
            _bottomLayerCanMove = NO;
            _isUpperLayerCanRefresh = YES;
        }else if (0 < offsetY && offsetY < _maxOffsetY){///底部视图上滑滑动，同时未到达悬停状态
            _upperLayerCanMove = NO;
            _bottomLayerCanMove = YES;
            _isUpperLayerCanRefresh = NO;
        }else if (offsetY >= _maxOffsetY) {///底部滑动，到达悬停状态==>底部停止滑动，上部视图开始滑动
            [scrollView setContentOffset:CGPointMake(0, _maxOffsetY)]; //设置最大偏移
            _upperLayerCanMove = YES;
            _bottomLayerCanMove = NO;
            _isUpperLayerCanRefresh = NO;
            if (_showLog) {
                NSLog(@"到达悬停位置，底部滚动停止！！！==>%f", _maxOffsetY);
            }
        }
    }
    
    if (offsetY >= _maxOffsetY) {
        [self.delegate scrollHoverBottomLayerCanMove:NO upperLayerCanMove:YES];
    }else{
        [self.delegate scrollHoverBottomLayerCanMove:YES upperLayerCanMove:NO];
    }
}
///4，上层滚动视图调用
- (void)lgUpperLayerScrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat offsetX = scrollView.contentOffset.x;
    if (_showLog) {
        NSLog(@"UpperLayerScrollView==>scrollView的偏移量Y：===%f", offsetY);
        NSLog(@"UpperLayerScrollView==>scrollView的偏移量X：===%f", offsetX);
    }
    
    ///状态：_upperLayerCanMovewq为NO时，上层视图不可滚动
    if (_upperLayerCanMove == NO) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
        return;
    }
    
    {///上层视图与底部视图同时支持刷新时，上层视图刷新时，底部视图不可刷新；上层视图不刷新时，底部视图可刷新。
        if (_isBottomLayerSupportRefresh && _isUpperLayerSupportRefresh) {///底层支持刷新时
            if (offsetY >= 0) {//当上层视图停止刷新数据时，底层视图可以下拉刷新
                _bottomLayerScrollView.bounces = YES;
            }else{//当上层视图下拉刷新数据时，底层视图不可以下拉刷新
                _bottomLayerScrollView.bounces = NO;
            }
        }
    }
    
    {
        /**
         状态：下拉上层视图
         可以进行的操作：1，如果是分类悬停后，下拉，则是滑动底层视图。
                      2，如果底层视图置顶时，下滑，为刷新操作。
         */
        if (offsetY <= 0) {
            if (!_isUpperLayerCanRefresh) {///如果是分类悬停后，下拉，则是滑动底层视图。
                _bottomLayerCanMove = YES;
                _upperLayerCanMove = YES;
            }
        }
    }
}
///3，中间左右滚动视图调用
- (void)lgMiddleLayerScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    _MiddleLayerScrollViewContentOffsetX = offsetX;
}
@end
