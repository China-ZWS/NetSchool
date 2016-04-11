//
//  PJTextField.m
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PJTextField.h"

@implementation PJTextField


- (void)drawRect:(CGRect)rect
{
    [self drawRectWithLine:rect start:CGPointMake(1, CGRectGetHeight(rect) * 3 / 4) end:CGPointMake(1, CGRectGetHeight(rect) - 1) lineColor:CustomGray lineWidth:.3];
    [self drawRectWithLine:rect start:CGPointMake(CGRectGetWidth(rect) - 1, CGRectGetHeight(rect) * 3 / 4) end:CGPointMake(CGRectGetWidth(rect) - 1, CGRectGetHeight(rect) - 1) lineColor:CustomGray lineWidth:.3];
    [self drawRectWithLine:rect start:CGPointMake(1, CGRectGetHeight(rect) - 1) end:CGPointMake(CGRectGetWidth(rect) - 1, CGRectGetHeight(rect) - 1) lineColor:CustomGray lineWidth:.3];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
