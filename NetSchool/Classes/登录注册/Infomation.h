//
//  Infomation.h
//  BabyStory
//
//  Created by 周文松 on 14-11-19.
//  Copyright (c) 2014年 com.talkweb.BabyStory. All rights reserved.
//


@interface Infomation : NSObject
<NSCoding>

singleton_interface(Infomation)

- (void)createPath;


/**
 *  @brief  保存用户信息
 *
 *  @param info 要保存的信息
 */
+ (void)writeInfo:(id)info;

/**
 *  @brief  读取信息
 *
 *  @return 返回以读取的信息
 */
+ (id)readInfo;

/**
 *  @brief  得到Lutp
 *
 *  @return 返回得到的Lutp
 */
+ (NSDictionary *)getLutp;

/**
 *  @brief  删除以保存的用户信息
 */
+ (BOOL)deleteInfo;

@property (nonatomic,strong) NSDictionary *datas;
@end
