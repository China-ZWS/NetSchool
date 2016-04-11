//
//  DownloadSinglecase.h
//  NetSchool
//
//  Created by 周文松 on 15/9/11.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadDelegate.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@interface DownloadSinglecase : NSObject
<ASIHTTPRequestDelegate, ASIProgressDelegate>
singleton_interface(DownloadSinglecase)

-(void)beginRequest:(NSArray *)dataArray isBeginDown:(BOOL)isBeginDown;
@property (strong, nonatomic) ASINetworkQueue *netWorkQueue;
@property (strong, nonatomic) NSString *informationOfUserPath; // 用户信息路劲
@property (strong, nonatomic) NSString *videoFiles; //视频文件路径
@property (strong, nonatomic) NSString *videoTemps; //视频临时文件路径
@property(nonatomic,strong) NSMutableArray *finishedList;//已下载完成的文件列表（文件对象）
@property(nonatomic,strong) NSMutableArray *downingList;//正在下载的文件列表(ASIHttpRequest对象)
@property (nonatomic) NSInteger num;

//@property (strong, nonatomic) ASIHTTPRequest *request;
@property(nonatomic, assign) id<DownloadDelegate> downloadDelegate;

/**
 *  @brief  读取本地临时文件
 */
-(void)loadTempfiles;

/**
 *  @brief  读取本地已下载视频
 */
-(void)loadFinishedfiles;
- (long long) fileSizeAtPath:(NSString*) filePath;
-(long long) folderSizeAtPath:(NSString*) folderPath;
-(NSString *)stringForAllFileSize:(UInt64)fileSize;
-(NSString *)stringForSurplusSize;
-(NSString *)stringForCacheFileSize:(UInt64)fileSize;

/**
 *  @brief  创建路径
 */
-(void)creatPath;

- (NSArray *)sortWithDowningDatas:(NSArray *)datas;
@end
