//
//  PlayViewController+Player.h
//  NetSchool
//
//  Created by 周文松 on 15/9/8.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PlayerViewController.h"

@interface PlayerViewController (Player)
- (void)removePlayerTimeObserver;
- (void)removePlayerOtherObserver;

- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
@end
