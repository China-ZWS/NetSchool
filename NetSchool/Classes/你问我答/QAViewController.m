//
//  QAViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/31.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "QAViewController.h"

@interface QACell : PJTableViewCell

@end

@implementation QACell

- (void)drawRect:(CGRect)rect
{}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.numberOfLines = 0;
        
        self.detailTextLabel.font = NFont(14);
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = CustomBlack;
        
        _title = [UILabel new];
        _title.font = NFont(14);
        _title.textColor = CustomBlack;
        [self.contentView addSubview:_title];
        
        _abstracts = [UILabel new];
        _abstracts.font = NFont(14);
        _abstracts.textColor = CustomBlue;
        [self.contentView addSubview:_abstracts];


    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize timeSize = [NSObject getSizeWithText:_title.text font:_title.font maxSize:CGSizeMake(200, _title.font.lineHeight)];
    _title.frame = CGRectMake(DeviceW - kDefaultInset.right - timeSize.width, CGRectGetHeight(self.frame) / 2 - kDefaultInset.top / 2 - timeSize.height, timeSize.width, timeSize.height);
    
    CGSize titleSize = [NSObject getSizeWithText:self.textLabel.text font:self.textLabel.font maxSize:CGSizeMake(DeviceW - kDefaultInset.left * 4 - timeSize.width, MAXFLOAT)];
    self.textLabel.frame = CGRectMake( kDefaultInset.left * 2, kDefaultInset.top, titleSize.width, titleSize.height);
    
    CGSize abstractsSize = [NSObject getSizeWithText:_abstracts.text font:_abstracts.font maxSize:CGSizeMake(200, _abstracts.font.lineHeight)];
    _abstracts.frame = CGRectMake(DeviceW - kDefaultInset.right - abstractsSize.width, CGRectGetHeight(self.frame) / 2 + kDefaultInset.top / 2 , abstractsSize.width, abstractsSize.height);
    
    
    self.detailTextLabel.frame = CGRectMake(kDefaultInset.left * 2, CGRectGetMaxY(self.textLabel.frame) + kDefaultInset.top, DeviceW - kDefaultInset.left * 4 - abstractsSize.width, self.detailTextLabel.font.lineHeight);
}

- (void)setDatas:(id)datas
{
    NSString *title = [datas[@"title"] length]?datas[@"title"]:@"（无）";
    self.textLabel.text = title;
    self.detailTextLabel.text = [@"来源：" stringByAppendingString:datas[@"lessonName"]];

    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *time = [dateFormatter dateFromString:datas[@"lastTime"]];
    _title.text = [NSObject compareCurrentTimeToPastTime:time];
    _abstracts.text = @"详情 >>>";

}

@end

#import "AddToQATheme.h"
#import "QADetailViewController.h"

@interface QAViewController ()

@end

@implementation QAViewController


- (id)init
{
    if ((self = [super init]))
    {
        [self.navigationItem setNewTitle:@"你问我答"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
        [self.navigationItem setRightItemWithTarget:self title:@"提问" action:@selector(eventWithRight) image:nil];
    }
    return self;
}

- (void)back
{
    [self popViewController];
}

- (void)eventWithRight
{
    [self pushViewController:[[AddToQATheme alloc] initWithSuccess:^{
        [_table.header beginRefreshing];
    }]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [_table.header beginRefreshing];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *datas = _datas[indexPath.row];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:datas[@"lastTime"]];
    NSString *time = [@"提问时间:" stringByAppendingString:[NSObject compareCurrentTimeToPastTime:date]];
    CGSize timeSize = [NSObject getSizeWithText:time font:NFont(14) maxSize:CGSizeMake(200, NFont(14).lineHeight)];
    NSString *title = [datas[@"title"] length]?datas[@"title"]:@"（无）";
    CGSize titleSize = [NSObject getSizeWithText:title font:NFont(17) maxSize:CGSizeMake(DeviceW - kDefaultInset.left * 4 - timeSize.width, MAXFLOAT)];
    
    return kDefaultInset.top * 3 + titleSize.height + NFont(14).lineHeight;}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    QACell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[QACell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.datas = _datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushViewController:[[QADetailViewController alloc] initWithParameters:_datas[indexPath.row]]];
}

- (void)loadNewData;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    [params setPublicDomain];

    _connection = [BaseModel POST:URL(@"api/m/aq/topics") parameter:params   class:[BaseModel class]
                          success:^(id data)
                   {
                       _datas = [self sortedArray:data[@"data"]] ;
                       
                       [self reloadTabData];
                       [_table.header endRefreshing];
                   }
                          failure:^(NSString *msg, NSString *state)
                   {
                       [self.view makeToast:msg];
                       [_table.header endRefreshing];
                   }];

}

- (NSArray *)sortedArray:(NSArray *)datas
{
    NSArray *times = [datas sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2)
                      {
                          NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                          [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                          NSDate *time1 = [dateFormatter dateFromString:obj1[@"lastTime"]];
                          NSDate *time2 = [dateFormatter dateFromString:obj2[@"lastTime"]];
                          NSComparisonResult result = [time1 compare:time2];
                          return result == NSOrderedAscending;
                      }];
    return times;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
