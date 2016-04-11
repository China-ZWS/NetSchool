//
//  PublicListController.h
//  NetSchool
//
//  Created by 周文松 on 15/9/1.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PJTableViewController.h"
#import "AppDelegate.h"

@interface ListTableViewController : PJTableViewController
- (void)requestWithServlet:(NSString *)servlet parameter:(id)parameter;
- (void)coreDataSave:(id)datas;
- (NSArray *)coreDataQuery;
- (BOOL)coreDataUpdate:(id)datas;

@end

@interface DoubleListController : ListTableViewController
@end

#import "FreeList.h"
@interface SingleListController : ListTableViewController
@end