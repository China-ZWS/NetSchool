//
//  PlayRecord.h
//  NetSchool
//
//  Created by 周文松 on 15/10/6.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlayRecord : NSManagedObject

@property (nonatomic, retain) NSData * datas;
@property (nonatomic, retain) NSDate * lastTime;
@property (nonatomic, retain) NSNumber * seekToTime;
@property (nonatomic, retain) NSString * sid;
@property (nonatomic, retain) NSString * pid;
+ (void)saveRecod:(id)datas seekToTime:(CGFloat)seekToTime;
+ (id)readRecod;
+ (void)removeRecod:(NSString *)lessonId;
@end
