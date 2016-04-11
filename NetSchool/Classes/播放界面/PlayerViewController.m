//
//  PlayerViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/9/8.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerViewController+Player.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "PlayRecord.h"
#import "DownloadSinglecase.h"

typedef enum : NSInteger {
    
    kMoveDirectionNone,
    kMoveDirectionUp,
    kMoveDirectionDown,
    kMoveDirectionRight,
    kMoveDirectionLeft
    
} MoveDirection;
CGFloat const gestureMinimumTranslation = 1.0 ;

@interface PlayerViewController ()
{
    float _progressValue;
    float _volume;
    double _time;

    UISlider *_volumeViewSlider;
    MoveDirection _direction;
    

}
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) BOOL isUnShow;
@end

@implementation PlayerViewController

- (id)initWithParameters:(id)parameters;
{
    if ((self = [super initWithParameters:parameters])) {
        
        [self.navigationItem setNewTitle:parameters[@"name"]];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(playBack) image:@"back.png"];
        _mRestoreAfterPlayRate = 1.0f;
    }
    
    return self;
}

- (void)dealloc
{
    [self removePlayerTimeObserver];
    [self removePlayerOtherObserver];
    
}

#pragma mark - 当视频还在加载中退出
- (void)playBack
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.allowRotation = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    [PlayRecord saveRecod:_parameters seekToTime:_time];
    BOOL status = NO;
    if (fabs(_time - CMTimeGetSeconds([self playerItemDuration])) <.1) {
        status = YES;
    }
    else
    {
        status = NO;
    }
    [app updateLearingRecord:_parameters[@"id"] status:status];
    [self dismissViewController];
}




- (void)viewDidLoad {
    [super viewDidLoad];

    
    _playerView = [[PlayerView alloc] initWithFrame:self.view.frame];
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    
    
    _tool = [PlayerTool new];
    _tool.delegate = self;
    _tool.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_playerView];
    [self.view addSubview:_tool];
    
    
//    if ([_parameters[@"videoUrl"] hasPrefix:@"http"]) {
//        self.url = [NSURL URLWithString:_parameters[@"videoUrl"]];
//    }
//    else
//    {
//        /*相对路径拼接*/
//        NSString *localVideoUrl = [[DownloadSinglecase sharedDownloadSinglecase].videoFiles stringByAppendingPathComponent:_parameters[@"videoUrl"]];
//        self.url = [NSURL fileURLWithPath:localVideoUrl];
//
//    }
    NSString *localVideoUrl = [[DownloadSinglecase sharedDownloadSinglecase].videoFiles stringByAppendingPathComponent:_parameters[@"videoUrl"]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
   
    if ([fileManager fileExistsAtPath:localVideoUrl])
    {
        
        self.url = [NSURL fileURLWithPath:localVideoUrl];
    }
    else
    {
        self.url = [NSURL URLWithString:_parameters[@"videoUrl"]];
    }
    
//    self.url = [NSURL URLWithString:@"http://demo.examw.com:8088/10-liuchang.mp4"];
//    self.url = [NSURL URLWithString:@"http://demo.examw.com:8088/4c.mp4"];
//    self.url = [NSURL URLWithString:_parameters[@"videoUrl"]];

    [self addGestureRecognizer];

}

#pragma mark - 加载URL以及初始化播放器
- (void)setUrl:(NSURL *)url
{
    if (_url != url)
    {
        _url = url;
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_url options:nil];
        
        NSArray *requestedKeys = @[@"playable"];
        
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                //                                NSError *error = nil;
                                //                                AVKeyValueStatus status = [asset statusOfValueForKey:@"playable" error:&error];
                                
                                    [self prepareToPlayAsset:asset withKeys:requestedKeys];

                            });
         }];
    }
}

- (void)seekToTime:(void(^)())seekToTime;
{
    NSArray *records= [PlayRecord readRecod];
    CGFloat time = 0;
    for (PlayRecord *record in records)
    {
        if ([record.sid isEqualToString:_parameters[@"id"]])
        {
            time = [record.seekToTime floatValue];
            if (fabs(time - CMTimeGetSeconds([self playerItemDuration])) <.1) {
                time = 0.f;
                [self.view makeToast:@"课程已学习完，已跳到开头"];
            }
            else
            {
                [self.view makeToast:[@"已跳到" stringByAppendingString:[self convertMovieTimeToText:time]]];
            }
            break;
        }
    }
    
    [_mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:CMTimeMake(1, 30) toleranceAfter:CMTimeMake(1, 30) completionHandler:^(BOOL finished)
     {
         dispatch_async(dispatch_get_main_queue(), ^{             
             seekToTime();
         });
     }];

}

