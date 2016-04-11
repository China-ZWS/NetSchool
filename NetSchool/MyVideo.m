//
//  MyVideo.m
//  NetSchool
//
//  Created by 周文松 on 15/9/18.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "MyVideo.h"
#import "MyClass.h"

@implementation MyVideo

@dynamic datas;
@dynamic highVideoUrl;
@dynamic name;
@dynamic orderNo;
@dynamic pid;
@dynamic sid;
@dynamic superVideoUrl;
@dynamic videoUrl;
@dynamic myClass;

+ (void)coreDataSave:(id)datas predicateDatas:(id)predicateDatas;
{
    
    if (![datas isKindOfClass:[NSArray class]] || ![datas count]) return; //非数组
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    MyVideo *video = (MyVideo *)[NSEntityDescription insertNewObjectForEntityForName:@"MyVideo" inManagedObjectContext:app.managedObjectContext];
    video.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
    video.pid = predicateDatas[@"id"];
    NSError* error;
    BOOL isSaveSuccess=[app.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
}

+ (NSArray *)coreDataQuery:(id)predicateDatas
{
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* class=[NSEntityDescription entityForName:@"MyVideo" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:class];
    
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"pid == %@",predicateDatas[@"id"]];
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
    
    MyVideo *model = (MyVideo *)mutableFetchResult[0];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:model.datas] ;
}

+ (BOOL)coreDataUpdate:(id)datas predicateDatas:(id)predicateDatas;
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"MyVideo" inManagedObjectContext:app.managedObjectContext];
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
    NSLog(@"The count of entry: %i",[mutableFetchResult count]);
    //更新age后要进行保存，否则没更新
    
    for (MyVideo *vedio in mutableFetchResult)
    {
        vedio.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
        vedio.pid = predicateDatas[@"id"];
        [app.managedObjectContext save:&error];
        return YES;
    }
    return NO;
    

}
@end
