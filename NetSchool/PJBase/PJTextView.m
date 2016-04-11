//
//  PJTextView.m
//  NetSchool
//
//  Created by 周文松 on 15/9/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PJTextView.h"

@implementation PJTextView

- (void)drawRect:(CGRect)rect
{
    [self drawCellWithRound:rect cellStyle:kRoundCell inset:UIEdgeInsetsMake(.5, .5, .5, .5) radius:0 lineWidth:.5 lineColor:CustomGray backgroundColor:[UIColor whiteColor]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
