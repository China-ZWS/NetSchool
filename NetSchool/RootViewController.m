//
//  ViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/27.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//




#import "RootViewController.h"
#import "PJCollectionViewCell.h"
#import "DataConfigManager.h"

@interface MainCell :PJCollectionViewCell

@end

@implementation MainCell

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _imageView = [UIImageView new];
        _title = [UILabel new];
        _title.font = Font(17);
        _title.textAlignment = NSTextAlignmentCenter;
        _title.textColor = [UIColor  blackColor];
        
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_title];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = CGRectMake(kDefaultInset.left, kDefaultInset.top, CGRectGetWidth(self.frame) - kDefaultInset.left * 2, CGRectGetWidth(self.frame) - kDefaultInset.left * 2);
    _title.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame) + kDefaultInset.bottom, CGRectGetWidth(self.frame), _title.font.lineHeight);
}

- (void)setDatas:(id)datas
{
    _datas = datas;
    NSString *title = datas[@"title"];
    NSString *image = datas[@"image"];
    
    _imageView.image = [UIImage imageNamed:image];
    _title.text = title;
    
}


@end

@interface RootViewController ()
<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray *_datas;
}

@end

@implementation RootViewController

- (UIButton *)exitView
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 40);
    [btn setTitle:@"切换账号" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = Font( 17);
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [btn addTarget:self action:@selector(back)  forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toplogo.png"]]];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:[self exitView]];
        [self.navigationItem setLeftBarButtonItem:leftButton];
        _datas = [DataConfigManager getMainConfigList];
    }
    return self;
}

- (void)back
{
    [kUserDefaults setValue:[NSNumber numberWithBool:NO] forKey:@"isLogin"];
    [kUserDefaults synchronize];
    [self gotoLoging];
}

- (UICollectionViewFlowLayout *)segmentBarLayout
{
    UICollectionViewFlowLayout *segmentBarLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (DeviceW - ScaleW(100)) / 3;
    segmentBarLayout.itemSize = CGSizeMake(width,width);
    segmentBarLayout.sectionInset = UIEdgeInsetsMake(ScaleW(30), ScaleW(30), ScaleW(30), ScaleW(30));
    segmentBarLayout.minimumLineSpacing = ScaleW(40);
    segmentBarLayout.minimumInteritemSpacing = 0;
    return segmentBarLayout;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:[self segmentBarLayout]];
    collectionView.userInteractionEnabled = YES;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [collectionView registerClass:[MainCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical  = YES;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    

    
}


#pragma mark -- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.datas = _datas[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *datas = _datas[indexPath.row];
    Class class = NSClassFromString(datas[@"class"]);
    id viewController = [class new];
    if (!indexPath.row) {
        [self pushViewController:viewController];
        [self setNavigationBarHidden:YES];
    }
    else
    {
        [self pushViewController:viewController];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self gotoLoging];
    });
}


- (void)gotoLoging
{
    if (![[kUserDefaults objectForKey:@"isLogin"] boolValue])
    {
        [self gotoLogingWithSuccess:^(BOOL isSuccess)
         {
             if (isSuccess)
             {
                 [self.view makeToast:@"登录成功" duration:1 position:@"center"];
             }
         }class:@"LoginViewController"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
