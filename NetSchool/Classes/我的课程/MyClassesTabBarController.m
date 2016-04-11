//
//  MyClassesTabBarController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/31.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "MyClassesTabBarController.h"
#import "DataConfigManager.h"
#import "OnLineList0ViewController.h"
#import "LocalManagement.h"
#import "PlayRecordViewController.h"
#import "PJNavigationBar.h"
#import "BaseNavigationController.h"
#import "FreeList0ViewController.h"




@interface MyClassesTabBarController ()
<UITabBarControllerDelegate>
{
    NSArray *_tabConfigList;
}
@end

@implementation MyClassesTabBarController

- (id)init
{
    if ((self = [super init])) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - 设备bar背景颜色
- (UIImage *)createTabBarBk
{
    UIImage *image = [UIImage imageNamed:@"tabBar_back"];
    CGFloat top = 3; // 顶端盖高度
    CGFloat bottom = 1 ; // 底端盖高度
    CGFloat left = 1; // 左端盖宽度
    CGFloat right = 1; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    image = [image resizableImageWithCapInsets:insets ];
    
    return image;
}

- (NSArray *)createTabItemArr
{
    _tabConfigList = [DataConfigManager getTabList];
    NSMutableArray *item = [NSMutableArray array];
    MyClassesTabBarController __weak*safeSelf = self;
    for (int i = 0; i < _tabConfigList.count; i ++)
    {
        switch (i) {
            case 0:
            {
                OnLineList0ViewController *item0 = [[OnLineList0ViewController alloc] initWithBack:^{
                    [safeSelf.navigationController popViewControllerAnimated:YES];
                }];
                 BaseNavigationController*nav = [[BaseNavigationController alloc] initWithNavigationBarClass:[PJNavigationBar class] toolbarClass:nil];
                nav.viewControllers = @[item0];
                
                [item addObject:nav];
            }
                break;
            case 1:
            {
                
                NSArray *controllers = @[[DownloadingController new],[DownloadedController new]];
                LocalManagement *item1 = [[LocalManagement alloc] initWithViewControllers:controllers back:^{
                    [safeSelf.navigationController popViewControllerAnimated:YES];
                }];
                BaseNavigationController *nav = [[BaseNavigationController alloc] initWithNavigationBarClass:[PJNavigationBar class] toolbarClass:nil];
                nav.viewControllers = @[item1];
                [item addObject:nav];
            }
                break;
            case 2:
            {
                PlayRecordViewController *item2 = [[PlayRecordViewController alloc] initWithBack:^{
                    [safeSelf.navigationController popViewControllerAnimated:YES];
                }];
                BaseNavigationController *nav = [[BaseNavigationController alloc] initWithNavigationBarClass:[PJNavigationBar class] toolbarClass:nil];
                nav.viewControllers = @[item2];
                [item addObject:nav];
                
            }
                break;
             default:
                break;
        }
        
    }
    return item;
}

- (void)createTabItemBk:(NSInteger)items;
{
    
    for (int i = 0; i < items; i ++)
    {
        NSDictionary *dict = [_tabConfigList objectAtIndex:i];
        [[self.tabBar.items objectAtIndex:i] setFinishedSelectedImage:[[UIImage imageNamed:[dict objectForKey:@"highlightedImage"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]  withFinishedUnselectedImage:[[UIImage imageNamed:[dict objectForKey:@"image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]];
        
        
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:i] setTitle:[dict objectForKey:@"title"]];
//        RGBA(23, 103, 223, 1)
        [[self.tabBar.items objectAtIndex:i] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:CustomBlue,NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:12],NSFontAttributeName,nil] forState:UIControlStateNormal];
        
        [[self.tabBar.items objectAtIndex:i] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:12],NSFontAttributeName,nil] forState:UIControlStateSelected];
        
        /* You may specify the font, text color, text shadow color, and text shadow offset for the title in the text attributes dictionary, using the keys found in UIStringDrawing.h. */
        //        - (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
        //        其中作为attributes的字典参数，要获取有哪些可以的话可以参照下面这句。
        //        [self.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] } forState:UIControlStateNormal];
        //        [NSValue valueWithCGSize:CGSizeMake(0.5, .5)] , UITextAttributeTextShadowOffset ,kUIColorFromRGB(0xFFFFFF) ,UITextAttributeTextShadowColor ,
        //        这里是修改颜色的，你可以用UITextAttributeFont来修改字体。
        
    }
    self.tabBar.selectionIndicatorImage = [[NSObject drawrWithImage:CGSizeMake(CGRectGetWidth(self.tabBar.frame) / _tabConfigList.count, CGRectGetHeight(self.tabBar.frame)) backgroundColor:CustomBlue] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBar setBackgroundImage:[self createTabBarBk] ];    /*设置Bar的背景颜色*/
    self.viewControllers = [self createTabItemArr];     /*设置Bar的items*/
    [self createTabItemBk:self.viewControllers.count];     /*设置Bar的item的背景及Title*/
    //    self.selectedIndex = 0;     /*设置Bar的第一个item*/
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
