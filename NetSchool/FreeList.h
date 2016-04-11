//
//  FreeList.h
//  NetSchool
//
//  Created by 周文松 on 15/9/18.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FreeList : NSManagedObject

@property (nonatomic, retain) NSData * datas;
@property (nonatomic, retain) NSString * pid;

@end
