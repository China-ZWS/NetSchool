//
//  QADetailViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/10/4.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//


#import "PJTableViewCell.h"


@interface QADetailCell : PJTableViewCell

@end

@implementation QADetailCell

- (void)drawRect:(CGRect)rect
{}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.textLabel.numberOfLines = 0;
        
        self.detailTextLabel.font = NFont(15);
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.numberOfLines = 0;
        
        _title = [UILabel new];
        _title.font = NFont(14);
        _title.textColor = CustomBlack;
        _title.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_title];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(kDefaultInset.left * 2, kDefaultInset.top, DeviceW - kDefaultInset.left * 4, self.textLabel.font.lineHeight);
    CGSize contentSize = [NSObject getSizeWithText:self.detailTextLabel.text font:self.detailTextLabel.font maxSize:CGSizeMake(CGRectGetWidth(self.frame) - kDefaultInset.left * 6, MAXFLOAT)];
    self.detailTextLabel.frame = CGRectMake(kDefaultInset.left * 3, CGRectGetMaxY( self.textLabel.frame) + kDefaultInset.top, contentSize.width, contentSize.height);
    _title.frame = CGRectMake(CGRectGetMinX(self.detailTextLabel.frame), CGRectGetMaxY(self.detailTextLabel.frame) + kDefaultInset.top, CGRectGetWidth(self.textLabel.frame), _title.font.lineHeight);
}

