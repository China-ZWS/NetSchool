//
//  NSMutableDictionary+PublicDomain.m
//  HCTProject
//
//  Created by 周文松 on 14-3-11.
//  Copyright (c) 2014年 talkweb. All rights reserved.
//

#import "NSMutableDictionary+PublicDomain.h"
#import <CommonCrypto/CommonDigest.h>



@implementation NSMutableDictionary (PublicDomain)


#pragma mark - 公共域
- (void)setPublicDomain;
{
    self[@"token"] = @"examw";
    NSArray* arr = self.allKeys;
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj1 compare:obj2];
        return result==NSOrderedDescending;
    }];
    
    
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in  arr)
    {
        if (!sign.length) {
            sign = [NSMutableString stringWithFormat:@"%@=%@",key,self[key]];
        }
        else
        {
            [sign appendFormat:@"&%@",[NSString stringWithFormat:@"%@=%@",key,self[key]]];
        }
    }
    [sign appendFormat:@"12345"];
    
    self[@"sign"] = md5(sign);
}




NSString *md5(NSString* source){
    NSData *data = [source dataUsingEncoding:NSUTF8StringEncoding];
    const char *str = [data bytes];

    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5(str, (int)[data length], digest);
    NSMutableString *result = [NSMutableString string];
    for (i=0;i<CC_MD5_DIGEST_LENGTH;i++) {
        [result appendFormat: @"%02x", (int)(digest[i])];
    }
    return [result lowercaseString];
}

/*
- (NSString *) setUuidMd5
{
    NSString * uuIdMd5 = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    return uuIdMd5;
}
 */


@end
