//
//  PlayNavigationController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/5.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PlayNavigationController.h"
#import "AppDelegate.h"

@interface PlayNavigationController ()

@end

@implementation PlayNavigationController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.allowRotation = YES;
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    UIImage *image = [self imageWithColor:RGBA(50, 50, 50, .6) size:CGSizeMake(10, 2)];
    CGFloat top = 1; // 顶端盖高度
    CGFloat bottom = 1 ; // 底端盖高度
    CGFloat left = 1; // 左端盖宽度
    CGFloat right = 1; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    image = [image resizableImageWithCapInsets:insets ];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:image];
    // Do any additional setup after loading the view.
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    @autoreleasepool
    {
        UIGraphicsBeginImageContextWithOptions((CGSize){ 5, 5}, NO, 0.0f);
        
        UIBezierPath* p =  [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 5, 5) cornerRadius:0];
        [color setFill];
        [p fill];

        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.allowRotation = YES;

    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    
    [super viewWillAppear:animated];
  
}

- (void)viewWillDisappear:(BOOL)animated
{

    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.allowRotation = NO;
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
