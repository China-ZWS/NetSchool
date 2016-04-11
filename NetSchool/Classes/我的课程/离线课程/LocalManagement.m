//
//  LocalManagement.m
//  NetSchool
//
//  Created by 周文松 on 15/9/12.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "LocalManagement.h"

@interface LocalManagement ()
<SideSegmentControllerDelegate>
{
    BOOL _hasEdit;
    void (^_back)();
    UIButton *_rightBtn;
    UIViewController *_currentController;
}

@end

@implementation LocalManagement

- (id)initWithViewControllers:(NSArray *)viewControllers back:(void(^)())back;
{
    if ((self = [super initWithViewControllers:viewControllers]))
    {
        [self.navigationItem setNewTitle:@"离线课程"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
       _rightBtn = [self.navigationItem setRightItemWithTarget:self title:@"编辑" action:@selector(eventWithEdit) image:nil];
        self.delegate = self;
        _back = back;
    }
    return self;
}

- (void)back
{
    if (_back) {
        _back();
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.backgroudColor = [UIColor whiteColor];
    self.lineColor = CustomBlue;
    self.selectedTitleColor = CustomBlue;
    self.titleColor = CustomGray;
    
    UIImageView *line=[[UIImageView alloc] initWithFrame:CGRectMake(DeviceW/2 - .5, kDefaultInset.top * 1.5, 1, CGRectGetHeight(self.segmentBar.frame) - kDefaultInset.top * 3)];
    [self.segmentBar addSubview:line];
    
    UIGraphicsBeginImageContext(line.frame.size);
    [line.image drawInRect:CGRectMake(0, 0, self.segmentBar.frame.size.width, line.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGRectGetWidth(line.frame));
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 110/255.0, 110/255.0, 110/255.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0, 0);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 0, CGRectGetHeight(line.frame));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    line.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)slideSegment:(UICollectionView *)segmentBar didSelectedViewController:(UIViewController *)viewController;
{
    if ([_currentController isKindOfClass:[DownloadingController class]]) {
        DownloadingController *ctr = (DownloadingController *)_currentController;
         [ctr eventWithEdit:NO];
        
    }
    else
    {
        DownloadedController *ctr = (DownloadedController *)_currentController;
        [ctr eventWithEdit:NO];
    }
    _hasEdit = NO;
    [_rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    _currentController = viewController;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)eventWithEdit
{

    _hasEdit = !_hasEdit;
    
     if ([_currentController isKindOfClass:[DownloadingController class]])
     {
        DownloadingController *ctr = (DownloadingController *)_currentController;
       _hasEdit = [ctr eventWithEdit:_hasEdit];
     }
    else
    {
        DownloadedController *ctr = (DownloadedController *)_currentController;
        _hasEdit = [ctr eventWithEdit:_hasEdit];
    }

    if (_hasEdit)
    {
        [_rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    else
    {
        [_rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    

}

- (void)setFullScreen:(BOOL)fullScreen
 {
     [self.tabBarController.tabBar setHidden:fullScreen];
        // tabBar的隐藏通过在初始化方法中设置hidesBottomBarWhenPushed属性来实现
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
