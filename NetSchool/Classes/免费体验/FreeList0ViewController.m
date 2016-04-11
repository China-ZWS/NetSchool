//
//  FreeList0ViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/31.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "FreeList0ViewController.h"
#import "FreeList1ViewController.h"
#import "PublicCell.h"
#import "FreeList.h"

@interface FreeList0ViewController ()
@end

@implementation FreeList0ViewController


- (id)init
{
    if ((self = [super init]))
    {
        [self.navigationItem setNewTitle:@"免费体验"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
    }
    return self;
}

- (void)back
{
    [self popViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushViewController:[[FreeList1ViewController alloc] initWithParameters:_datas[indexPath.row]]];
}


- (void)requestWithServlet:(NSString *)servlet parameter:(id)parameter
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setPublicDomain];
    [super requestWithServlet:@"/api/m/exams" parameter:params];
    
}

- (void)coreDataSave:(id)datas
{
    if (![datas isKindOfClass:[NSArray class]] || ![datas count]) return; //非数组
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    FreeList *free = (FreeList *)[NSEntityDescription insertNewObjectForEntityForName:@"FreeList" inManagedObjectContext:app.managedObjectContext];
   
    
    free.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
    
    NSError* error;
    BOOL isSaveSuccess=[app.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
    

}

- (NSArray *)coreDataQuery
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* free0=[NSEntityDescription entityForName:@"FreeList" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:free0];
    
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

    FreeList *model = (FreeList *)mutableFetchResult[0];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:model.datas] ;
}

- (BOOL)coreDataUpdate:(id)datas;
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"FreeList" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:user];
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"pid == %@",_parameters[@"id"]];
    [request setPredicate:predicate];
    
    
    NSError* error=nil;
    NSArray* mutableFetchResult=[app.managedObjectContext executeFetchRequest:request error:&error];
    if (mutableFetchResult==nil)
    {
        NSLog(@"Error:%@",error);
    }
    //更新age后要进行保存，否则没更新
    
    for (FreeList *free in mutableFetchResult)
    {
        free.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
        free.pid = _parameters[@"id"];
        [app.managedObjectContext save:&error];
        return YES;
    }
    return NO;
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
