//
//  LoginInputView.m
//  NetSchool
//
//  Created by 周文松 on 15/8/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "LoginInputView.h"

@implementation LoginInputView

- (void)drawRect:(CGRect)rect
{
    [self drawRectWithLine:rect start:CGPointMake(0, CGRectGetMidY(rect) - .25) end:CGPointMake(CGRectGetWidth(rect), CGRectGetMidY(rect) - .25) lineColor:CustomBlack lineWidth:.5];
}

- (id)initWithFrame:(CGRect)frame success:(void (^)())success
{
    if ((self = [super initWithFrame:frame success:success]))
    {
        self.backgroundColor = [UIColor whiteColor];
        
        [self getCornerRadius:5 borderColor:CustomBlack borderWidth:.5 masksToBounds:YES];
        [self layoutViews];
    }
    return self;
}
- (void)layoutViews
{
    [self addSubview:self.accountField];
    [self addSubview:self.pwdField];
}



- (UITextField *)accountField
{
    if (!_accountField)
    {
        _accountField = [[BaseTextField alloc] initWithFrame:CGRectMake(defaultInset.left, 0, CGRectGetWidth(self.frame) - defaultInset.left * 2, 44)];
        _accountField.placeholder = @"输入账号";
        _accountField.returnKeyType = UIReturnKeyNext;
        [_accountField setKeyboardType:UIKeyboardTypeNamePhonePad];
        _accountField.leftView = [self setLeftTitle:@"账号:"];
        _accountField.delegate = self;
        _accountField.font = Font(17);
        _accountField.text = @"newone";
    }
    return _accountField;

}

- (UITextField *)pwdField
{
    if (!_pwdField)
    {
        _pwdField = [[BaseTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(_accountField.frame),CGRectGetMaxY(_accountField.frame), CGRectGetWidth(_accountField.frame), 44)];
        _pwdField.delegate = self;
        _pwdField.leftView = [self setLeftTitle:@"密码:"];
        _pwdField.placeholder = @"输入密码";
        _pwdField.returnKeyType = UIReturnKeyDone;
        [_pwdField setKeyboardType:UIKeyboardTypeNamePhonePad];
        _pwdField.text = @"123456";
        _pwdField.font = Font(17);
    }
    return _pwdField;

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if ([textField isEqual:_accountField])
    {
        [textField resignFirstResponder];
        [_pwdField becomeFirstResponder];
    }
    else if ([textField isEqual:_pwdField])
    {
        [textField resignFirstResponder];
        _success();
    }
    return NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
