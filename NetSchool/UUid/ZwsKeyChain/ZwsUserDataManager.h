//
//  ZwsUserDataManager.h
//  233JuniorSchool
//
//  Created by 周文松 on 13-7-2.
//  Copyright (c) 2013年 长沙 二三三网络科技有限公司. All rights reserved.
//


@interface ZwsUserDataManager : NSObject


+(void)saveUuid:(NSString *)uuid;
+(NSString *)readUuID;
@end
