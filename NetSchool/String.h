//
//  String.h
//  NetSchool
//
//  Created by 周文松 on 15/8/27.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const serverUrl;
extern NSString *const agencyId;

#define URL(url) [String setUrl:url]
#define kTerminal_no 2 //终端编号

@interface String : NSObject
+ (NSString *)setUrl:(NSString *)url;
@end
