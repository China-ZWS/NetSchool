//
//  DownloadDelegate.h
//  NetSchool
//
//  Created by 周文松 on 15/9/11.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#ifndef NetSchool_DownloadDelegate_h
#define NetSchool_DownloadDelegate_h
#include "ASIHTTPRequest.h"

@protocol DownloadDelegate <NSObject>
-(void)waiting:(ASIHTTPRequest *)request;
-(void)start:(ASIHTTPRequest *)request;
-(void)failedDownload:(ASIHTTPRequest *)request;
-(void)updateCellProgress:(ASIHTTPRequest *)request;
-(void)finishedDownload:(ASIHTTPRequest *)request;
@end



#endif
