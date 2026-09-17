//
//  LaLoginpswVerifyVC.m
//  WildFireChat
//
//  Created by Ruby on 1/23/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaLoginpswVerifyVC.h"

#import "LaMobileEmailVerifyVC.h"

@interface LaLoginpswVerifyVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *aBgView;
@property (weak, nonatomic) IBOutlet UIView *bBgView;
@property (weak, nonatomic) IBOutlet UIView *cBgView;

@property (weak, nonatomic) IBOutlet UITextField *oldPswTF;
@property (weak, nonatomic) IBOutlet UITextField *newsPswATF;
@property (weak, nonatomic) IBOutlet UITextField *newsPswBTF;

@property (weak, nonatomic) IBOutlet UIButton *okButton;


@property (weak, nonatomic) IBOutlet UILabel *safetyL;
@property (weak, nonatomic) IBOutlet UIButton *codeVerificationBtn;

@end

@implementation LaLoginpswVerifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _aBgView.layer.cornerRadius = 10.0;
    _bBgView.layer.cornerRadius = 10.0;
    _cBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = NO;
    
    _oldPswTF.delegate = self;
    _newsPswATF.delegate = self;
    _newsPswBTF.delegate = self;
    [_oldPswTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    [_newsPswATF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    [_newsPswBTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"ModityLoginPassword");
    [_okButton setTitle:LLLLLL(@"Submit") forState:UIControlStateNormal];
    
    if ([CommonHelper.main isChinese]) {
        
    }else {
        _safetyL.text = @"Để đảm bảo an toàn tài khoản, chúng tôi cần xác minh danh tính.";
        
        _oldPswTF.placeholder = @"Mật khẩu cũ";
        _newsPswATF.placeholder = @"Mật khẩu mới";
        _newsPswBTF.placeholder = @"Xác nhận";
        
        [_codeVerificationBtn setTitle:@"Xác minh mã xác minh" forState:UIControlStateNormal];
    }
}

- (IBAction)ok:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_oldPswTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_oldPswTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    if (_newsPswATF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_newsPswATF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    if (_newsPswBTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_newsPswBTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    if (![_newsPswATF.text isEqualToString:_newsPswBTF.text]) {
        [SVProgressHUD showErrorWithStatus:LLLLLL(@"TheTwoPasswordsDoNotMatch")];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    
    WS(weakself)
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    [AppService.sharedAppService requestUrl:@"/change_pwd" params:@{@"oldPassword":_oldPswTF.text, @"newPassword":_newsPswATF.text, @"type":@(2)} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:NSClassFromString(@"LaSafetyVC")]) {
                    [weakself.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        });
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}


- (IBAction)code_verify:(UIButton *)sender {
    LaMobileEmailVerifyVC *vc = LaMobileEmailVerifyVC.new;
    NSInteger login_type = [NSUserDefaults.standardUserDefaults integerForKey:kLOGIN_TYPE];
    vc.isMobile = (login_type == 0 ? YES : NO);
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)textField:(UITextField *)textField {
    if (_oldPswTF.text.length >= 6 && _newsPswATF.text.length >= 6 && _newsPswBTF.text.length >= 6) {
        if (_okButton.userInteractionEnabled) {
            return;
        }
        _okButton.userInteractionEnabled = YES;
        _okButton.backgroundColor = MAINCOLOR;
    }else {
        if (!_okButton.userInteractionEnabled) {
            return;
        }
        _okButton.userInteractionEnabled = NO;
        _okButton.backgroundColor = RGBA(0xD5D6DA);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger length = textField.text.length - range.length + string.length;
    if (_oldPswTF == textField || _newsPswATF == textField || _newsPswBTF == textField) {
        return (length <= 16);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
