//
//  Account+CoreDataProperties.h
//  NetSchool
//
//  Created by 周文松 on 15/11/19.
//  Copyright © 2015年 TalkWeb. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *acc;
@property (nullable, nonatomic, retain) NSData *datas;
@property (nullable, nonatomic, retain) NSString *pwd;

@end

NS_ASSUME_NONNULL_END
