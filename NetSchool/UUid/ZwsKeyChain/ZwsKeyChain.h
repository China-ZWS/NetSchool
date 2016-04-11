//
//  ZwsKeyChain.h
//  233JuniorSchool
//
//  Created by 周文松 on 13-7-2.
//  Copyright (c) 2013年 长沙 二三三网络科技有限公司. All rights reserved.
//

#import "ZwsUserDataManager.h"

@interface ZwsKeyChain : NSObject
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;//
+ (void)save:(NSString *)service data:(id)data ;

+ (id)load:(NSString *)service;//读取uuid ;

@end
