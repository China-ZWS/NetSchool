//
//  ClassPickerView.m
//  NetSchool
//
//  Created by 周文松 on 15/9/29.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import "ClassPickerView.h"
#define kToolViewHeight 44

@interface ClassPickerView ()
<UIPickerViewDataSource, UIPickerViewDelegate>
{
    id _target;
    void(^_success)(id datas);
    NSArray *_array1;
    NSArray *_array2;
    NSDictionary *_selectDatas;
    Status _status;
}
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UIToolbar *toolBar;
@end

@implementation ClassPickerView

- (id)initWithSuccess:(void (^)(id))success datas:(id)datas target:(id)target status:(Status)status;
{
    if ((self = [super init])) {
        _success = success;
        _target = target;
        _status = status;
        
        
        if (status == kClass) {
            _array1 = [self loadDatas:datas];
            _array2 = _array1[0][@"children"];
            if (_array2.count) {
                _selectDatas = _array2[0];
            }
        }
        else
        {
            _array1 = datas;
            _selectDatas = _array1[0];
            
        }
        
        [self layoutViews];
    }
    return self;
}

- (UIPickerView *)picker
{
    if (!_picker) {
        _picker = [UIPickerView new];
        _picker.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY(_picker.frame) + kToolViewHeight);
        _picker.backgroundColor = [UIColor clearColor];
        _picker.delegate=self;
        _picker.dataSource=self;
    }
    return _picker;
}

- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DeviceW, kToolViewHeight)];
        UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
        
        UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
        _toolBar.items=@[lefttem,centerSpace,right];
    }
    return _toolBar;
    
}
#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_status == kClass) {
        return 2;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return _array1.count;
            break;
        case 1:
            return _array2.count;
            break;
        default:
            return 0;
            break;
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

{
    UILabel *myView = [UILabel new];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.font = NFont(17);         //用label来设置字体大小
    myView.backgroundColor = [UIColor clearColor];
    myView.numberOfLines = 0;
    myView.textColor = [UIColor blackColor];

    if (component == 0)
        myView.text = _array1[row][@"name"];
    else
        myView.text = _array2[row][@"name"];
    return myView;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component

{
    return 55;
}

- (void)setFrameWithSelf
{
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(_picker.frame) - CGRectGetHeight(_toolBar.frame);
    rect.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
    rect.size.height = CGRectGetHeight(_picker.frame) + CGRectGetHeight(_toolBar.frame);
    self.frame = rect;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            if (_status == kClass) {
                _array2 = _array1[row][@"children"];
                [_picker selectRow:0 inComponent:1 animated:NO];
                [_picker reloadComponent:1];
                if (_array2.count) {
                    _selectDatas = _array2[0];
                }
            }
            else
            {
                _selectDatas = _array1[row];
            }
        }
            break;
        case 1:
            _selectDatas = _array2[row];
            break;
        default:
            break;
    }
}


- (void)layoutViews
{
    [self addSubview:self.picker];
    [self addSubview:self.toolBar];
    [self setFrameWithSelf];
}

- (void)remove
{
    [_target endEditing:YES];
    _target = nil;
}

- (void)doneClick
{
    [_target endEditing:YES];
    _target = nil;
    _success(_selectDatas);
}

- (NSArray *)loadDatas:(id)datas
{
    NSMutableArray *tree = [NSMutableArray array];
    
    
    for (NSDictionary *dic in datas)
    {
        NSMutableDictionary *dic0 = [NSMutableDictionary dictionaryWithDictionary:dic];
        if ([dic0[@"id"] length] && ![dic0[@"pid"] length])
        {
            NSArray *children = [datas filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pid == %@",dic0[@"id"]]];
            if (children.count) {
                dic0[@"children"] = children;
            }
            else
            {
                dic0[@"children"] = [NSArray arrayWithObject:dic];
            }
            [tree addObject:dic0];
        }
    }
    if (!tree.count) {
        return nil;
    }
    return tree;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