#pragma mark - 计算缓冲总进度
- (NSTimeInterval)availableDuration
{

    NSArray *loadedTimeRanges = [[_mPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}



#pragma mark -调用媒体播放时更新时间控制器
-(void)initScrubberTimer
{
    if (!_mTimeObserver)
    {
    double interval = .1f;

    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([_tool.scrubber bounds]);
        interval = 0.5f * duration / width;

        _tool.rightDate.text = [@"/" stringByAppendingString:[self convertMovieTimeToText:duration]];
    }

    /* Update the scrubber during normal playback. */
    __weak PlayerViewController *weakSelf = self;
    _mTimeObserver = [_mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                            queue:NULL /* If you pass NULL, the main queue is used. */
                                                       usingBlock:^(CMTime time)
                      {
                          [weakSelf syncScrubber];
                      }];
    }
    
}

# pragma mark - 设置根据当前时间的进度.
- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _tool.scrubber.minimumValue = 0.0;
        return;
    }

    double duration = CMTimeGetSeconds(playerDuration);
    
    if (isfinite(duration))
    {
        float minValue = [_tool.scrubber minimumValue];
        float maxValue = [_tool.scrubber maximumValue];
        _time = CMTimeGetSeconds([self.mPlayer currentTime]);
        _tool.leftDate.text = [self convertMovieTimeToText:_time];
        [_tool.scrubber setValue:(maxValue - minValue) * _time / duration + minValue];
        _progressValue = _tool.scrubber.value;
    }
}


#pragma mark - 控制器的约束
-(void)enableScrubber
{
    _tool.scrubber.enabled = YES;
}

-(void)disableScrubber
{
    _tool.scrubber.enabled = NO;
}



-(void)enablePlayerButtons
{
    _tool.play.enabled = YES;
}

-(void)disablePlayerButtons
{
    _tool.play.enabled = NO;
}


#pragma mark - 更新当前播放按钮状态
- (void)syncPlayPauseButtons
{
    if ([self isPlaying])
    {
        _tool.play.selected = YES;
    }
    else
    {
        _tool.play.selected = NO;
    }
}


#pragma mark 播放进度/总时长
-(NSString*)convertMovieTimeToText:(CGFloat)time{
    int m = (int)(time/60);
    int s = (int) ((time/60 - m)*60);
    return [NSString stringWithFormat:@"%02d:%02d ",m,s];
}

#pragma mark - playerDelegate 代理 -
#pragma mark -开始
- (void)play
{
    [self.mPlayer setRate:_mRestoreAfterPlayRate];
    
//        [_mPlayer play];

}

#pragma mark - 暂停
- (void)pause
{
    _mRestoreAfterPlayRate = [self.mPlayer rate];
    [self.mPlayer setRate:0];
//    [_mPlayer pause];
}

#pragma mark - 开始滑动
- (void)beginDragging
{
    _mRestoreAfterScrubbingRate = [self.mPlayer rate];
    [self.mPlayer setRate:0.f];
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

#pragma mark - 开始滑动中
- (void)dragging
{
    if (!_isSeeking)
    {
//        _isSeeking = YES;
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }

        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [_tool.scrubber minimumValue];
            float maxValue = [_tool.scrubber maximumValue];
            float value = [_tool.scrubber value];

           _time = duration * (value - minValue) / (maxValue - minValue);
            _tool.leftDate.text = [self convertMovieTimeToText:_time];
        }
    }

}

#pragma mark - 结束滑动
- (void)endDraging
{
   	if (!_mTimeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            [self.mPlayer seekToTime:CMTimeMakeWithSeconds(_time, NSEC_PER_SEC) toleranceBefore:CMTimeMake(1, 30) toleranceAfter:CMTimeMake(1, 30) completionHandler:^(BOOL finished)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _isSeeking = NO;
                });
            }];

            CGFloat width = CGRectGetWidth([_tool.scrubber bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak PlayerViewController *weakSelf = self;
            _mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                             }];
        }
    }

    if (_mRestoreAfterScrubbingRate)
    {
        [self.mPlayer setRate:_mRestoreAfterScrubbingRate];
        _mRestoreAfterScrubbingRate = 0.f;
    }
    _progressValue = _tool.scrubber.value;
}

