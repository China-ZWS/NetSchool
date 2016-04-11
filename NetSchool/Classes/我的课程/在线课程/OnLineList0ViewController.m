//
//  OnLineList0ViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/31.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "OnLineList0ViewController.h"
#import "OnLineList1ViewController.h"
#import "MyClass.h"

@interface OnLineList0ViewController ()
{
    void (^_back)();
}
@end

@implementation OnLineList0ViewController


- (id)initWithBack:(void (^)())back
{
    if ((self = [super init])) {
        _back = back;
        [self.navigationItem setNewTitle:@"在线课程"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
    }
    return self;
}


- (id)init
{
    if ((self = [super init])) {
        [self.navigationItem setNewTitle:@"在线课程"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
    }
    return self;
}

- (void)back
{
    if (_back) {
        _back();
    }
    else
    {
        [self popViewController];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushViewController:[[OnLineList1ViewController alloc] initWithParameters:_datas[indexPath.section][@"children"][indexPath.row]]];
}



- (void)requestWithServlet:(NSString *)servlet parameter:(id)parameter
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    [params setPublicDomain];
    
    [super requestWithServlet:@"api/m/courses" parameter:params];
}


- (NSArray *)coreDataQuery
{
    return [MyClass coreDataQuery];
}

- (void)coreDataSave:(id)datas
{
    [MyClass coreDataSave:datas];
}


- (BOOL)coreDataUpdate:(id)datas;
{
   return [MyClass coreDataUpdate:datas predicateDatas:_parameters];
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
