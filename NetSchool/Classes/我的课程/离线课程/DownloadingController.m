//
//  DownloadingController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/12.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "DownloadingController.h"
#import "DownloadSinglecase.h"
#import "PJTableViewCell.h"
#import "CommonHelper.h"

@interface DownBtn : UIButton

@end

@implementation DownBtn

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Center image
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width/2;
    center.y = self.imageView.frame.size.height/2;
    self.imageView.center = center;
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height + 2;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end

@interface DownloadingCell : PJTableViewCell
@property (nonatomic, strong) DownBtn *status;

@end

@implementation DownloadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.numberOfLines = 0;
        
        _status = [DownBtn buttonWithType:UIButtonTypeCustom];
        _status.titleLabel.font = NFont(12);
        [_status setTitleColor:CustomBlack forState:UIControlStateNormal];
//        _status.backgroundColor = [UIColor redColor];
        self.accessoryView = _status;
//        [self.contentView addSubview:_status];
        
        self.detailTextLabel.font = NFont(14);
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = CustomBlack;
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    _status.frame = CGRectMake(DeviceW - kDefaultInset.left * 2 - 50, (55 - 50) / 2, 50, 50);
    CGSize titleSize = [NSObject getSizeWithText:self.textLabel.text font:self.textLabel.font maxSize:CGSizeMake(CGRectGetMinX(_status.frame) - kDefaultInset.left * 3, MAXFLOAT)];
    self.textLabel.frame = CGRectMake( kDefaultInset.left * 2, kDefaultInset.top, titleSize.width, titleSize.height);
    self.detailTextLabel.frame = CGRectMake(kDefaultInset.left * 2, CGRectGetMaxY(self.textLabel.frame) + kDefaultInset.top, CGRectGetMinX(_status.frame) - kDefaultInset.left * 3, self.detailTextLabel.font.lineHeight);
}

- (void)setDatas:(id)datas
{
    _datas = datas;
    self.textLabel.text = datas[@"name"];

    BOOL isWaiting = [datas[@"isWaiting"] boolValue];
    BOOL isDownloading = [datas[@"isDownloading"] boolValue];
   
    NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",[CommonHelper getFileSizeNumber:datas[@"fileReceivedSize"]] / [CommonHelper getFileSizeNumber:datas[@"fileSize"]] * 100];
    if (![fileCurrentSize integerValue]) {
        fileCurrentSize = @"0";
    }
    self.detailTextLabel.text = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM",[datas[@"fileReceivedSize"] floatValue] / 1024 / 1024,[datas[@"fileSize"] floatValue] / 1024 / 1024],fileCurrentSize ];
    if (isDownloading && !isWaiting)
    {
        [_status setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        [_status setTitle:@"正在下载" forState:UIControlStateNormal];
    }
    else if (!isDownloading && isWaiting)
    {
        [_status setTitle:@"等待中" forState:UIControlStateNormal];
        [_status setImage:[UIImage imageNamed:@"waitButton.png"] forState:UIControlStateNormal];
    }
    else if (!isDownloading && !isWaiting)
    {
        [_status setTitle:@"已暂停" forState:UIControlStateNormal];
        [_status setImage:[UIImage imageNamed:@"downloadButtonNomal.png"] forState:UIControlStateNormal];
    }
}

@end

@interface DownloadingController ()
<DownloadDelegate>

@end

@implementation DownloadingController

- (id)init
{
    if ((self = [super init])) {
        self.title = @"下载中";
    }
    return self;
}

- (void)dealloc
{
    [DownloadSinglecase sharedDownloadSinglecase].downloadDelegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _table.allowsSelectionDuringEditing = YES;
    [DownloadSinglecase sharedDownloadSinglecase].downloadDelegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DownloadSinglecase sharedDownloadSinglecase].downingList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASIHTTPRequest *request = [DownloadSinglecase sharedDownloadSinglecase].downingList[indexPath.row];
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    CGSize titleSize = [NSObject getSizeWithText:fileInfo[@"name"] font:NFont(17) maxSize:CGSizeMake(DeviceW - kDefaultInset.left - 40 - kDefaultInset.left * 3, MAXFLOAT)];

    return kDefaultInset.top * 3 + titleSize.height + NFont(14).lineHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[DownloadingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell.status addTarget:self action:@selector(eventWithDownload:) forControlEvents:UIControlEventTouchUpInside];
    }
    ASIHTTPRequest *request = [DownloadSinglecase sharedDownloadSinglecase].downingList[indexPath.row];
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    cell.datas = fileInfo;
    return cell;
}


#pragma mark -DownloadSinglecaseDelegate
#pragma mark - 下载等待中
-(void)waiting:(ASIHTTPRequest *)request;
{
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
 
    for (DownloadingCell *cell in _table.visibleCells)
    {
        if (cell.datas == fileInfo)
        {
            [cell.status setImage:[UIImage imageNamed:@"waitButton.png"] forState:UIControlStateNormal];
            [cell.status setTitle:@"等待中" forState:UIControlStateNormal];
            NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",[CommonHelper getFileSizeNumber:fileInfo[@"fileReceivedSize"]] / [CommonHelper getFileSizeNumber:fileInfo[@"fileSize"]] * 100];
            if (![fileCurrentSize integerValue]) {
                fileCurrentSize = @"0";
            }
            NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM",[fileInfo[@"fileReceivedSize"] floatValue] / 1024 / 1024,[fileInfo[@"fileSize"] floatValue] / 1024 / 1024],fileCurrentSize ];
            cell.detailTextLabel.text = abstracts;
            
        }
        
    }

}

