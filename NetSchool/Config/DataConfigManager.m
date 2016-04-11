//
//  DataConfigManager.m
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "DataConfigManager.h"

@implementation DataConfigManager
+ (NSDictionary *)returnRoot;
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    NSDictionary *root=[[NSDictionary alloc] initWithContentsOfFile:path];
    return root;

}

+ (NSArray *)getMainConfigList;
{
    NSDictionary * root = [self returnRoot];
    NSArray *data=[[NSArray alloc] initWithArray:[root objectForKey:@"MainList"]];
    return data;
}

+ (NSArray *)getTabList
{
    NSDictionary * root = [self returnRoot];
    NSArray *data=[[NSArray alloc] initWithArray:[root objectForKey:@"MainTab"]];
    return data;

}
@end
