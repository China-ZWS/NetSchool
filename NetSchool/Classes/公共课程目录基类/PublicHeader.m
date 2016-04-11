
//
//  PublicHeader.m
//  NetSchool
//
//  Created by 周文松 on 15/9/1.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PublicHeader.h"

@implementation PublicHeader

- (id)init
{
    if ((self = [super init])) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self drawRectWithLine:rect start:CGPointMake(0, CGRectGetHeight(rect) - .3) end:CGPointMake(DeviceW, CGRectGetHeight(rect) - .3) lineColor:CustomGray lineWidth:.3];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
