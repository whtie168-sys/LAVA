//
//  LaGetCodeVC.m
//  WildFireChat
//
//  Created by Ruby on 12/7/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaGetCodeVC.h"

#import "LaNumberVC.h"

@interface LaGetCodeVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UIView *aBgView;

@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxSendcodeButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;


@property (weak, nonatomic) IBOutlet UILabel *yanMingL;

@end

@implementation LaGetCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    WFCCUserInfo *userinfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    _phoneLabel.text = userinfo.mobile;
    
    _aBgView.layer.cornerRadius = 10.0;
    _okButton.layer.cornerRadius = 12.0;
    _okButton.userInteractionEnabled = NO;
    
    _ocsaoxCodeTF.delegate = self;
    [_ocsaoxCodeTF addTarget:self action:@selector(textField:) forControlEvents:UIControlEventEditingChanged];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    if ([CommonHelper.main isChinese]) {
        self.navigationItem.title = @"忘记数字密码";
    }else {
        self.navigationItem.title = @"Quên mật khẩu số";
        _yanMingL.text = @"Để đảm bảo an toàn tài khoản, chúng tôi cần xác minh danh tính.";
        
        _ocsaoxCodeTF.placeholder = LLLLLL(@"VerificationCode");
        [_ocsaoxSendcodeButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
        [_okButton setTitle:LLLLLL(@"OK") forState:UIControlStateNormal];
    }
}

- (IBAction)ok:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_ocsaoxCodeTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxCodeTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    LaNumberVC *vc = LaNumberVC.new;
    vc.code = _ocsaoxCodeTF.text;
    vc.type = 3;
    [self.navigationController pushViewController:vc animated:YES];
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.label.text = @"验证中...";
//    [hud showAnimated:YES];
//    
//    __weak typeof(self)ws = self;
//    [[AppService sharedAppService] resetPassword:@"" code:_ocsaoxCodeTF.text newPassword:@"" success:^{
//        [hud hideAnimated:YES];
//        
//        
//    } error:^(int errCode, NSString * _Nonnull message) {
//        [hud hideAnimated:YES];
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = message;
//        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
//        [hud hideAnimated:YES afterDelay:1.f];
//    }];
}

- (IBAction)sendCode:(UIButton *)sender {
    [self.view endEditing:YES];
    [CommonHelper.main send_reset_device_code_button:sender];
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
