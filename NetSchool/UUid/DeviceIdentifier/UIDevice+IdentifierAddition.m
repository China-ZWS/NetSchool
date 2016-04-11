//
//  UIDevice+IdentifierAddition.m
//  233JuniorSchool
//
//  Created by 周文松 on 13-7-1.
//  Copyright (c) 2013年 长沙 二三三网络科技有限公司. All rights reserved.
//

#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5Addition.h"
#import "ZwsUserDataManager.h"

@implementation UIDevice (IdentifierAddition)
- (NSString *) uniqueDeviceIdentifier
{
    
    
    NSString *uuid = [ZwsUserDataManager readUuID];
     
    if (uuid != nil && uuid.length != 0 )
    {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *stringToHash = [NSString stringWithFormat:@"%@%@",uuid,bundleIdentifier];
        NSString *uniqueIdentifier = [stringToHash stringFromMD5];
        return uniqueIdentifier;

    }
    return nil;
}

@end