- (void)setDatas:(id)datas
{
    NSString *name = nil;
    NSString *identity = nil;
    if ([datas[@"userName"] isEqualToString:[Infomation readInfo][@"userName" ]]) {
        name = @"我自己";
        identity = @"追问：";
    }
    else
    {
        name = datas[@"userName"];
        identity = @"回答者：";
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",identity,name]];
    [attrString addAttribute:NSForegroundColorAttributeName value:CustomBlack range:NSMakeRange(0,[identity length])];
    [attrString addAttribute:NSFontAttributeName value:NFont(15) range:NSMakeRange(0,[identity length])];
    [attrString addAttribute:NSForegroundColorAttributeName value:CustomBlue range:NSMakeRange([identity length],[name length])];
    [attrString addAttribute:NSFontAttributeName value:NFont(16) range:NSMakeRange([identity length],[name length])];
    self.textLabel.attributedText = attrString;
    self.detailTextLabel.text = datas[@"content"];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *time = [dateFormatter dateFromString:datas[@"createTime"]];
    _title.text = [NSObject compareCurrentTimeToPastTime:time];
}

@end

#import "QADetailViewController.h"
#import "BaseReplyBox.h"

@interface QADetailViewController ()

@end

@implementation QADetailViewController

- (id)initWithParameters:(id)parameters
{
    if ((self = [super initWithParameters:parameters])) {
        [self.navigationItem setNewTitle:@"详 情"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
    }
    return self;
}

- (void)back
{
    [self popViewController];
}

- (UIView *)toolBar
{
    UIButton *tool = [UIButton buttonWithType:UIButtonTypeCustom];
    tool.tag = 1000;
    tool.frame = CGRectMake(kDefaultInset.left, 5, DeviceW - kDefaultInset.left * 2, CGRectGetHeight(self.navigationController.toolbar.frame) - 10);
    [tool getCornerRadius:(CGRectGetHeight(self.navigationController.toolbar.frame) - 10) / 2 borderColor:CustomGray borderWidth:1 masksToBounds:YES];
    [tool setTitle:@"点击回复" forState:UIControlStateNormal];
    [tool setTitleColor:CustomBlack forState:UIControlStateNormal];
    tool.titleLabel.font = NFont(17);
    [tool addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    return tool;
}

- (UIView *)header
{
    UIView *header = [UIView new];
    UILabel *title = [UILabel new];
    title.font = NFont(15);
    title.textColor = CustomBlack;
    title.numberOfLines = 0;
    title.text = _parameters[@"title"];
    
    UILabel *time = [UILabel new];
    time.textAlignment = NSTextAlignmentRight;
    time.textColor = CustomGray;
    time.font = NFont(14);
    
    
    UILabel *content = [UILabel new];
    content.font = NFont(16);
    content.textColor = [UIColor blackColor];
    content.numberOfLines = 0;
    content.text = _parameters[@"content"];
    
    
    
    CGSize titleSize = [NSObject getSizeWithText:title.text font:title.font maxSize:CGSizeMake(DeviceW - kDefaultInset.left * 4, MAXFLOAT)];
    title.frame = CGRectMake((DeviceW - titleSize.width) / 2, kDefaultInset.top, titleSize.width, titleSize.height);
    
    time.frame = CGRectMake(kDefaultInset.left * 2, CGRectGetMaxY(title.frame) + kDefaultInset.top, DeviceW - kDefaultInset.left * 4, time.font.lineHeight);
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:_parameters[@"lastTime"]];
    time.text = [NSString stringWithFormat:@"提问时间:%@",[NSObject compareCurrentTimeToPastTime:date]];
    
    CGSize contentSize= [NSObject getSizeWithText:content.text font:content.font maxSize:CGSizeMake(DeviceW - kDefaultInset.left * 4, MAXFLOAT)];
    content.frame = CGRectMake(kDefaultInset.left * 2, CGRectGetMaxY(time.frame) + kDefaultInset.top, contentSize.width, contentSize.height);
    
    header.frame = CGRectMake(0, 0, DeviceW, CGRectGetMaxY(content.frame) + kDefaultInset.top);
    [header addSubview:title];
    [header addSubview:time];
    [header addSubview:content];
    return header;
    
    
}

- (void)loadView
{
    [super loadView];
    self.navigationController.toolbarHidden = NO;
    [self.navigationController.toolbar addSubview:[self toolBar]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _table.tableHeaderView = [self header];
    _table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [_table.header beginRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *header = [UILabel new];
    header.font = NFont(15);
    header.backgroundColor = RGBA(43, 189, 188, .6);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"回 复"];
    NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
    style.firstLineHeadIndent = kDefaultInset.left * 2;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrString.length)];
    header.attributedText = attrString;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = _datas[indexPath.row];
    
    CGSize contentSize = [NSObject getSizeWithText:dic[@"content"] font:NFont(15) maxSize:CGSizeMake(CGRectGetWidth(tableView.frame) - kDefaultInset.left * 6, MAXFLOAT)];

    return kDefaultInset.top + NFont(17).lineHeight + kDefaultInset.top + contentSize.height + kDefaultInset.top + NFont(14).lineHeight + kDefaultInset.top;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    QADetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[QADetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.datas = _datas[indexPath.row];
    return cell;
}

- (void)loadNewData;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"topicId"] = _parameters[@"id"];
    [params setPublicDomain];

    _connection = [BaseModel POST:URL(@"api/m/aq/details") parameter:params   class:[BaseModel class]
                          success:^(id data)
                   {
                       _datas = [self sortedArray:data[@"data"]];
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
                          NSDate *time1 = [dateFormatter dateFromString:obj1[@"createTime"]];
                          NSDate *time2 = [dateFormatter dateFromString:obj2[@"createTime"]];
                          NSComparisonResult result = [time1 compare:time2];
                          return result == NSOrderedAscending;
                      }];
    return times;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show
{

    [BaseReplyBox showToSuccess:^(NSString *string){
        [MBProgressHUD showMessag:@"提交中..." toView:self.view];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"topicId"] = _parameters[@"id"];
        params[@"content"] = string;
        params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
        [params setPublicDomain];
        _connection = [BaseModel POST:URL(@"api/m/aq/detail/add") parameter:params   class:[BaseModel class]
                              success:^(id data)
                       {
                           [_table.header beginRefreshing];
                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                       }
                              failure:^(NSString *msg, NSString *state)
                       {
                           [self.view makeToast:msg duration:.5 position:@"center"];
                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                       }];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    UIView *subviews  = [self.navigationController.toolbar viewWithTag:1000];
    [subviews removeFromSuperview];
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
