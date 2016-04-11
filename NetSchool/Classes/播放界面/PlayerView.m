//
//  PlayerView.m
//  PocketConcubine
//
//  Created by 周文松 on 15-5-17.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

- (void)dealloc
{
    NSLog(@"dealloc == %@",self);
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
