//
//  LaMobileBindingVC.m
//  WildFireChat
//
//  Created by Ruby on 1/24/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMobileBindingVC.h"

#import "LaAreacodeVC.h"

@interface LaMobileBindingVC ()<UITextFieldDelegate, XWCountryCodeControllerDelegate>
{
    NSString *_ocsaoxArea_name; // 手机区号
}
@property (weak, nonatomic) IBOutlet UIView *aBgView;
@property (weak, nonatomic) IBOutlet UIView *bBgView;

@property (weak, nonatomic) IBOutlet UILabel *ocsaoxAreaLabel;
@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxSendcodeButton;

@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation LaMobileBindingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _ocsaoxArea_name = @"+84";
    _ocsaoxAreaLabel.text = @"+84";
    
    _aBgView.layer.cornerRadius = 10.0;
    _bBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = NO;
    
    _ocsaoxCodeTF.delegate = self;
    _mobileTF.delegate = self;
    [_ocsaoxCodeTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    [_mobileTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"SetPhoneNumber");
    
    _mobileTF.placeholder = LLLLLL(@"MobileNumbers");
    _ocsaoxCodeTF.placeholder = LLLLLL(@"VerificationCode");
    
    [_ocsaoxSendcodeButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
    [_okButton setTitle:LLLLLL(@"Binding") forState:UIControlStateNormal];
}

- (IBAction)ok:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_mobileTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_mobileTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    if (_ocsaoxCodeTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxCodeTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/change_mobile" params:@{@"area":_ocsaoxArea_name, @"mobile":_mobileTF.text, @"code":_ocsaoxCodeTF.text} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];
        
        [NSNotificationCenter.defaultCenter postNotificationName:kMODITY_MOBILE_EMAIL_NOTI object:@{@"mobile":[NSString stringWithFormat:@"%@ %@",self->_ocsaoxArea_name, weakself.mobileTF.text]}];
        
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
    if (_mobileTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_mobileTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    NSMutableDictionary *params = NSMutableDictionary.new;
    params[@"area"] = _ocsaoxArea_name;
    params[@"mobile"] = _mobileTF.text;
    if (_returnCode.length) {
        params[@"code"] = _returnCode;
    }
    sender.userInteractionEnabled = NO;
    [AppService.sharedAppService requestUrl:@"/send_update_mobile_code_2" params:params success:^(NSDictionary * _Nonnull dict) {
        sender.userInteractionEnabled = NO;
        [SVProgressHUD showSuccessWithStatus:LLLLLL(@"SentSuccessfully")];
        [SVProgressHUD dismissWithDelay:1.0];
        [CommonHelper.main handleTimer:sender];
    } error:^(int errCode, NSString * _Nonnull message) {
        sender.userInteractionEnabled = YES;
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)area:(UIButton *)sender {
    [self.view endEditing:YES];
    LaAreacodeVC *vc = LaAreacodeVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    vc.deleagete = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)returnCountryName:(NSString *)countryName code:(NSString *)code {
    _mobileTF.text = @"";
    _ocsaoxArea_name = UNString(@"+%@", code);
    _ocsaoxAreaLabel.text = _ocsaoxArea_name;
}


- (void)textField:(UITextField *)textField {
    if (_mobileTF.text.length >= 6 && _ocsaoxCodeTF.text.length >= 4) {
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
    if (_mobileTF == textField) {
        if ([_ocsaoxArea_name isEqualToString:@"+86"]) {
            return (length <= 11);
        }
        return (length <= 15);
    }
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

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}


@end
