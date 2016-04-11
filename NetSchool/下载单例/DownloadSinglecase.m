//
//  DownloadSinglecase.m
//  NetSchool
//
//  Created by 周文松 on 15/9/11.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "DownloadSinglecase.h"
#import "CommonHelper.h"

BOOL _recovery;
@interface DownloadSinglecase ()
@property (nonatomic, strong) NSString *userVideoFiles;
@property (nonatomic, strong) NSString *userVideoTemps;
@end
@implementation DownloadSinglecase
singleton_implementation(DownloadSinglecase)

-(void)creatPath
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    _videoFiles = [[[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"User information"]] stringByAppendingPathComponent:[Infomation readInfo][@"userId"]] stringByAppendingPathComponent:@"VideoFiles"];
    
    _videoTemps = [[[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"User information"]] stringByAppendingPathComponent:[Infomation readInfo][@"userId"]] stringByAppendingPathComponent:@"VideoTemps"];
    [self loadTempfiles];
    [self loadFinishedfiles];
}

-(void)beginRequest:(NSArray *)dataArray isBeginDown:(BOOL)isBeginDown
{
    
    
    if (!self.netWorkQueue) {
        self.netWorkQueue  = [[ASINetworkQueue alloc] init];
        //        [_netWorkQueue cancelAllOperations];
        [_netWorkQueue reset];
        [_netWorkQueue setShowAccurateProgress:YES];
        [_netWorkQueue setShouldCancelAllRequestsOnFailure:NO];
        [_netWorkQueue cancelAllOperations];
        self.downingList = [NSMutableArray array];
        [_netWorkQueue go];
        _netWorkQueue.maxConcurrentOperationCount = 2;
    }
    
    
    
    
    for (NSMutableDictionary *datas in dataArray)
    {
        NSURL *mp4Url = [NSURL URLWithString:datas[@"videoUrl"]];
//                NSURL *mp4Url = [NSURL URLWithString:@"http://demo.examw.com:8088/4g.mp4"];
        //如果不存在则创建临时存储目录
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        
        
        if(![fileManager fileExistsAtPath:_videoFiles])
        {
            [fileManager createDirectoryAtPath:_videoFiles withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        if(![fileManager fileExistsAtPath:_videoTemps])
        {
            [fileManager createDirectoryAtPath:_videoTemps withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        
        // 生成RTF 文件
        NSMutableDictionary *writeDic = [NSMutableDictionary dictionary];
        writeDic[@"name"] = datas[@"name"];
        writeDic[@"fileSize"] = datas[@"fileSize"]?datas[@"fileSize"]:@"";
        writeDic[@"videoUrl"] = datas[@"videoUrl"];
        writeDic[@"id"] = datas[@"id"];
        NSData *writeData = [NSJSONSerialization dataWithJSONObject:writeDic  options:NSJSONWritingPrettyPrinted error:nil];
        NSString *writeMsg = [[NSString alloc] initWithData:writeData encoding:NSUTF8StringEncoding];
        [writeMsg writeToFile:[_videoTemps stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",datas[@"id"]]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        datas[@"isFistReceived"] = [NSNumber numberWithBool:YES];

        //获取Temp文件大小
        NSData *fileData=[fileManager contentsAtPath:[_videoTemps stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4.temp",datas[@"id"]]]];
        NSInteger receivedDataLength=[fileData length];
        datas[@"fileReceivedSize"] = [NSString stringWithFormat:@"%d",receivedDataLength];
        
        
        //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
        for(ASIHTTPRequest *tempRequest in self.downingList){
//            if([tempRequest.url isEqual:mp4Url]){
            NSDictionary *tDic = tempRequest.userInfo[@"File"];
            if ([tDic[@"id"] isEqualToString:datas[@"id"]])
            {
                _num = [self.downingList indexOfObject:tempRequest];
                _recovery = YES;
                [self.downingList removeObject:tempRequest];
                break;
            }
            //            [tempRequest setUsername:@"sdsda"];
        }
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:mp4Url];
        request.delegate=self;
        request.shouldContinueWhenAppEntersBackground = YES;
        
        [request setDownloadDestinationPath:[_videoFiles stringByAppendingPathComponent:[NSString stringWithFormat:@"%@<->%@.mp4",datas[@"id"],datas[@"name"]]]];//设置文件保存路径
        [request setTemporaryFileDownloadPath:[_videoTemps stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4.temp",datas[@"id"]]]];//设置临时文件保存路径;
        [request setDownloadProgressDelegate:self];
        //    [request setDownloadProgressDelegate:downCell.progress];//设置进度条的代理,这里由于下载是在AppDelegate里进行的全局下载，所以没有使用自带的进度条委托，这里自己设置了一个委托，用于更新UI
        [request setAllowResumeForFileDownloads:YES];//支持断点续传
        
        
        datas[@"request"] = request;
                
        if (isBeginDown)
        {
            datas[@"isDownloading"] = [NSNumber numberWithBool:NO];
            datas[@"isWaiting"] = [NSNumber numberWithBool:YES];
            
            if ( nil != request) {
                //添加到ASINetworkQueue队列去下载
                [_netWorkQueue addOperation:request];
            }
        }
        else
        {
            datas[@"isDownloading"] = [NSNumber numberWithBool:NO];
            datas[@"isWaiting"] = [NSNumber numberWithBool:NO];
        }
        
        request.userInfo = @{@"File":datas};//设置上下文的文件基本信息
        [request setTimeOutSeconds:10.0f];

        
        if (_recovery)/*暂停恢复*/ {
            [self.downingList  insertObject:request atIndex:_num];
            _recovery = NO;
        } else/*新增加的下载 每一个新下载请求都会加载到数组的最后一列 也就是现在列表的最后一行*/ {
            
            [self.downingList addObject:request];
        }
        
        
        if ([_downloadDelegate respondsToSelector:@selector(waiting:)] && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)])
        {
            dispatch_async( dispatch_get_main_queue(),^{
                [self.downloadDelegate waiting:request];
            });
        }

    }
    
    //其实刷新是需要考虑 新增加的下载，暂停恢复 不需要 刷新。这里是方便。
    NSNotificationPost(RefreshWithViews, nil, nil);
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"star");
    NSMutableDictionary *datas = request.userInfo[@"File"];
    datas[@"isDownloading"] = [NSNumber numberWithBool:YES];
    datas[@"isWaiting"] = [NSNumber numberWithBool:NO];
    
    if ([_downloadDelegate respondsToSelector:@selector(start:)] && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)])
    {
        dispatch_async( dispatch_get_main_queue(),^{
            [self.downloadDelegate start:request];
        });
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    
    NSMutableDictionary *datas = request.userInfo[@"File"];
    datas[@"isDownloading"] = [NSNumber numberWithBool:NO];
    datas[@"isWaiting"] = [NSNumber numberWithBool:NO];
    
    if (self.netWorkQueue.maxConcurrentOperationCount == 0) {
        self.netWorkQueue = nil;
    }
    if ([_downloadDelegate respondsToSelector:@selector(failedDownload:)] && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)])
    {
        dispatch_async( dispatch_get_main_queue(),^{
            [self.downloadDelegate failedDownload:request];
        });
    }
    
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    
    fileInfo[@"fileSize"] = [NSString stringWithFormat:@"%f",[CommonHelper getFileSizeNumber:[[request responseHeaders] objectForKey:@"Content-Length"]] + [fileInfo[@"fileReceivedSize"] floatValue]];
    NSMutableDictionary *writeDic = [NSMutableDictionary dictionary];
    writeDic[@"name"] = fileInfo[@"name"];
    writeDic[@"fileSize"] = fileInfo[@"fileSize"];
    writeDic[@"videoUrl"] = fileInfo[@"videoUrl"];
    writeDic[@"id"] = fileInfo[@"id"];
    NSData *writeData = [NSJSONSerialization dataWithJSONObject:writeDic  options:NSJSONWritingPrettyPrinted error:nil];
    NSString *writeMsg = [[NSString alloc] initWithData:writeData encoding:NSUTF8StringEncoding];
    
    [writeMsg writeToFile:[_videoTemps stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",fileInfo[@"id"]]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    NSLog(@"bytes:%lld",bytes);
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    
    if(![fileInfo[@"isFistReceived"] boolValue])//原因 首次进来 他会把总大小加在一起
    {
        fileInfo[@"fileReceivedSize"]= [NSString stringWithFormat:@"%lld",[fileInfo[@"fileReceivedSize"] longLongValue]+bytes];
    }

    
    if ([_downloadDelegate respondsToSelector:@selector(updateCellProgress:)] && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)] )
    {
        dispatch_async( dispatch_get_main_queue(),^{
            
            [self.downloadDelegate updateCellProgress:request];
        });
    }
    fileInfo[@"isFistReceived"] = [NSNumber numberWithBool:NO];

}

//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSMutableDictionary *fileInfo = request.userInfo[@"File"];
    fileInfo[@"isDownloading"] = [NSNumber numberWithBool:NO];
    fileInfo[@"isWaiting"] = [NSNumber numberWithBool:NO];
    
    //删除RTF 文件
    NSString *tempRTF = [_videoTemps stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",fileInfo[@"id"]]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if([fileManager fileExistsAtPath:tempRTF])//如果存在临时文件的配置文件
    {
        [fileManager removeItemAtPath:tempRTF error:&error];
    }
    
    
    if ([_downloadDelegate respondsToSelector:@selector(finishedDownload:)] && [_downloadDelegate conformsToProtocol:@protocol(DownloadDelegate)] && _downloadDelegate)
    {
        dispatch_async( dispatch_get_main_queue(),^{
            
            [self.downloadDelegate finishedDownload:request];
        });
    }
    
    if (_downingList.count) {
        [_downingList removeObject:request];
    }
    if (_finishedList.count) {
        [_finishedList removeAllObjects];
    }
    if([fileManager fileExistsAtPath:_videoFiles])
    {
        NSArray *filelist=[fileManager contentsOfDirectoryAtPath:_videoFiles error:&error];
        if(!error)
        {
       
        }
        for(NSString *fileName in filelist)
        {
//            NSString *path = [_videoFiles stringByAppendingPathComponent:fileName];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSInteger index=[fileName rangeOfString:@"."].location;
            NSString *trueName=[fileName substringToIndex:index];
            NSArray *array = [trueName componentsSeparatedByString:@"<->"];
            dic[@"videoUrl"] = fileName;
            dic[@"id"] = array[0];
            dic[@"name"] = array[1];
            [_finishedList addObject:dic];
        }
    }

    NSNotificationPost(RefreshWithViews, nil, nil);
}

- (void)loadTempfiles
{
    NSMutableArray *datas = [NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *filelist=[fileManager contentsOfDirectoryAtPath:_videoTemps error:&error];
    for (NSString *file in filelist )
    {
        if([file rangeOfString:@".rtf"].location<=100)//以.temp结尾的文件是下载文件的配置文件，存在文件名称，文件总大小，文件下载URL
        {
            //临时文件的配置文件的内容
            NSString *msg=[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[_videoTemps stringByAppendingPathComponent:file]]  encoding:NSUTF8StringEncoding];
            
            NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"name"] = dict[@"name"];
            dic[@"fileSize"] = dict[@"fileSize"];
            dic[@"videoUrl"] = dict[@"videoUrl"];
            dic[@"id"] = dict[@"id"];
            [datas addObject:dic];
        }
    }
    
    if (datas.count) {
        [self beginRequest:datas isBeginDown:NO];
    }
}


-(void)loadFinishedfiles
{
    self.finishedList = [NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    
    
    if([fileManager fileExistsAtPath:_videoFiles])
    {
        NSArray *filelist=[fileManager contentsOfDirectoryAtPath:_videoFiles error:&error];
        if(!error)
        {
            
        }
        for(NSString *fileName in filelist)
        {
//            NSString *path = [_videoFiles stringByAppendingPathComponent:fileName];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSInteger index=[fileName rangeOfString:@"."].location;
            NSString *trueName=[fileName substringToIndex:index];
            NSArray *array = [trueName componentsSeparatedByString:@"<->"];
            dic[@"videoUrl"] = fileName;
            dic[@"id"] = array[0];
            dic[@"name"] = array[1];
            
            [_finishedList addObject:dic];
            
        }
    }
}


- (NSArray *)sortWithDowningDatas:(NSArray *)datas;
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *videoFiles=[fileManager contentsOfDirectoryAtPath:_videoFiles error:&error];
    NSArray *videoTemps=[fileManager contentsOfDirectoryAtPath:_videoTemps error:&error];
    NSMutableArray *unDownDatas = [NSMutableArray array];
    for (NSDictionary *dic in datas)
    {
        
        NSString *name = [NSString stringWithFormat:@"%@<->%@.mp4",dic[@"id"],dic[@"name"]];
        if ([videoFiles containsObject:name])
        {
            [unDownDatas addObject:dic];
        }
    }
    for (NSDictionary *dic in datas)
    {
        NSString *name = [NSString stringWithFormat:@"%@.rtf",dic[@"id"]];
        if ([videoTemps containsObject:name])
        {
            [unDownDatas addObject:dic];
        }
    }
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",unDownDatas];
    NSArray *downDatas = [datas filteredArrayUsingPredicate:filterPredicate];
    return @[downDatas,unDownDatas];
}


@end