#pragma mark - 下载开始
-(void)start:(ASIHTTPRequest *)request;
{
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    for (DownloadingCell *cell in _table.visibleCells)
    {
        if (cell.datas == fileInfo)
        {
            [cell.status setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            
            [cell.status setTitle:@"正在下载" forState:UIControlStateNormal];
            NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",[CommonHelper getFileSizeNumber:fileInfo[@"fileReceivedSize"]] / [CommonHelper getFileSizeNumber:fileInfo[@"fileSize"]] * 100];
            NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM",[fileInfo[@"fileReceivedSize"] floatValue] / 1024 / 1024,[fileInfo[@"fileSize"] floatValue] / 1024 / 1024],fileCurrentSize ];
            cell.detailTextLabel.text = abstracts;
            
        }
    }
}

#pragma mark - 下载完成
-(void)failedDownload:(ASIHTTPRequest *)request;
{
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    for (DownloadingCell *cell in _table.visibleCells)
    {
        if (cell.datas == fileInfo)
        {
            [cell.status setImage:[UIImage imageNamed:@"downloadButtonNomal.png"] forState:UIControlStateNormal];
            [cell.status setTitle:@"已暂停" forState:UIControlStateNormal];
            NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",[CommonHelper getFileSizeNumber:fileInfo[@"fileReceivedSize"]] / [CommonHelper getFileSizeNumber:fileInfo[@"fileSize"]] * 100];
            NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM",[fileInfo[@"fileReceivedSize"] floatValue] / 1024 / 1024,[fileInfo[@"fileSize"] floatValue] / 1024 / 1024],fileCurrentSize ];
            cell.detailTextLabel.text = abstracts;
        }
        
    }

}

#pragma mark - 跟新下砸进度
-(void)updateCellProgress:(ASIHTTPRequest *)request;
{
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    
        for (DownloadingCell *cell in _table.visibleCells)
        {
            if (cell.datas == fileInfo)
            {
                NSString *fileCurrentSize = [NSString stringWithFormat:@"%.1f",[CommonHelper getFileSizeNumber:fileInfo[@"fileReceivedSize"]] / [CommonHelper getFileSizeNumber:fileInfo[@"fileSize"]] * 100];
                NSString *abstracts = [NSString stringWithFormat:@"(%@) ----- %@%% ",[NSString stringWithFormat:@"%.1fM/%.1fM",[fileInfo[@"fileReceivedSize"] floatValue] / 1024 / 1024,[fileInfo[@"fileSize"] floatValue] / 1024 / 1024],fileCurrentSize ];
                cell.detailTextLabel.text = abstracts;
            }
        }

}

#pragma mark - 下载完成（这里暂时没有用到）
-(void)finishedDownload:(ASIHTTPRequest *)request;
{

}

- (void)eventWithDownload:(UIButton *)button
{
    DownloadingCell *cell = [self getCell:button];;
    
    ASIHTTPRequest *request = cell.datas[@"request"];
    
    BOOL isWaiting = [cell.datas[@"isWaiting"] boolValue];
    BOOL isDownloading = [cell.datas[@"isDownloading"] boolValue];
  
    if (isDownloading || isWaiting)
    {
        [request cancel];
        request = nil;
    }
    else
    {
        [[DownloadSinglecase sharedDownloadSinglecase] beginRequest:@[cell.datas] isBeginDown:YES];
    }
}

- (DownloadingCell*)getCell:(UIView *)view
{
    for (UIView* next = view; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
       
        if ([nextResponder isKindOfClass:[DownloadingCell
                                          class]])
        {
            return (DownloadingCell*)nextResponder;
        }
    }
    return nil;
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
        if ([DownloadSinglecase sharedDownloadSinglecase].downingList.count) {
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
    ASIHTTPRequest *request = [DownloadSinglecase sharedDownloadSinglecase].downingList[indexPath.row];
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    //删除RTF 文件
    
    NSString *tempRTF = [[DownloadSinglecase sharedDownloadSinglecase].videoTemps stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",fileInfo[@"id"]]];
    NSString *mp4Temp = [[DownloadSinglecase sharedDownloadSinglecase].videoTemps stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4.temp",fileInfo[@"id"]]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if([fileManager fileExistsAtPath:tempRTF])//如果存在临时文件的配置文件
    {
        [fileManager removeItemAtPath:tempRTF error:&error];
    }
    if([fileManager fileExistsAtPath:mp4Temp])//如果存在临时文件的配置文件
    {
        [fileManager removeItemAtPath:mp4Temp error:&error];
    }

    [request cancel];
    request = nil;
    [[DownloadSinglecase sharedDownloadSinglecase].downingList removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = @[indexPath]; // 构建 索引处的行数 的数组
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
