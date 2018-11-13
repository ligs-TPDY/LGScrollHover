//
//  UITableView+GestureRecognizerTrigger.m
//  qfxtaoguwang
//
//  Created by carnet on 2018/10/23.
//  Copyright © 2018年 qfx. All rights reserved.
//

#import "UITableView+GestureRecognizerTrigger.h"

@implementation UITableView (GestureRecognizerTrigger)
/**
 返回YES，则可以多个手势一起触发方法，返回NO则为互斥（比如外层UIScrollView名为mainScroll内嵌的UIScrollView名为subScroll，当我们拖动subScroll时，mainScroll是不会响应手势的（多个手势默认是互斥的），当下面这个代理返回YES时，subScroll和mainScroll就能同时响应手势，同时滚动，这符合我们这里的需求）
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.tag == 7800) {
        return YES;
    }else{
        return NO;
    }
}
@end
