//
//  PlayRecordViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/31.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PlayRecordViewController.h"
#import "PlayRecord.h"
#import "PJTableViewCell.h"

@interface PlayRecordCell : PJTableViewCell

@end

@implementation PlayRecordCell

- (void)drawRect:(CGRect)rect
{}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
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

-(NSString*)convertMovieTimeToText:(CGFloat)time{
    int m = (int)(time/60);
    int s = (int) ((time/60 - m)*60);
    return [NSString stringWithFormat:@"%02d:%02d ",m,s];
}


- (void)setDatas:(id)datas
{
    _datas = datas;
    PlayRecord *record = (PlayRecord *)datas;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:record.datas options:kNilOptions error:nil];
    self.textLabel.text = dic[@"name"];
    self.detailTextLabel.text = [@"学习时间：" stringByAppendingString:[NSObject compareCurrentTimeToPastTime:record.lastTime]];
    _title.text = [@"已学习到:" stringByAppendingString:[self convertMovieTimeToText:[record.seekToTime floatValue]]];
    _abstracts.text = @"继续播放 >>>";
}

@end

#import "PlayerViewController.h"
#import "PlayNavigationController.h"

@interface PlayRecordViewController ()
{
    void (^_back)();
    NSMutableArray *_datas;
    UIButton *_rightBtn;
}
@end

@implementation PlayRecordViewController



- (id)initWithBack:(void(^)())back;
{
    if ((self = [super init])) {
        _back = back;
        [self.navigationItem setNewTitle:@"播放记录"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
        _rightBtn = [self.navigationItem setRightItemWithTarget:self title:@"编辑" action:@selector(eventWithEdit:) image:nil];
        [_rightBtn setTitle:@"完成" forState:UIControlStateSelected];

    }
    return self;
}

- (id)init
{
    if ((self = [super init])) {
        [self.navigationItem setNewTitle:@"播放记录"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
        _rightBtn = [self.navigationItem setRightItemWithTarget:self title:@"编辑" action:@selector(eventWithEdit:) image:nil];
        [_rightBtn setTitle:@"完成" forState:UIControlStateSelected];
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

-(NSString*)convertMovieTimeToText:(CGFloat)time{
    int m = (int)(time/60);
    int s = (int) ((time/60 - m)*60);
    return [NSString stringWithFormat:@"%02d:%02d ",m,s];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayRecord *record = _datas[indexPath.row];

    NSString *time = [@"以学习到:" stringByAppendingString:[self convertMovieTimeToText:[record.seekToTime floatValue]]];
    CGSize timeSize = [NSObject getSizeWithText:time font:NFont(14) maxSize:CGSizeMake(200, NFont(14).lineHeight)];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:record.datas options:kNilOptions error:nil];
    CGSize titleSize = [NSObject getSizeWithText:dic[@"name"] font:NFont(17) maxSize:CGSizeMake(DeviceW - kDefaultInset.left * 4 - timeSize.width, MAXFLOAT)];
    
    
    return kDefaultInset.top * 3 + titleSize.height + NFont(14).lineHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    PlayRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PlayRecordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.datas = _datas[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayRecord *record = _datas[indexPath.row];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:record.datas options:kNilOptions error:nil];
    PlayerViewController *play = [[PlayerViewController alloc] initWithParameters:dic];
    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithRootViewController:play];;
    [self presentViewController:nav];
}


#pragma mark ---deit delete---
//  指定哪一行可以编辑 哪行不能编辑
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//  设置 哪一行的编辑按钮 状态 指定编辑样式
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// 判断点击按钮的样式 来去做添加 或删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    PlayRecord *record = _datas[indexPath.row];
    [PlayRecord removeRecod:record.sid];
    [_datas removeObjectAtIndex:indexPath.row];

    NSArray *indexPaths = @[indexPath]; // 构建 索引处的行数 的数组
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    if (!_datas.count) {
        [_rightBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


- (void)loadNewData{
    dispatch_async(dispatch_get_main_queue(), ^{
        _datas = [PlayRecord readRecod];
        [self reloadTabData];
        [self.table.header endRefreshing];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.table.header beginRefreshing];
}

- (void)eventWithEdit:(UIButton *)button
{
    if (!_datas.count)
        button.selected = NO;
    else
        button.selected = !button.selected;

    [_table setEditing: button.selected animated:YES];
    for (PlayRecordCell *cell in _table.visibleCells)
    {
        if (button.selected) {
            cell.title.hidden = cell.abstracts.hidden = YES;
        }
        else
        {
            cell.title.hidden = cell.abstracts.hidden = NO;
        }
    }
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
