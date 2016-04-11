//
//  PJViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PJViewController.h"
#import "PJNavigationBar.h"

@interface PJViewController ()

@end

@implementation PJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)addNavigationWithPresentViewController:(UIViewController *)viewcontroller;
{
    UINavigationController *nav = [[UINavigationController alloc] initWithNavigationBarClass:[PJNavigationBar class] toolbarClass:nil];
    nav.viewControllers = @[viewcontroller];
    [self presentViewController:nav];
    
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
