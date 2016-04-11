//
//  CommonHelper.h
//  233JuniorSchool
//
//  Created by 周文松 on 13-6-6.
//  Copyright (c) 2013年 长沙 二三三网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonHelper : NSObject

+(float)getProgress:(float)totalSize currentSize:(float)currentSize;

//经文件大小转化成不带单位ied数字
+(float)getFileSizeNumber:(NSString *)size;

@end
