//
//  UINavigationItem+BaseNavigationItem.m
//  MoodMovie
//
//  Created by 周文松 on 14-8-28.
//  Copyright (c) 2014年 com.talkweb.MoodMovie. All rights reserved.
//

#import "UINavigationItem+BaseNavigationItem.h"
#import "BaseNavBarButtonItem.h"

@implementation UINavigationItem (BaseNavigationItem)
- (void)setNewTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 22, 22);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:19];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    self.titleView = label;
}

- (UIButton *)setRightItemWithTarget:(id)target title:(NSString *)title action:(SEL)action image:(NSString *)image;
{
    BaseNavBarButtonItem *buttonItem = [BaseNavBarButtonItem itemWithTarget:target title:title action:action image:image];
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem.button];
    return buttonItem.button;
}

- (void)setBackItemWithTarget:(id)target title:(NSString *)title  action:(SEL)action image:(NSString *)image;
{
    BaseNavBarButtonItem *buttonItem = [BaseNavBarButtonItem itemWithTarget:target title:nil action:action image:image];
    self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem.button];
//    [self.leftBarButtonItem setBackgroundVerticalPositionAdjustment:-40.0 forBarMetrics:UIBarMetricsDefaultPrompt];
}

- (void)setBackItemWithTargets:(id)target titles:(NSArray *)titles actions:(NSArray *)actions images:(NSArray *)images;
{
    BaseNavBarButtonItem *buttonItem = [BaseNavBarButtonItem itemWithTarget:target titles:titles actions:actions images:images];
    self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem.view];
}

- (void)setRightItemView:(UIView *)view
{
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
}


@end
