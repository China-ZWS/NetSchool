//
//  AddToQATheme.m
//  NetSchool
//
//  Created by 周文松 on 15/9/28.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "AddToQATheme.h"
#import "PJTextField.h"
#import "PJTextView.h"
#import "PJInputView.h"
#import "ClassPickerView.h"
#import "MyClass.h"
#import "MyVideo.h"

@interface QAInputView : PJInputView
{
}
@property (nonatomic, strong) PJTextField *className;
@property (nonatomic, strong) NSString *classId;
@property (nonatomic, strong) PJTextField *lessonName;
@property (nonatomic, strong) NSString *lessonId;
@property (nonatomic, strong) PJTextField *textField;
@property (nonatomic, strong) PJTextView *textView;
@property (nonatomic, strong) UILabel *text1;
@property (nonatomic, strong) UILabel *text2;

@end

@implementation QAInputView

- (id) initWithFrame:(CGRect)frame success:(void (^)())success
{
    if ((self = [super initWithFrame:frame success:success]))
    {
        self.backgroundColor = [UIColor whiteColor];
        [self layoutViews];
    }
    return self;
}

- (UILabel *)text1
{
    if (!_text1) {
        NSString *title = @"所属班级：";
        CGSize titleSize = [NSObject getSizeWithText:title font:NFont(17) maxSize:CGSizeMake(MAXFLOAT, NFont(17).lineHeight)];
        _text1 = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultInset.left, kDefaultInset.top, titleSize.width, 60)];
        _text1.text = title;
        _text1.font = NFont(17);
    }
    return _text1;
}

- (UILabel *)text2
{
    if (!_text2) {
        NSString *title = @"课程资源：";
        CGSize titleSize = [NSObject getSizeWithText:title font:NFont(17) maxSize:CGSizeMake(MAXFLOAT, NFont(17).lineHeight)];
        _text2 = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultInset.left, CGRectGetMaxY(_text1.frame) + kDefaultInset.top, titleSize.width, 60)];
        _text2.text = title;
        _text2.font = NFont(17);
    }
    return _text2;
}

- (PJTextField *)className
{
    if (!_className) {
        _className = [[PJTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_text1.frame) + kDefaultInset.left,CGRectGetMinY(_text1.frame) + 5, CGRectGetWidth(self.frame) - kDefaultInset.left * 2 - CGRectGetMaxX(_text1.frame), 50)];
        _className.placeholder = @"未选";
        UIImageView *rV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boss_unipay_ic_arrdown.png"]];
        _className.rightView = rV;
        _className.returnKeyType = UIReturnKeyNext;
        _className.delegate = self;
        _className.font = NFont(15);
    }
    return _className;
}

- (PJTextField *)lessonName
{
    if (!_lessonName) {
        _lessonName = [[PJTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_text2.frame) + kDefaultInset.left,CGRectGetMinY(_text2.frame) + 5, CGRectGetWidth(self.frame) - kDefaultInset.left * 2 - CGRectGetMaxX(_text2.frame), 50)];
        UIImageView *rV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boss_unipay_ic_arrdown.png"]];
        _lessonName.rightView = rV;
        _lessonName.placeholder = @"未选";
        _lessonName.returnKeyType = UIReturnKeyNext;
        _lessonName.delegate = self;
        _lessonName.font = NFont(15);
    }
    return _lessonName;
}

- (PJTextField *)textField
{
    if (!_textField) {
        _textField = [[PJTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(_text2.frame), CGRectGetMaxY(_text2.frame) + kDefaultInset.top , CGRectGetWidth(self.frame) - CGRectGetMinX(_text2.frame) * 2, 50)];
        _textField.returnKeyType = UIReturnKeyNext;
        _textField.delegate = self;
        _textField.font = NFont(15);
        _textField.placeholder = @"请输入标题";
    }
    return _textField;
}

