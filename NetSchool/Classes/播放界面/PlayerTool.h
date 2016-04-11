//
//  PlayerTool.h
//  NetSchool
//
//  Created by 周文松 on 15/9/7.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PlayerToolDelegate;

@interface PlayerTool : UIView
@property (nonatomic, weak) id<PlayerToolDelegate>delegate;
@property (nonatomic, strong) UISlider *scrubber;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) UIButton *speed;
@property (nonatomic, strong) UILabel *leftDate;
@property (nonatomic, strong) UILabel *rightDate;
@property (nonatomic, strong) UIButton *play;
@end

@protocol PlayerToolDelegate <NSObject>

- (void)play;
- (void)pause;
- (void)beginDragging;
- (void)dragging;
- (void)endDraging;
-(void)speedVideo:(CGFloat)rate ;
@end
