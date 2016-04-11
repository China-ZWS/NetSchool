//
//  String.m
//  NetSchool
//
//  Created by 周文松 on 15/8/27.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "String.h"

NSString *const serverUrl = @"http://www.52huike.com/api.php/";
NSString *const agencyId = @"9bc380e2-4fc7-11e5-bfe6-000d609a8169";

@implementation String

+ (NSString *)setUrl:(NSString *)url;
{
    return [serverUrl stringByAppendingString:url];
}

@end
