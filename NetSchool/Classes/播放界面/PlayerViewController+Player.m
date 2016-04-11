//
//  PlayViewController+Player.m
//  NetSchool
//
//  Created by 周文松 on 15/9/8.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

static void *AVPlayerRateObservationContext = &AVPlayerRateObservationContext;
static void *AVPlayerStatusObservationContext = &AVPlayerStatusObservationContext;
static void *AVPlayerCurrentItemObservationContext = &AVPlayerCurrentItemObservationContext;
static void *AVPlayerLoadedTimeRangesObservationContext = &AVPlayerLoadedTimeRangesObservationContext;
static void *AVPlayerPlaybackBufferEmptyObservationContext = &AVPlayerPlaybackBufferEmptyObservationContext;
static void *AVPlayerPlaybackLikelyToKeepUpObservationContext = &AVPlayerPlaybackLikelyToKeepUpObservationContext;


#import "PlayerViewController+Player.h"

@implementation PlayerViewController (Player)


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (_mTimeObserver)
    {
        [_mPlayer removeTimeObserver:_mTimeObserver];
        _mTimeObserver = nil;
    }
}

- (void)removePlayerOtherObserver
{
    [_mPlayerItem removeObserver:self forKeyPath:@"status"];
    [_mPlayerItem  removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_mPlayerItem  removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_mPlayerItem  removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_mPlayer removeObserver:self forKeyPath:@"currentItem"];
    [_mPlayer removeObserver:self forKeyPath:@"rate"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_mPlayer pause];
    self.mPlayer = nil;
    self.mPlayerItem = nil;

}




#pragma mark - 得到总时间
- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [_mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

#pragma mark - 判断当前播放的状态
- (BOOL)isPlaying
{
//    return _mRestoreAfterScrubbingRate != 0.f || [_mPlayer rate] != 0.f;
    return [_mPlayer rate] != 0.f;

}


/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    _seekToZeroBeforePlay = YES;
    [self playBack];
}



#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self removePlayerOtherObserver];
//    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        else if (keyStatus == AVKeyValueStatusCancelled) // 关闭
        {
            
            return;
        }
    }
    
    // keyStatus == AVKeyValueStatusLoaded
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        //        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedDescription = NSLocalizedString(@"视频播放失败", @"Item cannot be played description");
        
        NSString *localizedFailureReason = NSLocalizedString(@"地址错误", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        [_mPlayerItem removeObserver:self forKeyPath:@"status"];
        [_mPlayerItem  removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_mPlayerItem  removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_mPlayerItem  removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /*监听缓冲进度*/
    [self.mPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:AVPlayerLoadedTimeRangesObservationContext];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerStatusObservationContext];
    
    
    
    [self.mPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:AVPlayerPlaybackBufferEmptyObservationContext];
    [self.mPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:AVPlayerPlaybackLikelyToKeepUpObservationContext];
//
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
    
    
    _seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!_mPlayer)
    {
        /* 得到一个新的AVPlayer初始化播放指定播放器项目 */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [_mPlayer addObserver:self
                   forKeyPath:@"currentItem"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:AVPlayerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [_mPlayer addObserver:self
                   forKeyPath:@"rate"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:AVPlayerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (_mPlayer.currentItem != self.mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [_mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        //        [self syncPlayPauseButtons];
    }
    
    //    [_tool.scrubber setValue:0.0];
}


- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    
    NSLog(@"%@",path);
    
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerStatusObservationContext)
    {
        [self syncPlayPauseButtons];
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                
                
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self seekToTime:^()
                {
                    [self initScrubberTimer];
                }];
                [self play];
                [self enableScrubber];
                [self enablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    /*计算缓冲进度*/
    else if (context == AVPlayerLoadedTimeRangesObservationContext)
    {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        CMTime duration = [self playerItemDuration];
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [_tool.progress setProgress:timeInterval / totalDuration animated:YES];
        
    }
    else if (context == AVPlayerPlaybackBufferEmptyObservationContext)
    {
        if (_mPlayerItem.playbackBufferEmpty) {
            NSLog(@"11");
        }
        NSLog(@"down");
        
    }
    else if (context == AVPlayerPlaybackLikelyToKeepUpObservationContext)
    {
        if (_mPlayerItem.playbackLikelyToKeepUp) {
            NSLog(@"22");
        }
        NSLog(@"up");
    }
    
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerRateObservationContext)
    {
        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == AVPlayerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self disablePlayerButtons];
            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [_playerView setPlayer:_mPlayer];
            [_playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}





@end
