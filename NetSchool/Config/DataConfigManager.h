//
//  DataConfigManager.h
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataConfigManager : NSObject
+ (NSDictionary *)returnRoot;

+ (NSArray *)getMainConfigList;

+ (NSArray *)getTabList;

@end
