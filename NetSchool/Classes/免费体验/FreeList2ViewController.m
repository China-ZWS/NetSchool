//
//  FreeList1ViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/1.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "FreeList3ViewController.h"
#import "FreeList2ViewController.h"
#import "PublicHeader.h"
#import "PublicCell.h"
#import "FreeList.h"

@interface FreeList2ViewController ()
@end

@implementation FreeList2ViewController


- (id)initWithParameters:(id)parameters;
{
    if ((self = [super initWithParameters:parameters])) {
        [self.navigationItem setNewTitle:parameters[@"name"]];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
    }
    return self;
}

- (void)back
{
    [self popViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushViewController:[[FreeList3ViewController alloc] initWithParameters:_datas[indexPath.section][@"children"][indexPath.row]]];
}

- (void)requestWithServlet:(NSString *)servlet parameter:(id)parameter
{
    NSString *paramsString = [NSString stringWithFormat:@"api/m/packages/%@/%@.do",agencyId,_parameters[@"id"]];
    [super requestWithServlet:paramsString parameter:@{}];
}



- (NSArray *)coreDataQuery
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest* request=[[NSFetchRequest alloc] init]; // 请求数据用的
    
    NSEntityDescription* free1=[NSEntityDescription entityForName:@"FreeList" inManagedObjectContext:app.managedObjectContext];
    [request setEntity:free1];
    
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"pid == %@",_parameters[@"id"]];
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

    FreeList *model = (FreeList *)mutableFetchResult[0];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:model.datas] ;
}

- (void)coreDataSave:(id)datas
{
    if (![datas isKindOfClass:[NSArray class]] || ![datas count]) return; //非数组
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    FreeList *free = (FreeList *)[NSEntityDescription insertNewObjectForEntityForName:@"FreeList" inManagedObjectContext:app.managedObjectContext];
    free.datas = [NSKeyedArchiver archivedDataWithRootObject:datas];
    free.pid = _parameters[@"id"];
    NSError* error;
    BOOL isSaveSuccess=[app.managedObjectContext save:&error];
    if (!isSaveSuccess) {
        NSLog(@"Error:%@",error);
    }else{
        NSLog(@"Save successful!");
    }
}

- (BOOL)coreDataUpdate:(id)datas;
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* user=[NSEntityDescription entityForName:@"MyClass" inManagedObjectContext:app.managedObjectContext];
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


- (void)didReceiveMemoryWarning {
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
