//
//  LaMobileEmailVerifyVC.m
//  WildFireChat
//
//  Created by Ruby on 1/23/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMobileEmailVerifyVC.h"

#import "LaLoginpswVerifyVC.h"


@interface LaMobileEmailVerifyVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mobileEmailLabel;

@property (weak, nonatomic) IBOutlet UIView *aBgView;
@property (weak, nonatomic) IBOutlet UIView *bBgView;

@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (nonatomic, strong) WFCCUserInfo *userInfo;


@property (weak, nonatomic) IBOutlet UILabel *safetyL;
@property (weak, nonatomic) IBOutlet UIButton *loginPswVerificationButton;

@end

@implementation LaMobileEmailVerifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _aBgView.layer.cornerRadius = 10.0;
    _bBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = NO;
    
    _ocsaoxCodeTF.delegate = self;
    _pswTF.delegate = self;
    [_ocsaoxCodeTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    [_pswTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    if (_isMobile) { // 手机
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        NSString *mobile = phones.lastObject;
        NSMutableString *star = NSMutableString.new;
        for (NSInteger i = 0; i < mobile.length-7; i ++) {
            [star appendString:@"*"];
        }
        _mobileEmailLabel.text = [NSString stringWithFormat:@"%@ %@",phones.firstObject, [mobile stringByReplacingCharactersInRange:NSMakeRange(3, mobile.length - 7) withString:UNString(@" %@ ", star)]];
    }else { // 邮箱
        NSArray *emails = [_userInfo.email componentsSeparatedByString:@"@"];
//        _mobileEmailLabel.text = UNString(@"******@%@", emails.lastObject);
        NSString *emailFront = emails.firstObject; // 类似于->Rubyuer
        if (emailFront.length <= 4) {
            if (emailFront.length <= 2) {
                _mobileEmailLabel.text = _userInfo.email;
            }else {
                _mobileEmailLabel.text = [NSString stringWithFormat:@"%@**%@@%@",[emailFront substringToIndex:1], [emailFront substringFromIndex:(emailFront.length-1)], emails.lastObject];
            }
        }else {
            _mobileEmailLabel.text = [NSString stringWithFormat:@"%@****%@@%@",[emailFront substringToIndex:2], [emailFront substringFromIndex:(emailFront.length-2)], emails.lastObject];
        }
    }
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"ModityLoginPassword");
    [_sendButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
    [_okButton setTitle:LLLLLL(@"Submit") forState:UIControlStateNormal];
    
    _ocsaoxCodeTF.placeholder = LLLLLL(@"VerificationCode");
     
    [_loginPswVerificationButton setTitle:LLLLLL(@"LoginPasswordVerification") forState:UIControlStateNormal];
    
    if ([CommonHelper.main isChinese]) {
        
    }else {
        _safetyL.text = @"Để đảm bảo an toàn tài khoản, chúng tôi cần xác minh danh tính.";
        
        _pswTF.placeholder = @"Mật khẩu mới";
    }
}
 
- (IBAction)ok:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_ocsaoxCodeTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxCodeTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    if (_pswTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_pswTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    WS(weakself) //  type -> 0邮箱 1 手机 2 旧密码
    NSDictionary *params = @{@"code":_ocsaoxCodeTF.text, @"newPassword":_pswTF.text, @"type":@(_isMobile ? 1 : 0)};
    [AppService.sharedAppService requestUrl:@"/change_pwd" params:params success:^(NSDictionary * _Nonnull dict) {
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

- (IBAction)send:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *url = @"";
    NSDictionary *params = @{};
    if (_isMobile) {
        url = @"/send_update_password_code";
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        params = @{@"area":phones.firstObject, @"mobile":phones.lastObject, @"type":@(1)};
    }else {
        url = @"/send_update_password_email_code";
        params = @{@"email":_userInfo.email, @"type":@(1)}; // type 0 设置密码 1修改密码
    }
    sender.userInteractionEnabled = NO;
    [AppService.sharedAppService requestUrl:url params:params success:^(NSDictionary * _Nonnull dict) {
        sender.userInteractionEnabled = NO;
        [SVProgressHUD showSuccessWithStatus:LLLLLL(@"SentSuccessfully")];
        [SVProgressHUD dismissWithDelay:1.0];
        [CommonHelper.main handleTimer:sender];
    } error:^(int errCode, NSString * _Nonnull message) {
        sender.userInteractionEnabled = YES;
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
    _ocsaoxCodeTF.text = @"";
}

- (IBAction)login_psw_verify:(UIButton *)sender {
    LaLoginpswVerifyVC *vc = LaLoginpswVerifyVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)textField:(UITextField *)textField {
    if (_ocsaoxCodeTF.text.length >= 4 && _pswTF.text.length >= 6) {
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
    if (_ocsaoxCodeTF == textField) {
        return (length <= 6);
    }
    if (_pswTF == textField) {
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
