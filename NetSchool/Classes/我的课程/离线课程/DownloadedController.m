//
//  DownloadedController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/12.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "DownloadedController.h"
#import "PJTableViewCell.h"
#import "DownloadSinglecase.h"
#import "PlayerViewController.h"
#import "PlayNavigationController.h"

@interface DownloadedCell: PJTableViewCell

@end

@implementation DownloadedCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.imageView.image = [UIImage imageNamed:@"filetype_1.png"];
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = CustomBlack;
        self.textLabel.numberOfLines = 0;
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palyico2.png"]];
        self.accessoryView = view;
        
        self.detailTextLabel.font = NFont(12);
        self.detailTextLabel.textColor = CustomBlue;
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + kDefaultInset.left, 0, DeviceW - (CGRectGetMaxX(self.imageView.frame) + 25 + 35 + kDefaultInset.right * 2 ), 55);
    self.accessoryView.frame = CGRectMake(DeviceW - 25 - kDefaultInset.left, (55 - 25) / 2, 25, 25);
    self.detailTextLabel.frame = CGRectMake(CGRectGetMinX(self.accessoryView.frame) - 35, 0, 35, 55);
}


- (void)setDatas:(id)datas
{
    self.textLabel.text = datas[@"name"];
    self.detailTextLabel.text = @"本地";

}

@end

@interface DownloadedController ()

@end

@implementation DownloadedController

- (id)init
{
    if ((self = [super init])) {
        self.title = @"下载完成";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _table.allowsSelectionDuringEditing = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DownloadSinglecase sharedDownloadSinglecase].finishedList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    DownloadedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[DownloadedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.datas = [DownloadSinglecase sharedDownloadSinglecase].finishedList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        return;
    }
    PlayerViewController *play = [[PlayerViewController alloc] initWithParameters:[DownloadSinglecase sharedDownloadSinglecase].finishedList[indexPath.row]];
    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithRootViewController:play];;
    [self presentViewController:nav];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshWithViews
{
    [self reloadTabData];
}

- (BOOL)eventWithEdit:(BOOL)hasEdit;
{
    
    if (hasEdit) {
        if ([DownloadSinglecase sharedDownloadSinglecase].finishedList.count) {
            [_table setEditing:hasEdit animated:YES];
            return hasEdit;
        }
        return !hasEdit;
    }
    [_table setEditing:hasEdit animated:YES];
    return hasEdit;
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
    //删除mp4 文件
    NSString *mp4File = [DownloadSinglecase sharedDownloadSinglecase].finishedList[indexPath.row][@"videoUrl"];
    [[DownloadSinglecase sharedDownloadSinglecase].finishedList removeObjectAtIndex:indexPath.row];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if([fileManager fileExistsAtPath:mp4File])//如果存在视频文件
    {
        [fileManager removeItemAtPath:mp4File error:&error];
    }
    
    NSArray *indexPaths = @[indexPath]; // 构建 索引处的行数 的数组
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    NSNotificationPost(RefreshWithViews, nil, nil);
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
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
