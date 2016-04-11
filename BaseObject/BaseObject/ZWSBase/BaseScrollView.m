//
//  BaseScrollView.m
//  PocketConcubine
//
//  Created by 周文松 on 15-5-11.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "BaseScrollView.h"

@implementation BaseScrollView
{
    BOOL _isShow;
    NSTimeInterval _animationDuration;
    UIViewAnimationCurve _animationCurve;
    CGRect _keyboardEndFrame;
    UIView *_currentField;
    CGFloat _selfMinY;

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
    
    }
    return self;
}



#pragma mark - 初始化通知
-(void)notificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}



#pragma mark - 键盘调用的事件
- (void)keyboardWasShow:(NSNotification *)notification
{
    
    [self moveTextViewForKeyboard:notification up:YES];
}

#pragma mark - 键盘消失调用的事件
-(void)keyboardWasHidden:(NSNotification *)notification
{
    [self moveTextViewForKeyboard:notification up:NO];
}


- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
    NSDictionary* userInfo = [aNotification userInfo];
    // Get animation info from userInfo
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&_animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&_animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    _isShow = up;
    
    if (up)
    {
        [self calculateInsetHeight];
        
    }
    else
    {
        self.transform = CGAffineTransformIdentity;
        
    }
}

- (void)calculateInsetHeight
{
    if (!_isShow) {
        return;
    }
    CGRect rect = [self.window convertRect:_keyboardEndFrame toView:self.superview];
    CGFloat insetHeight = CGRectGetMaxY(_currentField.frame) + _selfMinY - CGRectGetMinY(rect);
    //    NSLog(@"%f === %f",CGRectGetMaxY(_currentField.frame), CGRectGetMinY(rect));
    if (insetHeight > 0)
    {
        self.transform=CGAffineTransformMakeTranslation(0, -insetHeight);
    }
    

}

- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
{
    if (_currentField)
    {
        
        //        [_currentField getCornerRadius:ScaleW(3) borderColor:CustomGray borderWidth:1 masksToBounds:YES];
        _currentField = nil;
    }
    
    _currentField = textField;
    //    [textField getCornerRadius:ScaleW(3) borderColor:CustomPink borderWidth:1.5 masksToBounds:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_currentField)
    {
        //        [_currentField getCornerRadius:ScaleW(3) borderColor:CustomGray borderWidth:1 masksToBounds:YES];
        _currentField = nil;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (_currentField)
    {
        //        [_currentField getCornerRadius:ScaleW(3) borderColor:CustomGray borderWidth:1 masksToBounds:YES];
        _currentField = nil;
    }
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    if (_currentField)
    {
        //        [_currentField getCornerRadius:ScaleW(3) borderColor:CustomGray borderWidth:1 masksToBounds:YES];
        _currentField = nil;
    }
    
    _currentField = textView;
    //    [textView getCornerRadius:ScaleW(3) borderColor:CustomPink borderWidth:1.5 masksToBounds:YES];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {//按下return键
        //这里隐藏键盘，不做任何处理
        [textView resignFirstResponder];
        return NO;
    }else {
        if ([textView.text length] <= 200) {//判断字符个数
            return YES;
        }
    }
    return NO;
}


#pragma mark - 手动添加键盘监听事件
- (void)setHasOpenkeyboardNotification:(BOOL)hasOpenkeyboardNotification
{
    if (hasOpenkeyboardNotification) {
        [self notificationCenter];
    }
}

- (void)setScrollHeaderView:(UIView *)scrollHeaderView
{
    if (![scrollHeaderView isEqual: _scrollHeaderView]) {
        [_scrollHeaderView removeFromSuperview];
        _scrollHeaderView = nil;
        _scrollHeaderView = scrollHeaderView;
        [self addSubview:scrollHeaderView];
    }
}

- (void)setScrollFooterView:(UIView *)scrollFooterView
{
    if (scrollFooterView != _scrollFooterView) {
        [_scrollFooterView removeFromSuperview];
        _scrollFooterView = nil;
        [self addSubview:scrollFooterView];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
