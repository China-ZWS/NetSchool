//
//  MyClass.h
//  NetSchool
//
//  Created by 周文松 on 15/9/18.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MyVideo;

@interface MyClass : NSManagedObject

@property (nonatomic, retain) NSData * datas;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * orderNo;
@property (nonatomic, retain) NSString * pid;
@property (nonatomic, retain) NSString * sid;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) MyVideo *myVideo;
+ (NSArray *)coreDataQuery;
+ (void)coreDataSave:(id)datas;
+ (BOOL)coreDataUpdate:(id)datas predicateDatas:(id)predicateDatas;

@end
