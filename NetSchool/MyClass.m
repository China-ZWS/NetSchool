//
//  MyClass.m
//  NetSchool
//
//  Created by 周文松 on 15/9/18.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "MyClass.h"
#import "MyVideo.h"
#import "AppDelegate.h"

@implementation MyClass

@dynamic datas;
@dynamic name;
@dynamic orderNo;
@dynamic pid;
@dynamic sid;
@dynamic type;
@dynamic myVideo;


+ (NSArray *)coreDataQuery
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* class=[NSEntityDescription entityForName:@"MyClass" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:class];
    
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"pid == %@",[Infomation readInfo][@"userId"]];
    [request setPredicate:predicate];
    
    
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
    MyClass *model = (MyClass *)mutableFetchResult[0];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:model.datas] ;
}

+ (void)coreDataSave:(id)datas
{
    
    if (![datas isKindOfClass:[NSArray class]] || ![datas count]) return; //非数组
    
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    MyClass *class = (MyClass *)[NSEntityDescription insertNewObjectForEntityForName:@"MyClass" inManagedObjectContext:app.managedObjectContext];
    class.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
    class.pid = [Infomation readInfo][@"userId"];
    NSError* error;
    BOOL isSaveSuccess=[app.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
    
}

+ (BOOL)coreDataUpdate:(id)datas predicateDatas:(id)predicateDatas;
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"MyClass" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:user];
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"pid == %@",predicateDatas[@"id"]];
    [request setPredicate:predicate];
    
    
    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
    if (mutableFetchResult==nil)
    {
        NSLog(@"Error:%@",error);
    }
    //更新age后要进行保存，否则没更新
    
    for (MyClass *class in mutableFetchResult)
    {
        class.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
        class.pid = predicateDatas[@"id"];
        [app.managedObjectContext save:&error];
        return YES;
    }
    return NO;
    
    
}


@end
