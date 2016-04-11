//
//  Infomation.m
//  BabyStory
//
//  Created by 周文松 on 14-11-19.
//  Copyright (c) 2014年 com.talkweb.BabyStory. All rights reserved.
//

#import "Infomation.h"


@implementation Infomation
singleton_implementation(Infomation)

- (id)initWithInfo:(NSDictionary *)data
{
    if ((self = [super init]))
    {
        self.datas = data;
    }
    return self;
}

- (void)createPath;
{
//    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
//    
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    NSError *error;

}

//对属性解码，解归档调用
- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init]))
    {
        self.datas = [decoder decodeObjectForKey:@"datas"];
    }
    return self;
}

//对属性编码，归档的时候会用
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_datas forKey:@"datas"];
}

#pragma mark - info进行归档
+ (void)writeInfo:(id)info;
{
   
    Infomation *data = [[Infomation alloc] initWithInfo:info];
    if (data)
    {
         NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Infomation"];
        [NSKeyedArchiver archiveRootObject:data toFile:filePath];
    }
}

#pragma  mark - info 解档
+ (id)readInfo
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    Infomation *data = nil;
    if ([fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Infomation"]])
    {
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Infomation"]];
    }
    return data.datas;
}

#pragma mark - 获取lutp 字符串
+ (NSDictionary *)getLutp
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSDictionary *lutp = nil;
    if ([fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Infomation"]])
    {
       Infomation *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Infomation"]];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"secret_key"] = data;
        
//        NSString *sstoken = data.result[@"sstoken"];
//        NSString *userId = data.result[@"user"][@"id"];
//        NSString *acc
//        lutp = [NSDictionary dictionaryWithObjectsAndKeys:sstoken,@"sstoken",userId,@"id",nil] ;
    }
    return lutp;
}

#pragma mark -  删除用户信息
+ (BOOL)deleteInfo
{

    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Infomation"]])
    {
       return [fileManager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Infomation"] error:&error];
    }
    return NO;
}
@end
