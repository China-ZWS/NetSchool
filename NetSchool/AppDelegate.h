//
//  AppDelegate.h
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ToolSingleton.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    @public
    NetworkStatus _networkStatus;
}

@property (nonatomic) BOOL allowRotation;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
/**
 *  @brief  上传学习记录
 *
 *  @param lessonId 资源ID
 *  @param status   学习进度
 */
- (void)updateLearingRecord:(NSString *)lessonId status:(BOOL)status;

@end

