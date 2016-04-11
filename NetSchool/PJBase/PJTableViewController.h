//
//  PJTableViewController.h
//  NetSchool
//
//  Created by 周文松 on 15/8/31.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "BaseTableViewController.h"
#import "MJRefresh.h"
#import "MJChiBaoZiHeader.h"

@interface PJTableViewController : BaseTableViewController
{
    NSArray *_datas;
}
@property (nonatomic, strong) NSArray *datas;

@end
