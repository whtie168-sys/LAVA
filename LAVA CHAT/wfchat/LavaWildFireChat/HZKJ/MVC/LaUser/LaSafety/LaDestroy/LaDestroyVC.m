//
//  LaDestroyVC.m
//  WildFireChat
//
//  Created by Ruby on 1/22/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaDestroyVC.h"
#import "OrgService.h"


@interface LaDestroyVC ()
{
    NSInteger _type; // 登录方式 0 手机号  1 邮箱
    
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UILabel *descLLL;

@property (weak, nonatomic) IBOutlet UILabel *codeL;
@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UIButton *destroyButton;

@end

@implementation LaDestroyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _sendButton.layer.cornerRadius = 5.0;
    _sendButton.layer.borderWidth = 1.0;
    _sendButton.layer.borderColor = RGBA(0x2c2c2c).CGColor;
    _destroyButton.layer.cornerRadius = 20.0;
    
    _type = [NSUserDefaults.standardUserDefaults integerForKey:kLOGIN_TYPE];
    
    _isChinese = [CommonHelper.main isChinese];
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"DestroyAccount");
    _ocsaoxCodeTF.placeholder = LLLLLL(@"VerificationCode");
    [_sendButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
    if (_isChinese) {
        
    }else {
        _descLLL.text = @"Bạn chắc chắn muốn hủy tài khoản này chứ 😭😭😭!";
        _codeL.text = @"Mã xác nhận";
        
        [_destroyButton setTitle:@"Hủy tài khoản" forState:UIControlStateNormal];
    }
}

- (IBAction)destroy:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_ocsaoxCodeTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxCodeTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    WS(weakself)
    [AppService.sharedAppService destroyAccount:@{@"type":@(_type), @"code":_ocsaoxCodeTF.text} success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedName"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedToken"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedUserId"];
            [[AppService sharedAppService] clearAppServiceAuthInfos];
            [[OrgService sharedOrgService] clearOrgServiceAuthInfos];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //服务器已经删除所有信息了，这里都传NO。不能传YES，如果传YES协议栈会需要跟IM服务进行交互。
            [[WFCCNetworkService sharedInstance] disconnect:NO clearSession:NO];
        });
    } error:^(int errorCode, NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"login error with code %d, message %@", errorCode, message);
            [hud hideAnimated:YES];
            [weakself.view makeToast:message duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

- (IBAction)send:(UIButton *)sender {
    [self.view endEditing:YES];
    _ocsaoxCodeTF.text = @"";
    sender.userInteractionEnabled = NO;
    [sender setTitle:(_isChinese ? @"短信发送中" : @"gửi...") forState:UIControlStateNormal];
    WS(weakself)
    [AppService.sharedAppService sendDestroyAccountCode:@{@"type":@(_type)} success:^{
        [weakself.view makeToast:LLLLLL(@"SentSuccessfully") duration:1.0 position:CSToastPositionCenter];
        [CommonHelper.main handleTimer:sender];
    } error:^(int errorCode, NSString * _Nonnull message) {
        sender.userInteractionEnabled = YES;
        [sender setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
        NSString *text = message;
        [weakself.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
