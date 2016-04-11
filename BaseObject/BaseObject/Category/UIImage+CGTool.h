//
//  UIImage+CGTool.h
//  GrowingSupermarket
//
//  Created by 周文松 on 15-3-24.
//  Copyright (c) 2015年 com.talkweb.Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CGTool)


+ (UIImage *)drawrWithRoundImage:(CGSize)size lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor backgroundColor:(UIColor *)backgroundColor withParam:(CGFloat) inset;

+ (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;

@end
