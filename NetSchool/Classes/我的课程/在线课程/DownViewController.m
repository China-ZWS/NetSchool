//
//  DownViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/10.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "DownViewController.h"
#include "PJTableViewCell.h"
#import "DownloadSinglecase.h"

@interface DownCell : PJTableViewCell
@property (nonatomic, strong) UIButton *acc;
@property (nonatomic, strong) id downDatas;
@property (nonatomic, strong) id undownDatas;
- (void)setDownDatas:(id)downDatas hasDatas:(BOOL)hasDatas;
- (void)setUndownDatas:(id)undownDatas hasDatas:(BOOL)hasDatas;

@end

@implementation DownCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.textLabel.numberOfLines = 0;
        _acc = [UIButton buttonWithType:UIButtonTypeCustom];
        [_acc setBackgroundImage:[UIImage imageNamed:@"listCheckboxPress.png"] forState:UIControlStateSelected];
        [_acc setBackgroundImage:[UIImage imageNamed:@"listCheckbox.png"] forState:UIControlStateNormal];

        [self.contentView addSubview:_acc];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake( kDefaultInset.left * 2, 0, DeviceW - (CGRectGetMaxX(self.imageView.frame) + 25 + 35 + kDefaultInset.right * 2 ), 55);
    _acc.frame = CGRectMake(DeviceW - 25 - kDefaultInset.left, (55 - 25) / 2, 25, 25);

}


- (void)setDownDatas:(id)downDatas hasDatas:(BOOL)hasDatas
{
    if (hasDatas) {
        _acc.hidden = NO;
        self.textLabel.text = downDatas[@"name"];
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = CustomBlack;
    }
    else
    {
        _acc.hidden = YES;
        self.textLabel.text = @"班级课程正在下载或已全部下载完!";
        self.textLabel.font = NFont(15);
        self.textLabel.textColor = [UIColor blackColor];

    }
    
}

- (void)setUndownDatas:(id)undownDatas hasDatas:(BOOL)hasDatas
{

    _acc.hidden = YES;
    if (hasDatas) {
        self.textLabel.text = undownDatas[@"name"];
        self.textLabel.font = NFont(17);
        self.textLabel.textColor = CustomBlack;
    }
    else
    {
        self.textLabel.text = @"暂时没有下载课程!";
        self.textLabel.font = NFont(15);
        self.textLabel.textColor = [UIColor blackColor];
    }
}

@end

@interface DownViewController ()
{
    NSMutableArray *_downloadDatas;
}
@property (nonatomic, strong)UIButton *done;
@property (nonatomic, strong) UILabel *show;
@end

@implementation DownViewController

- (UIView *)layoutFooter
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, DeviceH - 55, DeviceW, 55)];
    footer.backgroundColor = CustomGray;
    return footer;
}

- (id)initWithParameters:(id)parameters
{
    if ((self = [super initWithParameters:parameters]))
    {
        [self.navigationItem setNewTitle:@"下 载"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
        _downloadDatas = [NSMutableArray array];
        _datas = [[DownloadSinglecase sharedDownloadSinglecase] sortWithDowningDatas:parameters];
//        _parameters = @[@{@"name":@"1"},@{@"name":@"2"},@{@"name":@"3"},@{@"name":@"4"},@{@"name":@"5"},@{@"name":@"6"},@{@"name":@"7"},@{@"name":@"8"},@{@"name":@"9"},@{@"name":@"10"},@{@"name":@"11"},@{@"name":@"12"},@{@"name":@"13"},@{@"name":@"14"},@{@"name":@"15"},@{@"name":@"16"},@{@"name":@"17"},@{@"name":@"18"},@{@"name":@"19"},@{@"name":@"20"}];
    }
    return self;
}

- (void)back
{
    [self dismissViewController];
}

- (UILabel *)show
{
    if (!_show) {
        _show = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultInset.left * 2 , 0, DeviceW - kDefaultInset.left * 4 - 50, CGRectGetHeight(self.navigationController.toolbar.frame))];
        _show.font = NFont(13);
        _show.textColor = CustomGray;
        _show.attributedText = [self setToolText];
    }
    return _show;
}

