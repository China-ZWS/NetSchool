//
//  FreeList3ViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/2.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "FreeList3ViewController.h"
#import "PJTableViewCell.h"
#import "AppDelegate.h"
#import "FreeVideo.h"
#import "PlayerViewController.h"
#import "PlayNavigationController.h"

@interface FreeClasslist : PJTableViewCell

@end

@implementation FreeClasslist


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.imageView.image = [UIImage imageNamed:@"filetype_1.png"];
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = CustomBlack;
        self.textLabel.numberOfLines = 0;
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palyico2.png"]];
        self.accessoryView = view;
        
        _title = [UILabel new];
        _title.font = NFont(12);
        _title.textColor = CustomBlue;
        _title.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_title];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + kDefaultInset.left, 0, DeviceW - (CGRectGetMaxX(self.imageView.frame) + 25 + 35 + kDefaultInset.right * 2 ), 55);
    self.accessoryView.frame = CGRectMake(DeviceW - 25 - kDefaultInset.left, (55 - 25) / 2, 25, 25);
    _title.frame = CGRectMake(CGRectGetMinX(self.accessoryView.frame) - 35, 0, 35, 55);
    _title.text = @"在线";
}

- (void)setDatas:(id)datas
{
    self.textLabel.text = datas[@"name"];
}
@end


@interface FreeList3ViewController ()
@end

@implementation FreeList3ViewController


- (id)initWithParameters:(id)parameters;
{
    if ((self = [super initWithParameters:parameters])) {
        [self.navigationItem setNewTitle:parameters[@"name"]];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
    }
    return self;
}

- (void)back
{
    [self popViewController];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.table.header beginRefreshing];
}


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
    FreeClasslist *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[FreeClasslist alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.datas = _datas[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerViewController *play = [[PlayerViewController alloc] initWithParameters:_datas[indexPath.row]];
    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithRootViewController:play];;
    
    [self presentViewController:nav];
}


- (void)loadNewData;
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    if (app->_networkStatus == NotReachable)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadDatas:[self coreDataQuery]];
        });
        
        return;
    }

    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    params[@"classId"] = _parameters[@"id"];
    params[@"free"] = [NSNumber numberWithBool:1];
    [params setPublicDomain];
  
    _connection = [BaseModel POST:URL(@"api/m/lessons") parameter:params class:[BaseModel class]
                          success:^(id data)
                   {
                       
                       [self loadDatas:data[@"data"]];
                       if (![self coreDataUpdate:data[@"data"]])
                           [self coreDataSave:data[@"data"]];
                   }
                          failure:^(NSString *msg, NSString *state)
                   {
                       [self.view makeToast:msg];
                       [self.table.header endRefreshing];
                   }];
    
}

- (void)loadDatas:(id)datas
{
    _datas = datas;
    [self.table.header endRefreshing];
    [self reloadTabData];
    
    
}


- (NSArray *)coreDataQuery
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* free1=[NSEntityDescription entityForName:@"FreeVideo" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:free1];
    
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"pid == %@",_parameters[@"id"]];
    [request setPredicate:predicate];
    
    
    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
    
    
    if (mutableFetchResult==nil)
    {
        NSLog(@"Error:%@",error);
    }
    else if (!mutableFetchResult.count)
    {
        return nil;
    }

    FreeVideo *model = (FreeVideo *)mutableFetchResult[0];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:model.datas] ;
}


- (void)coreDataSave:(id)datas
{
    if (![datas isKindOfClass:[NSArray class]] || ![datas count]) return; //非数组
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    FreeVideo *free = (FreeVideo *)[NSEntityDescription insertNewObjectForEntityForName:@"FreeVideo" inManagedObjectContext:app.managedObjectContext];
    free.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
    free.pid = _parameters[@"id"];
    NSError* error;
    BOOL isSaveSuccess=[app.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
}

- (BOOL)coreDataUpdate:(id)datas;
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"FreeVideo" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:user];
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"pid == %@",_parameters[@"id"]];
    [request setPredicate:predicate];
    
    
    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
    if (mutableFetchResult==nil)
    {
        NSLog(@"Error:%@",error);
    }
    
    NSLog(@"The count of entry: %i",[mutableFetchResult count]);
    //更新age后要进行保存，否则没更新
    
    for (FreeVideo *vedio in mutableFetchResult)
    {
        vedio.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
        vedio.pid = _parameters[@"id"];
        [app.managedObjectContext save:&error];
        return YES;
    }
    return NO;
    
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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