-(void)speedVideo:(CGFloat)rate ;
{
    _mPlayer.rate = rate;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma 单击手势
- (void)handleSingleTapFrom
{
    self.isUnShow = !_isUnShow;
}

- (void)setIsUnShow:(BOOL)isUnShow
{
    _isUnShow = isUnShow;
    [UIView animateWithDuration:.5 animations:^{
        
        if (isUnShow) {
            _tool.alpha = 0;
            _tool.transform=CGAffineTransformMakeTranslation(0, CGRectGetHeight(_tool.frame));
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            self.navigationController.navigationBar.alpha = 0;
        }
        else
        {
            _tool.alpha = 1;
            _tool.transform = CGAffineTransformIdentity;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            self.navigationController.navigationBar.alpha = 1;
        }
    }];
}

#pragma mark 声音和进度手势
-(void)handlePanGestures:(UIPanGestureRecognizer *)recognizer
{
    
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan )
    {
        _direction = kMoveDirectionNone;
        _volume = [ToolSingleton getInstance].volume;
    }
    
    else if (recognizer.state == UIGestureRecognizerStateChanged )
    {
        
        _direction = [ self determineCameraDirectionIfNeeded:translatedPoint];
        // 用户的手势指示的方向移动
        switch (_direction) {
            case kMoveDirectionDown:
                NSLog (@ "Start moving down" );
                [self stateChangedVoiceDirection:_volume - translatedPoint.y / DeviceH];
                break ;
            case kMoveDirectionUp:
                NSLog (@ "Start moving up" );
                [self stateChangedVoiceDirection:_volume - translatedPoint.y / DeviceH];
                break ;
            case kMoveDirectionRight:
                NSLog (@ "Start moving right" );
                if (!_mRestoreAfterScrubbingRate)
                {
                    self.isUnShow = NO;
                    [self beginDragging];
                }
                [self stateChangedProgressDirection:_progressValue + translatedPoint.x / DeviceW];
                break ;
            case kMoveDirectionLeft:
                NSLog (@ "Start moving left" );
                if (!_mRestoreAfterScrubbingRate)
                {
                    self.isUnShow = NO;
                    [self beginDragging];
                }
                [self stateChangedProgressDirection:_progressValue + translatedPoint.x / DeviceW];
                break ;
            default :
                break ;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded )
    {
        // now tell the camera to stop
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        switch (_direction) {
            case kMoveDirectionDown:
                NSLog (@ "Start moving down" );
                [self stateEndedVoiceDirection];
                break ;
            case kMoveDirectionUp:
                NSLog (@ "Start moving up" );
                [self stateEndedVoiceDirection];
                break ;
            case kMoveDirectionRight:
                NSLog (@ "Start moving right" );
                [self stateEndedProgressDirection];
                break ;
            case kMoveDirectionLeft:
                NSLog (@ "Start moving left" );
                [self stateEndedProgressDirection];
                break ;
            default :
                break ;
        }
        NSLog (@ "Stop" );
    }
}


- (void)stateChangedVoiceDirection:(CGFloat)value
{

     _volumeViewSlider.value = value;
}

- (void)stateEndedVoiceDirection
{
    _volume = _volumeViewSlider.value;
}

- (void)stateChangedProgressDirection:(CGFloat)value
{
    _tool.scrubber.value = value;
    
    [self dragging];
}

- (void)stateEndedProgressDirection
{
    _progressValue = _tool.scrubber.value;
    [self endDraging];
}


- (MoveDirection )determineCameraDirectionIfNeeded:( CGPoint )translation

{
    if (_direction != kMoveDirectionNone)
        return _direction;
    // 确定横向轻扫只有当你满足一些最小速度
    if (fabs(translation.x) > gestureMinimumTranslation)
    {
        BOOL gestureHorizontal = NO;
        if (translation.y == 0.0 )
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) > 1.0 );
        
        if (gestureHorizontal)
        {
            if (translation.x > 0.0 )
                return kMoveDirectionRight;
            else
                return kMoveDirectionLeft;
        }
    }
    // 确定是否垂直刷卡只有当你满足一些最小速度
    else if (fabs(translation.y) > gestureMinimumTranslation)
    {
        BOOL gestureVertical = NO;
        if (translation.x == 0.0 )
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 1.0 );
        
        if (gestureVertical)
        {
            if (translation.y > 0.0 )
                return kMoveDirectionDown;
            else
                return kMoveDirectionUp;
        }
    }
    return _direction;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

#pragma mark - 添加手势
- (void)addGestureRecognizer
{
    UITapGestureRecognizer  *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [_playerView addGestureRecognizer:singleRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestures:)];
    //无论最大还是最小都只允许一个手指
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [_playerView addGestureRecognizer:panGestureRecognizer];
    if (!_volumeViewSlider) {
        MPVolumeView *volumeView = [MPVolumeView new];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }

}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
