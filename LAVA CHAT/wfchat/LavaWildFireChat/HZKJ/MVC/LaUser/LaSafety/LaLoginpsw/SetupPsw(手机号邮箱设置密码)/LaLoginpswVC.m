//
//  LaLoginpswVC.m
//  WildFireChat
//
//  Created by Ruby on 11/15/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaLoginpswVC.h"


@interface LaLoginpswVC ()<UITextFieldDelegate>
{
    NSInteger _login_type; // 登录方式 0 手机号码    1 邮箱
    BOOL _isSendCode;
}
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UIView *aBgView;

@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxSendcodeButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (nonatomic, strong) WFCCUserInfo *userInfo;


@property (weak, nonatomic) IBOutlet UILabel *yanMingL;


@end

@implementation LaLoginpswVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    
    // 登录方式 0 手机号码    1 邮箱
    _login_type = [[NSUserDefaults standardUserDefaults] integerForKey:kLOGIN_TYPE];
    if (_login_type == 0) {
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        NSString *mobile = phones.lastObject;
        NSMutableString *star = NSMutableString.new;
        for (NSInteger i = 0; i < mobile.length-7; i ++) {
            [star appendString:@"*"];
        }
        _phoneLabel.text = [NSString stringWithFormat:@"%@ %@",phones.firstObject, [mobile stringByReplacingCharactersInRange:NSMakeRange(3, mobile.length - 7) withString:UNString(@" %@ ", star)]];
    }else {
        NSArray *emails = [_userInfo.email componentsSeparatedByString:@"@"];
//        _phoneLabel.text = UNString(@"******@%@", emails.lastObject);
        NSString *emailFront = emails.firstObject; // 类似于->Rubyuer
        if (emailFront.length <= 4) {
            if (emailFront.length <= 2) {
                _phoneLabel.text = _userInfo.email;
            }else {
                _phoneLabel.text = [NSString stringWithFormat:@"%@**%@@%@",[emailFront substringToIndex:1], [emailFront substringFromIndex:(emailFront.length-1)], emails.lastObject];
            }
        }else {
            _phoneLabel.text = [NSString stringWithFormat:@"%@****%@@%@",[emailFront substringToIndex:2], [emailFront substringFromIndex:(emailFront.length-2)], emails.lastObject];
        }
    }

    _isSendCode = NO;
    _aBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = false;
    
    _ocsaoxCodeTF.delegate = self;
    [_ocsaoxCodeTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"SetPassword");
    if ([CommonHelper.main isChinese]) {
        _yanMingL.text = @"为了账户安全，我们需要验证身份";
    }else {
        _yanMingL.text = @"Để đảm bảo an toàn tài khoản, chúng tôi cần xác minh danh tính.";
    }
    _ocsaoxCodeTF.placeholder = LLLLLL(@"VerificationCode");
    [_ocsaoxSendcodeButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
    [_okButton setTitle:LLLLLL(@"Next") forState:UIControlStateNormal];
}


- (IBAction)ok:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_ocsaoxCodeTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxCodeTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"InValidation");
    [hud showAnimated:YES];
    
    NSString *url = @"";
    NSDictionary *params = @{};
    if (_login_type == 0) {
        url = @"/check_mobile_code";
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        params = @{@"area":phones.firstObject, @"mobile":phones.lastObject, @"code":_ocsaoxCodeTF.text};
    }else {
        url = @"/check_email_code";
        params = @{@"email":_userInfo.email, @"code":_ocsaoxCodeTF.text};
    }
    WS(weakself)
    [AppService.sharedAppService requestUrl:url params:params success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        
        LaLoginpswOkVC *vc = LaLoginpswOkVC.new;
        vc.code = dict[@"result"];
        [weakself.navigationController pushViewController:vc animated:YES];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}


- (IBAction)sendCode:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *url = @"";
    NSDictionary *params = @{};
    if (_login_type == 0) {
        url = @"/send_update_password_code";
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        params = @{@"area":phones.firstObject, @"mobile":phones.lastObject, @"type":@(0)};
    }else {
        url = @"/send_update_password_email_code";
        params = @{@"email":_userInfo.email, @"type":@(0)};
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


- (void)textField:(UITextField *)textField {
    if (_ocsaoxCodeTF.text.length >= 4) {
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












@interface LaLoginpswOkVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *aBgView;
@property (weak, nonatomic) IBOutlet UIView *bBgView;

@property (weak, nonatomic) IBOutlet UITextField *newsPswTF;
@property (weak, nonatomic) IBOutlet UITextField *newsPswATF;

@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (nonatomic, strong) WFCCUserInfo *userInfo;

@end


@implementation LaLoginpswOkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _aBgView.layer.cornerRadius = 10.0;
    _bBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = false;
    
    _newsPswTF.delegate = self;
    _newsPswATF.delegate = self;
    [_newsPswTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    [_newsPswATF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"SetLoginPassword");
    
    _newsPswTF.placeholder = LLLLLL(@"EnterLoginPassword");
    _newsPswATF.placeholder = LLLLLL(@"ModityLoginPassword");
    [_okButton setTitle:LLLLLL(@"Submit") forState:UIControlStateNormal];
}

- (IBAction)ok:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_newsPswTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_newsPswTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    if (_newsPswATF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_newsPswATF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    if (![_newsPswTF.text isEqualToString:_newsPswATF.text]) {
        [SVProgressHUD showErrorWithStatus:LLLLLL(@"TheTwoPasswordsDoNotMatch")];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    
    // 登录方式 0 手机号码    1 邮箱
    NSInteger login_type = [[NSUserDefaults standardUserDefaults] integerForKey:kLOGIN_TYPE];

    NSMutableDictionary *params = NSMutableDictionary.new;
    params[@"type"] = @(login_type);
    params[@"code"] = _code;
    params[@"newPassword"] = _newsPswTF.text;
    
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/change_pwd" params:params success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"kHasPassword"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [NSNotificationCenter.defaultCenter postNotificationName:kMODITY_MOBILE_EMAIL_NOTI object:@{@"loginPsw":@(1)}];
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:NSClassFromString(@"LaSafetyVC")]) {
                [weakself.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}

- (void)textField:(UITextField *)textField {
    if (_newsPswTF.text.length >= 6 && _newsPswATF.text.length >= 6) {
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
    if (_newsPswTF == textField || _newsPswATF == textField) {
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

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
@end
