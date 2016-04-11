//
//  UIImage+CGTool.m
//  GrowingSupermarket
//
//  Created by 周文松 on 15-3-24.
//  Copyright (c) 2015年 com.talkweb.Test. All rights reserved.
//

#import "UIImage+CGTool.h"

@implementation UIImage (CGTool)


+ (UIImage *)drawrWithRoundImage:(CGSize)size lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor backgroundColor:(UIColor *)backgroundColor withParam:(CGFloat) inset;
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width,size.height ), NO, 0);
    [backgroundColor setFill];
    [lineColor setStroke];
    
    
    CGContextRef  context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    CGContextSetLineWidth(context,lineWidth);
    CGContextAddEllipseInRect(context, CGRectMake(inset / 2, inset / 2, size.width - inset, size.height - inset));
    CGContextClosePath(context);
    CGContextDrawPath(context,kCGPathFillStroke);
    
    
    UIImage* im = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return im;
}



+ (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset
{
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,2);
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}


@end