- (UIButton *)done
{
    if (!_done) {
        _done = [UIButton buttonWithType:UIButtonTypeCustom];
        _done.frame = CGRectMake(DeviceW - kDefaultInset.left * 2 - 50, (CGRectGetHeight(self.navigationController.toolbar.frame) - 35) / 2, 50, 35);
        _done.backgroundColor = CustomBlue;
        [_done setTitle:@"完 成" forState:UIControlStateNormal];
        [_done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_done addTarget:self action:@selector(eventWithDone) forControlEvents:UIControlEventTouchUpInside];
        [_done getCornerRadius:3 borderColor:[UIColor clearColor] borderWidth:0 masksToBounds:YES];
    }
    return _done;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.toolbar addSubview:self.show];
    [self.navigationController.toolbar addSubview:self.done];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_datas count];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerView = [UILabel new];
    headerView.font = NFont(15);
    headerView.backgroundColor = RGBA(110, 110, 110, .5);
    headerView.textColor = [UIColor whiteColor];
    if (section == 0) {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"可下载"];
        NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
        style.firstLineHeadIndent = kDefaultInset.left;
        [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, 3)];
        headerView.attributedText = attrString;
    }
    else
    {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"已下载或下载中"];
        NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
        style.firstLineHeadIndent = kDefaultInset.left;
        [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, 7)];
        headerView.attributedText = attrString;
    }
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_datas[section] count] == 0) {
        return 1;
    }
    return [_datas[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    DownCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[DownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if ([_datas[indexPath.section] count])
        {
            [cell setDownDatas:_datas[indexPath.section][indexPath.row] hasDatas:YES];//有数据
            if ([_downloadDatas containsObject:_datas[indexPath.section][indexPath.row]])
            {
                cell.acc.selected = YES;
            }
            else
            {
                cell.acc.selected = NO;
            }
        }
        else
        {
            [cell setDownDatas:nil hasDatas:NO];// 没有数据

        }

    }
    else
    {
        if ([_datas[indexPath.section] count]) {
            [cell setUndownDatas:_datas[indexPath.section][indexPath.row] hasDatas:YES];
        }
        else
        {
            [cell setUndownDatas:nil hasDatas:NO];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if ([_datas[indexPath.section] count]) {
            DownCell *cell = (DownCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.acc.selected = !cell.acc.selected;
            if ([_downloadDatas containsObject:_datas[indexPath.section][indexPath.row]])
            {
                [_downloadDatas removeObject:_datas[indexPath.section][indexPath.row]];
                
            }
            else
            {
                [_downloadDatas addObject:_datas[indexPath.section][indexPath.row]];
            }
            
            _show.attributedText = [self setToolText];
        }
    }
    
}

- (void)eventWithDone
{
    [self.view makeToast:@"添加下载成功" duration:1.0 position:@"center"];
    [[DownloadSinglecase sharedDownloadSinglecase] beginRequest:_downloadDatas isBeginDown:YES];
    [_downloadDatas removeAllObjects];
    _show.attributedText = [self setToolText];
    _datas = [[DownloadSinglecase sharedDownloadSinglecase] sortWithDowningDatas:_parameters];
    [self reloadTabData];
}

- (NSMutableAttributedString *)setToolText
{
    NSMutableAttributedString *attTitle =  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已选%d节课程，%@",_downloadDatas.count,[NSObject usedSpaceAndfreeSpace]]];
    NSUInteger len = (_downloadDatas.count>9)?2:1;
    [attTitle addAttribute:NSForegroundColorAttributeName value:CustomBlue range:NSMakeRange(2, len)];
    [attTitle addAttribute:NSFontAttributeName value:NFont(15) range:NSMakeRange(2, len)];
    

    return attTitle;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController  setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController  setToolbarHidden:YES animated:YES];
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
