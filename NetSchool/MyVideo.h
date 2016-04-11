//
//  MyVideo.h
//  NetSchool
//
//  Created by 周文松 on 15/9/18.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@class MyClass;

@interface MyVideo : NSManagedObject

@property (nonatomic, retain) NSData * datas;
@property (nonatomic, retain) NSString * highVideoUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * orderNo;
@property (nonatomic, retain) NSString * pid;
@property (nonatomic, retain) NSString * sid;
@property (nonatomic, retain) NSString * superVideoUrl;
@property (nonatomic, retain) NSString * videoUrl;
@property (nonatomic, retain) MyClass *myClass;
+ (void)coreDataSave:(id)datas predicateDatas:(id)predicateDatas;
+ (NSArray *)coreDataQuery:(id)predicateDatas;
+ (BOOL)coreDataUpdate:(id)datas predicateDatas:(id)predicateDatas;

@end
