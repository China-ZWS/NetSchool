//
//  PJTableViewCell.m
//  NetSchool
//
//  Created by 周文松 on 15/9/1.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PJTableViewCell.h"

@implementation PJTableViewCell
- (void)drawRect:(CGRect)rect
{
    [self drawRectWithLine:rect start:CGPointMake(10, CGRectGetHeight(rect) - .3) end:CGPointMake(DeviceH, CGRectGetHeight(rect) - .3) lineColor:CustomGray lineWidth:.3];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
