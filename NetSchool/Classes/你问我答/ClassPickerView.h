//
//  ClassPickerView.h
//  NetSchool
//
//  Created by 周文松 on 15/9/29.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, Status)
{
    kClass,
    kLesson
};

@interface ClassPickerView : UIView
- (id)initWithSuccess:(void (^)(id))success datas:(id)datas target:(id)target status:(Status)status;

@end
