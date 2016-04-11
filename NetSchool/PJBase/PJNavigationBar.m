//
//  PJNavigationBar.m
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PJNavigationBar.h"

@implementation PJNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.barTintColor = CustomBlue;
        self.translucent = NO;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.barTintColor = CustomBlue;
        self.translucent = NO;

    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
