//
//  PlayRecord.m
//  NetSchool
//
//  Created by 周文松 on 15/10/6.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PlayRecord.h"
#import "AppDelegate.h"

@implementation PlayRecord

@dynamic datas;
@dynamic lastTime;
@dynamic seekToTime;
@dynamic sid;
@dynamic pid;

+ (void)saveRecod:(id)datas seekToTime:(CGFloat)seekToTime;
{
    
    if ([self coreDataUpdate:datas seekToTime:(CGFloat)seekToTime])return;
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    PlayRecord *record = (PlayRecord *)[NSEntityDescription insertNewObjectForEntityForName:@"PlayRecord" inManagedObjectContext:app.managedObjectContext];
    record.pid = [Infomation readInfo][@"userId"];
    record.sid = datas[@"id"];
    record.lastTime = [NSDate date];
    record.datas = [NSJSONSerialization dataWithJSONObject:datas  options:NSJSONWritingPrettyPrinted error:nil];
    ;
    record.seekToTime = [NSNumber numberWithFloat:seekToTime];
    NSError* error;
    BOOL isSaveSuccess=[app.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
}

+ (BOOL)coreDataUpdate:(id)datas seekToTime:(CGFloat)seekToTime;
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"PlayRecord" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:user];
    //查询条件
    NSPredicate* sidPredicate=[NSPredicate predicateWithFormat:@"sid == %@",datas[@"id"]];
    NSPredicate* pidPredicate =[NSPredicate predicateWithFormat:@"pid == %@",[Infomation readInfo][@"userId"]];
    NSPredicate *andCompoundPredicate =[NSCompoundPredicate andPredicateWithSubpredicates:@[sidPredicate,pidPredicate]];

    [request setPredicate:andCompoundPredicate];
    
    
    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
    if (mutableFetchResult==nil)
    {
        NSLog(@"Error:%@",error);
    }
    //更新age后要进行保存，否则没更新
    
    for (PlayRecord *record in mutableFetchResult)
    {
        record.lastTime = [NSDate date];
        record.seekToTime = [NSNumber numberWithFloat:seekToTime];
        [app.managedObjectContext save:&error];
        NSLog(@"updata successful");
        return YES;
    }
    NSLog(@"updata flase");
    
    return NO;
    
}

+ (id)readRecod
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* class=[NSEntityDescription entityForName:@"PlayRecord" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:class];
    
    
    NSPredicate* pidPredicate =[NSPredicate predicateWithFormat:@"pid == %@",[Infomation readInfo][@"userId"]];
    [request setPredicate:pidPredicate];

    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
    
    
    if (mutableFetchResult==nil)
    {
        NSLog(@"Error:%@",error);
    }
    else if (!mutableFetchResult.count)
    {
        return nil;
    }
    NSArray *times = [mutableFetchResult sortedArrayUsingComparator:^NSComparisonResult(PlayRecord *obj1, PlayRecord *obj2)
                      {
                          NSComparisonResult result = [obj1.lastTime compare:obj2.lastTime];
                          return result == NSOrderedAscending;
                      }];
    
    return [NSMutableArray arrayWithArray:times];
}

+ (void)removeRecod:(NSString *)lessonId
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* class=[NSEntityDescription entityForName:@"PlayRecord" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:class];
    //查询条件
    NSPredicate* sidPredicate=[NSPredicate predicateWithFormat:@"sid == %@",lessonId];
    NSPredicate* pidPredicate =[NSPredicate predicateWithFormat:@"pid == %@",[Infomation readInfo][@"userId"]];
    NSPredicate *andCompoundPredicate =[NSCompoundPredicate andPredicateWithSubpredicates:@[sidPredicate,pidPredicate]];
    [request setPredicate:andCompoundPredicate];
    
    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
    for (PlayRecord* record in mutableFetchResult) {
        [app.managedObjectContext deleteObject:record];
    }
    [app.managedObjectContext save:&error];
}

@end
