//
//  MobileEmailPasswordVC.m
//  WildFireChat
//
//  Created by Ruby on 12/26/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "MobileEmailPasswordVC.h"
#import "ForgetPasswordSetupVC.h"

#import "LaAreacodeVC.h"


@interface MobileEmailPasswordVC ()<UITextFieldDelegate, XWCountryCodeControllerDelegate>
{
    NSString *_ocsaoxArea_name;
}
@property (weak, nonatomic) IBOutlet UIView *aView;
@property (weak, nonatomic) IBOutlet UIView *aaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aaViewWidth;
@property (weak, nonatomic) IBOutlet UIView *bView;

@property (weak, nonatomic) IBOutlet UILabel *ocsaoxAreaLabel;

@property (weak, nonatomic) IBOutlet UITextField *ocsaoxAccountTF;
@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxSendcodeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation MobileEmailPasswordVC


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([CommonHelper.main isChinese]) {
        self.navigationItem.title = @"找回密码";
    }else {
        self.navigationItem.title = @"Lấy lại mật khẩu";
        
        _ocsaoxAccountTF.placeholder = LLLLLL(@"MobileNumber");
        _ocsaoxCodeTF.placeholder = LLLLLL(@"Code");
        
        [_ocsaoxSendcodeButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
        [_nextButton setTitle:LLLLLL(@"Next") forState:UIControlStateNormal];
    }
    _ocsaoxArea_name = @"+84";
    _ocsaoxAreaLabel.text = _ocsaoxArea_name;
    _aView.layer.cornerRadius = 20.0;
    _bView.layer.cornerRadius = 20.0;
    _nextButton.layer.cornerRadius = 12.0;
    _nextButton.userInteractionEnabled = NO;
    
    _ocsaoxAccountTF.delegate = self;
    _ocsaoxCodeTF.delegate = self;
    [_ocsaoxAccountTF addTarget:self action:@selector(pswTextField:) forControlEvents:UIControlEventEditingChanged];
    [_ocsaoxCodeTF addTarget:self action:@selector(pswTextField:) forControlEvents:UIControlEventEditingChanged];
    
    
    if (_type == 1) {
        _aaView.hidden = YES;
        _aaViewWidth.constant = 5.0;
        _ocsaoxAccountTF.placeholder = LLLLLL(@"Email");
        _ocsaoxAccountTF.keyboardType = UIKeyboardTypeEmailAddress;
    }
}

- (IBAction)next:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_ocsaoxAccountTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxAccountTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
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
    if (_type == 0) {
        url = @"/check_mobile_code";
        params = @{@"area":_ocsaoxArea_name, @"mobile":_ocsaoxAccountTF.text, @"code":_ocsaoxCodeTF.text};
    }else {
        url = @"/check_email_code";
        params = @{@"email":_ocsaoxAccountTF.text, @"code":_ocsaoxCodeTF.text};
    }
    WS(weakself)
    [AppService.sharedAppService requestUrl:url params:params success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        
        ForgetPasswordSetupVC *vc = ForgetPasswordSetupVC.new;
        vc.type = weakself.type;
        vc.code = dict[@"result"];
        vc.account = weakself.ocsaoxAccountTF.text;
        if (weakself.type == 0) {
            vc.area = self->_ocsaoxArea_name;
        }
        [weakself.navigationController pushViewController:vc animated:YES];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        NSString *text = message;
//        if ([CommonHelper.main isChinese]) {
//            text = message;
//        }else {
//            if ([message containsString:@"验证码错误"]) {
//                text = @"Mã xác nhận sai";
//            }else if ([message containsString:@"错误"]) {
//                text = @"Lỗi...";
//            }else {
//                text = @"Lỗi...";
//            }
//        }
        [weakself.view makeToast:text duration:1.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)code:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_type == 0) {
        if (_ocsaoxAccountTF.text.length <= 0) {
            [SVProgressHUD showErrorWithStatus:LLLLLL(@"MobileNumber")];
            [SVProgressHUD dismissWithDelay:1.0];
            return ;
        }
        [CommonHelper.main sendForgetCode:_ocsaoxAccountTF.text area:_ocsaoxArea_name button:sender];
    }else {
        if (_ocsaoxAccountTF.text.length <= 0) {
            [SVProgressHUD showErrorWithStatus:LLLLLL(@"Email")];
            [SVProgressHUD dismissWithDelay:1.0];
            return ;
        }
        [CommonHelper.main sendEmailCodeForForget:_ocsaoxAccountTF.text button:sender];
    }
    _ocsaoxCodeTF.text = @"";
    _nextButton.selected = NO;
    _nextButton.userInteractionEnabled = NO;
}

- (IBAction)phoneAreaCode:(UIButton *)sender { // 电话号码的区号
    [self.view endEditing:YES];
    LaAreacodeVC *vc = LaAreacodeVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    vc.deleagete = self;
    [self.navigationController pushViewController:vc animated:YES];
    _ocsaoxAccountTF.text = @"";
}

- (void)returnCountryName:(NSString *)countryName code:(NSString *)code {
    _ocsaoxAccountTF.text = @"";
    _ocsaoxArea_name = UNString(@"+%@", code);
    _ocsaoxAreaLabel.text = _ocsaoxArea_name;
}

- (void)pswTextField:(UITextField *)textField {
    BOOL account = (_type == 0 ? _ocsaoxAccountTF.text.length >= 6 : _ocsaoxAccountTF.text.length >= 6);
    if (account && _ocsaoxCodeTF.text.length >= 4) {
        if (_nextButton.userInteractionEnabled) {
            return;
        }
        _nextButton.userInteractionEnabled = YES;
        _nextButton.backgroundColor = MAINCOLOR;
    }else {
        if (!_nextButton.userInteractionEnabled) {
            return;
        }
        _nextButton.userInteractionEnabled = NO;
        _nextButton.backgroundColor = RGBA(0xD5D6DA);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger length = textField.text.length - range.length + string.length;
    if (_ocsaoxCodeTF == textField) {
        return (length <= 6);
    }
    if (_ocsaoxAccountTF == textField) {
        if (_type == 0) {
            if ([_ocsaoxArea_name isEqualToString:@"+86"]) {
                return (length <= 11);
            }
            return (length <= 15);
        }
        return (length <= 32);
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)dealloc {
    NSLog(@"%@ --- dealloc",NSStringFromClass(self.class));
}

@end
