//
//  PublicListController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/1.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PublicListController.h"
#import "PublicCell.h"
#import "PublicHeader.h"

@interface ListTableViewController ()
@end
@implementation ListTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.table.header beginRefreshing];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


- (void)loadNewData
{
   
    [self requestWithServlet:@"" parameter:@{}];
}


- (void)requestWithServlet:(NSString *)servlet parameter:(id)parameter;
{
    
}

- (void)coreDataSave:(id)datas;
{
    
}

- (NSArray *)coreDataQuery;
{
    return nil;
}

- (BOOL)coreDataUpdate:(id)datas;
{
    return NO;
}

@end


#pragma mark - 双层
@interface DoubleListController ()
{
    NSMutableArray *_puckerArray;
    NSInteger _currentHeader;
}
@end

@implementation DoubleListController



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_datas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    PublicHeader *header = [PublicHeader buttonWithType:UIButtonTypeCustom];
    header.backgroundColor = [UIColor whiteColor];
    header.tag = section;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, DeviceW - 60, 50)];
    title.font = NFont(17);
    title.text = _datas[section][@"name"];
    [header addSubview:title];
    [header addTarget:self action:@selector(puckerTouches:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *acc = [UIButton buttonWithType:UIButtonTypeCustom];
    acc.frame = CGRectMake(DeviceW - 40, 5, 40, 40);
    [acc setImage:[UIImage imageNamed:@"boss_unipay_ic_arrdown.png"] forState:UIControlStateNormal];
    NSNumber *number = [_puckerArray objectAtIndex:section];
    if ([number boolValue])
    {
            acc.transform = CGAffineTransformIdentity;
    }
    else
    {
            acc.transform = CGAffineTransformMakeRotation(-M_PI);
    }
  
    [header addSubview:acc];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber *number = [_puckerArray objectAtIndex:section];
    if (![number boolValue]) {
        return 0;
    }
    else {
        
        return [_datas[section][@"children"] count];
    }

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    PublicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[PublicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _datas[indexPath.section][@"children"][indexPath.row][@"name"];
    return cell;
}


- (void)requestWithServlet:(NSString *)servlet parameter:(id)parameter
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    if (app->_networkStatus == NotReachable)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self loadDatas:[self coreDataQuery]];
        });

        return;
    }

    _connection = [BaseModel POST:URL(servlet) parameter:parameter   class:[BaseModel class]
                          success:^(id data)
                   {
                       [self loadDatas:data[@"data"]];
                       if (![self coreDataUpdate:data[@"data"]])
                           [self coreDataSave:data[@"data"]];

                   }
                          failure:^(NSString *msg, NSString *state)
                   {
                       [self.view makeToast:msg];
                       [_table.header endRefreshing];
                   }];
}

- (void)loadDatas:(id)datas
{
    NSMutableArray *tree = [NSMutableArray array];
  
    
    for (NSDictionary *dic in datas)
    {
        NSMutableDictionary *dic0 = [NSMutableDictionary dictionaryWithDictionary:dic];
        if ([dic0[@"id"] length] && ![dic0[@"pid"] length])
        {
            NSArray *children = [datas filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pid == %@",dic0[@"id"]]];
            if (children.count) {
                dic0[@"children"] = children;
            }
            else
            {
                dic0[@"children"] = [NSArray arrayWithObject:dic];
            }
            [tree addObject:dic0];
        }
    }
    _datas = tree;
    [self makePuckerArray];
    [_table.header endRefreshing];
    [self reloadTabData];

}


- (void)puckerTouches:(PublicHeader *)button
{
    if (_currentHeader != button.tag)
    {
        NSNumber *number = [_puckerArray objectAtIndex:_currentHeader];
        
        if ([number boolValue])
        {
            [_puckerArray replaceObjectAtIndex:_currentHeader withObject:[NSNumber  numberWithBool:![number boolValue]]];
            
            [_table reloadSections:[NSIndexSet indexSetWithIndex:_currentHeader] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

    }
    NSNumber *number = [_puckerArray objectAtIndex:button.tag];
    
    [_puckerArray replaceObjectAtIndex:button.tag withObject:[NSNumber  numberWithBool:![number boolValue]]];
    
    [_table reloadSections:[NSIndexSet indexSetWithIndex:button.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    _currentHeader = button.tag;

    
}


#pragma mark - 折点数组初始化
-(void)makePuckerArray
{
    if (!_puckerArray)
    {
        _puckerArray = [NSMutableArray array];
    }
    else
    {
        [_puckerArray removeAllObjects];
    }
    for (int i = 0;i < [_datas count];i++) {
        NSNumber *number = [NSNumber numberWithBool:(i == 0?YES:NO)];
        [_puckerArray addObject:number];
    }
    _currentHeader = 0;
    
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

#pragma mark - 单层

@interface SingleListController ()

@end

@implementation SingleListController



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    PublicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[PublicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _datas[indexPath.row][@"name"];
    
    return cell;
}



- (void)requestWithServlet:(NSString *)servlet parameter:(id)parameter
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    if (app->_networkStatus == NotReachable)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadDatas:[self coreDataQuery]];
        });
        
        return;
    }

    _connection = [BaseModel POST:URL(servlet) parameter:parameter   class:[BaseModel class]
                          success:^(id data)
                   {
                       
                       [self loadDatas:data[@"data"]];
                       if (![self coreDataUpdate:data[@"data"]])
                           [self coreDataSave:data[@"data"]];
                       
                       
                   }
                          failure:^(NSString *msg, NSString *state)
                   {
                       [self.view makeToast:msg];
                       [_table.header endRefreshing];
                   }];
    
}

- (void)loadDatas:(id)datas
{
    _datas = datas;
    [_table.header endRefreshing];
    [self reloadTabData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
