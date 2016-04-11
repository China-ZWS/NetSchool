//
//  FeedbackViewController.m
//  NetSchool
//
//  Created by 周文松 on 15/8/31.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "FeedbackViewController.h"
#import "PJTextView.h"

@interface FeedbackViewController ()
<BaseTextViewDelegate>
{
    BOOL _isShow;
    NSTimeInterval _animationDuration;
    UIViewAnimationCurve _animationCurve;
    CGRect _keyboardEndFrame;
    UIView *_currentField;
    void (^_success)(NSString *string);
    CGFloat _hight;
    
}
@property (nonatomic) PJTextView *textView;
@end

@implementation FeedbackViewController


- (id)init
{
    if ((self = [super init]))
    {
        [self.navigationItem setNewTitle:@"意见反馈"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
    }
    return self;
}

- (void)back
{
    [self popViewController];
}


- (void)eventWithSend
{
    [self.view endEditing:YES];
    if (!_textView.text.length) {
        [self.view makeToast:@"你还没有反馈类容"];
        return;
    }
    [MBProgressHUD showMessag:@"提交中..." toView:self.view];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"content"] = _textView.text ;
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    [params setPublicDomain];

    _connection = [BaseModel POST:URL(@"api/m/aq/suggest/add") parameter:params   class:[BaseModel class]
                          success:^(id data)
                   {
                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                       [self.view makeToast:@"反馈成功"];
                       [self performSelector:@selector(back) withObject:nil afterDelay:.5];
                   }
                          failure:^(NSString *msg, NSString *state)
                   {
                       [self.view makeToast:msg duration:.5 position:@"center"];
                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                   }];

}


- (UIToolbar *)header
{
    UIToolbar *view = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DeviceW, 50)];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"学员名：%@",[Infomation readInfo][@"userName"]]];
    NSMutableParagraphStyle * style = [NSMutableParagraphStyle new];
    style.firstLineHeadIndent = kDefaultInset.left * 2;
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[@"学员名：" length])];
    [attrString addAttribute:NSFontAttributeName value:NFont(15) range:NSMakeRange(0,[@"学员名：" length])];
    [attrString addAttribute:NSForegroundColorAttributeName value:CustomBlue range:NSMakeRange([@"学员名：" length],[[Infomation readInfo][@"userName"] length])];
    [attrString addAttribute:NSFontAttributeName value:NFontBold(18) range:NSMakeRange([@"学员名：" length],[[Infomation readInfo][@"userName"] length])];
    
    UILabel *title = [[UILabel alloc] initWithFrame:view.frame];
    title.attributedText = attrString;
    [view addSubview:title];
    return view;
}

- (PJTextView *)textView
{
    _textView = [[PJTextView alloc] initWithFrame:CGRectMake(0, 50, DeviceW, ScaleH(150))];
    _textView.font = Font(17);
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyGo;
    _textView.keyboardType = UIKeyboardTypeNamePhonePad;
    _hight = CGRectGetMaxY(_textView.frame);
    return _textView;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {//按下return键
        //这里隐藏键盘，不做任何处理
        [textView resignFirstResponder];
        [self eventWithSend];
        return NO;
    }else {
        if ([textView.text length] <= 200) {//判断字符个数
            return YES;
        }
    }
    return NO;
}


- (UIButton *)send
{
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(kDefaultInset.left * 2, CGRectGetMaxY(_textView.frame) + kDefaultInset.top, DeviceW - kDefaultInset.left * 4, 50);
    [sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    sendBtn.titleLabel.font = NFont(18);
    sendBtn.backgroundColor = CustomBlue;
    [sendBtn addTarget:self action:@selector(eventWithSend) forControlEvents:UIControlEventTouchUpInside];
    return sendBtn;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[self header]];
    [self.view addSubview:self.textView];
    [self.view addSubview:[self send]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end