//
//  LaMobileEmailVerityVC.m
//  WildFireChat
//
//  Created by Ruby on 1/24/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMobileEmailVerityVC.h"

#import "LaMobileBindingVC.h"
#import "LaEmailBindingVC.h"

@interface LaMobileEmailVerityVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mobileEmailLabel;

@property (weak, nonatomic) IBOutlet UIView *aBgView;

@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxSendcodeButton;

@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (nonatomic, strong) WFCCUserInfo *userInfo;

@property (weak, nonatomic) IBOutlet UILabel *safetyL;


@end

@implementation LaMobileEmailVerityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    if (_type == 0) {
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        NSString *mobile = phones.lastObject;
        NSMutableString *star = NSMutableString.new;
        for (NSInteger i = 0; i < mobile.length-7; i ++) {
            [star appendString:@"*"];
        }
        _mobileEmailLabel.text = [NSString stringWithFormat:@"%@ %@",phones.firstObject, [mobile stringByReplacingCharactersInRange:NSMakeRange(3, mobile.length - 7) withString:UNString(@" %@ ", star)]];
    }else {
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
    
    _aBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = NO;
    
    _ocsaoxCodeTF.delegate = self;
    [_ocsaoxCodeTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    if (_type == 0) {
        self.navigationItem.title = LLLLLL(@"ModifyMobilePhone");
    }else {
        self.navigationItem.title = LLLLLL(@"ModifyEmail");
    }
    if ([CommonHelper.main isChinese]) {
        
    }else {
        _safetyL.text = @"Để đảm bảo an toàn tài khoản, chúng tôi cần xác minh danh tính, nhập mã xác nhận từ email cũ để tiến hành xác minh";
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
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    NSString *url = @"";
    if (_type == 0) {
        url = @"/check_update_mobile_code_1";
    }else {
        url = @"/check_update_email_code_1";
    }
    WS(weakself)
    [AppService.sharedAppService requestUrl:url params:@{@"code":_ocsaoxCodeTF.text} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        if (weakself.type == 0) {
            LaMobileBindingVC *vc = LaMobileBindingVC.new;
            vc.returnCode = dict[@"result"];
            [weakself.navigationController pushViewController:vc animated:YES];
        }else {
            LaEmailBindingVC *vc = LaEmailBindingVC.new;
            vc.returnCode = dict[@"result"];
            [weakself.navigationController pushViewController:vc animated:YES];
        }
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}


- (IBAction)send:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *url = @"";
    NSDictionary *params = @{};
    if (_type == 0) {
        url = @"/send_update_mobile_code_1";
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        params = @{@"area":phones.firstObject, @"mobile":phones.lastObject};
    }else {
        url = @"/send_update_email_code_1";
        params = @{@"email":_userInfo.email};
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