- (PJTextView *)textView
{
    if (!_textView) {
        _textView = [[PJTextView  alloc] initWithFrame:CGRectMake(CGRectGetMinX(_textField.frame), CGRectGetMaxY(_textField.frame) + 2 * kDefaultInset.top, CGRectGetWidth(_textField.frame), 130)];
        _textView.font = Font(17);
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyGo;
        _textView.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    return _textView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if ([textField isEqual:_textField])
    {
        if ([textField resignFirstResponder])
            [_textView becomeFirstResponder];
    }
    return NO;
}


- (void)layoutViews
{
    [self addSubview:self.text1];
    [self addSubview:self.text2];
    [self addSubview:self.className];
    [self addSubview:self.lessonName];
    [self addSubview:self.textField];
    [self addSubview:self.textView];
    
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
{
    [super textFieldDidBeginEditing:textField];
    QAInputView __weak *safeSelf = self;
    if ([textField isEqual:_className])
    {
        textField.inputView=[[ClassPickerView alloc] initWithSuccess:^(id datas)
                             {
                                 textField.text = datas[@"name"];
                                 safeSelf.classId = datas[@"id"];
                                 
                             }datas:[MyClass coreDataQuery] target:self status:kClass];
        textField.inputAccessoryView = nil;
    }
    else if ([textField isEqual:_lessonName])
    {
        [_className resignFirstResponder];
        if (!_classId) {
            [self makeToast:@"请先选好所属班级"];
            return NO;
        }
        textField.inputView=[[ClassPickerView alloc] initWithSuccess:^(id datas)
                             {
                                 textField.text = datas[@"name"];
                                 safeSelf.lessonId = datas[@"id"];
                             }datas:[MyVideo coreDataQuery:@{@"id":_classId}] target:self status:kLesson];
        textField.inputAccessoryView = nil;
    }
    
    return YES;
}

@end

@interface AddToQATheme ()
{
    QAInputView *_inputView;
    void(^_success)();
}
@end

@implementation AddToQATheme

- (id)initWithSuccess:(void(^)())success;
{
    if ((self = [super init])) {
        [self.navigationItem setNewTitle:@"新问题"];
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(back) image:@"back.png"];
        _success = success;
    }
    return self;
}

- (void)back
{
    [self popViewController];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    AddToQATheme __weak *safeSelf = self;
    _inputView = [[QAInputView  alloc] initWithFrame:CGRectMake(kDefaultInset.left, kDefaultInset.top, DeviceW - kDefaultInset.left * 2, 300 + 6 * kDefaultInset.top) success:^{
        [safeSelf eventWithSignup];
    }];
    [self.view addSubview:_inputView];
    
    UIButton *signUp = [UIButton buttonWithType:UIButtonTypeCustom];
    signUp.frame = CGRectMake(defaultInset.left * 2, CGRectGetMaxY(_inputView.frame) + defaultInset.top, DeviceW - defaultInset.left * 4, 50);
    signUp.backgroundColor = CustomBlue;
    signUp.titleLabel.font = Font(18);
    [signUp setTitle:@"提 交" forState:UIControlStateNormal];
    [signUp addTarget:self action:@selector(eventWithSignup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUp];
}

- (void)eventWithSignup
{
    [self.view endEditing:YES];
    if (!_inputView.classId) {
        [self.view makeToast:@"请选好所属班级"];
        return;
    }
    if (!_inputView.lessonId) {
        [self.view makeToast:@"请选好课程资源"];
        return;
    }
    if ([_inputView.textField.text isEqualToString:@""]) {
        [self.view makeToast:@"请填上问题的标题"];
        return;
    }
    if ([_inputView.textView.text isEqualToString:@""]) {
        [self.view makeToast:@"请填上问题的类容"];
        return;
    }
    
    [MBProgressHUD showMessag:@"提交中..." toView:self.view];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"title"] = _inputView.textField.text;
    params[@"content"] = _inputView.textView.text;
    params[@"lessonId"] = _inputView.lessonId;
    params[@"randUserId"] = [Infomation readInfo][@"data"][@"randUserId"];
    [params setPublicDomain];
    _connection = [BaseModel POST:URL(@"api/m/aq/topic/add") parameter:params   class:[BaseModel class]
                          success:^(id data)
                   {
                       [self back];
                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                       _success();
                   }
                          failure:^(NSString *msg, NSString *state)
                   {
                       [self.view makeToast:msg];
                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                   }];
    
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
