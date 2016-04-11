//
//  PlayerTool.m
//  NetSchool
//
//  Created by 周文松 on 15/9/7.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "PlayerTool.h"
float rate[4] = {1.0,1.2,1.4,1.6};

@interface PlayerTool ()
{
    NSInteger _speedNum;
}
@end

@implementation PlayerTool

- (id)init
{
    if ((self = [super initWithFrame:CGRectMake(0, DeviceH - 60, DeviceW, 60)])) {
        self.backgroundColor =  RGBA(50, 50, 50, .6);
    }
    return self;
}

- (UIProgressView *)progress
{
    if (!_progress) {
        _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progress.frame = CGRectMake(0, 1.5, DeviceW, 5);
        _progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.5f);
        _progress.transform = transform;
        _progress.progressTintColor = RGBA(255, 255, 255, .5);
        _progress.trackTintColor = RGBA(110, 110, 110, .5);
        _progress.progress = 0;
    }
    return _progress;
}

- (UIImage *)transparentImage:(BOOL)isMin
{
    UIGraphicsBeginImageContextWithOptions((CGSize){ 5, 5}, NO, 0.0f);
    if (isMin) {
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(con, CustomBlue.CGColor);
        CGContextFillRect(con, CGRectMake(0, 0, 5, 5));
    }
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return transparentImage;
}


- (UISlider *)scrubber
{
    if (!_scrubber)
    {
        _scrubber = [UISlider new];
        _scrubber.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrubber setMinimumTrackImage:[self transparentImage:YES] forState:UIControlStateNormal];
        [_scrubber setMaximumTrackImage:[self transparentImage:NO] forState:UIControlStateNormal];
        [_scrubber setThumbImage:[UIImage imageNamed:@"progressButtonNomal.png"] forState:UIControlStateNormal];
        [_scrubber setThumbImage:[UIImage imageNamed:@"progressButtonPress.png"] forState:UIControlStateHighlighted];
        
        _scrubber.frame = CGRectMake(-2, 0, DeviceW + 4, 5);
        [_scrubber minimumValueImageRectForBounds:_scrubber.frame];
        [_scrubber maximumValueImageRectForBounds:_scrubber.frame];
        _scrubber.backgroundColor = [UIColor clearColor];
        [_scrubber addTarget:self action:@selector(beginDragging) forControlEvents:UIControlEventTouchDown];
        [_scrubber addTarget:self action:@selector(dragging) forControlEvents:UIControlEventValueChanged];
        [_scrubber addTarget:self action:@selector(endDraging) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scrubber;
}

- (UIButton *)play
{
    if (!_play)
    {
        _play = [UIButton buttonWithType:UIButtonTypeCustom];
        _play.frame = CGRectMake(kDefaultInset.left * 3, (CGRectGetHeight(self.frame) - 30) / 2 + 5, 30, 30);
        UIImage *image = [UIImage imageNamed:@"playerBottomPlayNomal.png"];
        UIImage *image_s = [UIImage imageNamed:@"playerBottomSuspendNomal.png"];
        [_play setBackgroundImage:image forState:UIControlStateNormal];
        [_play setBackgroundImage:image_s forState:UIControlStateSelected];
        [_play addTarget:self action:@selector(eventWithPlay:) forControlEvents:UIControlEventTouchUpInside];
        _play.selected = NO;
    }
    return _play;
}

- (UILabel *)leftDate
{
    if (!_leftDate) {
        _leftDate = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_play.frame) + kDefaultInset.right * 2, (CGRectGetHeight(self.frame) - NFont(16).lineHeight) / 2 + 5, 50, NFont(16).lineHeight)];
        _leftDate.font = NFont(16);
        _leftDate.text = @"00:00";
        _leftDate.textColor = [UIColor whiteColor];
        _leftDate.textAlignment = NSTextAlignmentRight;
    }
    return _leftDate;
}

- (UILabel *)rightDate
{
    if (!_rightDate) {
        _rightDate = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftDate.frame), (CGRectGetHeight(self.frame) - NFont(16).lineHeight) / 2 + 5, 60, NFont(16).lineHeight)];
        _rightDate.font = NFont(16);
        _rightDate.textColor = [UIColor whiteColor];
        _rightDate.text = @"/00:00";
        _rightDate.textAlignment = NSTextAlignmentLeft;
    }
    return _rightDate;
}


- (UIButton *)speed
{
    if (!_speed) {
        _speed = [UIButton buttonWithType:UIButtonTypeCustom];
        _speed.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _speed.frame = CGRectMake(DeviceW - 40 - kDefaultInset.right * 3, (CGRectGetHeight(self.frame) - 25) / 2 + 5, 40, 25);
        [_speed getCornerRadius:5 borderColor:[UIColor whiteColor] borderWidth:1 masksToBounds:YES];
        [_speed setTitle:[NSString stringWithFormat:@"%0.1fX",rate[_speedNum]] forState:UIControlStateNormal];
        [_speed addTarget:self action:@selector(speedVideo) forControlEvents:UIControlEventTouchUpInside];
        _speed.titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    }
    return _speed;
}

- (void)beginDragging
{
    if ([_delegate respondsToSelector:@selector(beginDragging)] && [_delegate conformsToProtocol:@protocol(PlayerToolDelegate)]) {
        [_delegate beginDragging];
    }
}

- (void)dragging
{
    if ([_delegate respondsToSelector:@selector(beginDragging)] && [_delegate conformsToProtocol:@protocol(PlayerToolDelegate)]) {
        [_delegate dragging];
    }
    
}

- (void)endDraging
{
    if ([_delegate respondsToSelector:@selector(beginDragging)] && [_delegate conformsToProtocol:@protocol(PlayerToolDelegate)]) {
        [_delegate endDraging];
    }
}


- (void)eventWithPlay:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        if ([_delegate respondsToSelector:@selector(play)] && [_delegate conformsToProtocol:@protocol(PlayerToolDelegate)]) {
            [_delegate play];
        }
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(pause)] && [_delegate conformsToProtocol:@protocol(PlayerToolDelegate)]) {
            [_delegate pause];
        }
    }
    
}

- (void)speedVideo
{
    _speedNum++;
    if (_speedNum == 4) {
        _speedNum = 0;
    }
    
    [_speed setTitle:[NSString stringWithFormat:@"%0.1fX",rate[_speedNum]] forState:UIControlStateNormal];
    
    [_delegate speedVideo:rate[_speedNum]];

}


- (void)layoutSubviews
{
    [super layoutSubviews];

    [self addSubview:self.progress];
    [self addSubview:self.scrubber];
    [self addSubview:self.play];
    [self addSubview:self.leftDate];
    [self addSubview:self.rightDate];
    [self addSubview:self.speed];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
