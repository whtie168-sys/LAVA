//
//  LaEmailBindingVC.m
//  WildFireChat
//
//  Created by Ruby on 1/24/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaEmailBindingVC.h"

@interface LaEmailBindingVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *aBgView;
@property (weak, nonatomic) IBOutlet UIView *bBgView;

@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxSendcodeButton;

@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation LaEmailBindingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _aBgView.layer.cornerRadius = 10.0;
    _bBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = NO;
    
    _ocsaoxCodeTF.delegate = self;
    _emailTF.delegate = self;
    [_ocsaoxCodeTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    [_emailTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"SetEmail");
    
    _emailTF.placeholder = LLLLLL(@"E-mail");
    _ocsaoxCodeTF.placeholder = LLLLLL(@"VerificationCode");
    [_ocsaoxSendcodeButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
    [_okButton setTitle:LLLLLL(@"Binding") forState:UIControlStateNormal];
}

- (IBAction)ok:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_emailTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_emailTF.placeholder];
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
    [AppService.sharedAppService requestUrl:@"/change_email" params:@{@"email":_emailTF.text, @"code":_ocsaoxCodeTF.text} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];
        
        [NSNotificationCenter.defaultCenter postNotificationName:kMODITY_MOBILE_EMAIL_NOTI object:@{@"email":weakself.emailTF.text}];
        
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
    if (_emailTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_emailTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    WS(weakself)
    NSMutableDictionary *params = NSMutableDictionary.new;
    params[@"email"] = _emailTF.text;
    if (_returnCode.length) {
        params[@"code"] = _returnCode;
    }
    sender.userInteractionEnabled = NO;
    [AppService.sharedAppService requestUrl:@"/send_update_email_code_2" params:params success:^(NSDictionary * _Nonnull dict) {
        sender.userInteractionEnabled = NO;
        [SVProgressHUD showSuccessWithStatus:LLLLLL(@"SentSuccessfully")];
        [SVProgressHUD dismissWithDelay:1.0];
        [CommonHelper.main handleTimer:sender];
        weakself.ocsaoxCodeTF.text = @"";
    } error:^(int errCode, NSString * _Nonnull message) {
        sender.userInteractionEnabled = YES;
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}

- (void)textField:(UITextField *)textField {
    if (_emailTF.text.length >= 6 && _ocsaoxCodeTF.text.length >= 4) {
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
    if (_emailTF == textField) {
        return (length <= 50);
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
