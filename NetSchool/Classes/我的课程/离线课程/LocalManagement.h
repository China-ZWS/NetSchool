//
//  LocalManagement.h
//  NetSchool
//
//  Created by 周文松 on 15/9/12.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "SideSegmentController.h"
#import "DownloadedController.h"
#import "DownloadingController.h"

@interface LocalManagement : SideSegmentController
- (id)initWithViewControllers:(NSArray *)viewControllers back:(void(^)())back;

@end
