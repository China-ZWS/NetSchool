//
//  PlayerViewController.h
//  NetSchool
//
//  Created by 周文松 on 15/9/8.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PJViewController.h"
#import "PlayerView.h"
#import "PlayerTool.h"

@interface PlayerViewController : PJViewController
<PlayerToolDelegate>
{
    id _mTimeObserver;
    PlayerView *_playerView;
    PlayerTool *_tool;
    float _mRestoreAfterScrubbingRate;
    float _mRestoreAfterPlayRate;
    BOOL _isSeeking;
    BOOL _seekToZeroBeforePlay;
    BOOL _isPlayBack;
    AVPlayer* _mPlayer;
    AVPlayerItem* _mPlayerItem;
}

@property (readwrite, strong, setter=setPlayer:, getter=player) AVPlayer* mPlayer;
@property (strong) AVPlayerItem* mPlayerItem;



- (void)syncScrubber;
- (void)disableScrubber;
- (void)disablePlayerButtons;
- (void)playBack;
- (void)syncPlayPauseButtons;
- (void)initScrubberTimer;
- (void)enableScrubber;
- (void)enablePlayerButtons;
- (void)seekToTime:(void(^)())seekToTime;
- (NSTimeInterval)availableDuration;

@end
