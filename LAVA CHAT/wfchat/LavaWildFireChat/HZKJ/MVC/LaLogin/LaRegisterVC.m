//
//  LaRegisterVC.m
//  WildFireChat
//
//  Created by Ruby on 12/25/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaRegisterVC.h"
#import "KeyChainTool.h"

#import "LaProtocolVC.h"
#import "LaAreacodeVC.h"
#import "LaTabBarVC.h"

#import "LaMessageVC.h"
#import "LaWebviewVC.h"
#import "RegisterSetAvatarVC.h"

@interface LaRegisterVC ()<UITextFieldDelegate, UIScrollViewDelegate, XWCountryCodeControllerDelegate>
{
    NSInteger _eogcsaioxType; // 手机 or 邮箱
    
    NSString *_ocsaoxArea_name; // 手机区号
    CGFloat _area_view_width; // 手机区号的宽度
    
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *boxBgView;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxRegisterTypeAButton;
@property (weak, nonatomic) IBOutlet UIButton *ocsaoxRegisterTypeBButton;

@property (weak, nonatomic) IBOutlet UITextField *ocsaoxAccountTF;
@property (weak, nonatomic) IBOutlet UITextField *ocsaoxCodeTF;
@property (weak, nonatomic) IBOutlet UIImageView *ocsaoxAccountImgView;
@property (weak, nonatomic) IBOutlet UILabel *ocsaoxAccountLabel;
@property (weak, nonatomic) IBOutlet UILabel *ocsaoxCodeLabel;
@property (weak, nonatomic) IBOutlet UIButton *ocsaoxSendcodeButton;

@property (weak, nonatomic) IBOutlet UIView *ocsaoxAreaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ocsaoxAreaViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *ocsaoxAreaLabel;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxRegisterButton;

@property (weak, nonatomic) IBOutlet UILabel *ocsaoxHaveAmountL;
@property (weak, nonatomic) IBOutlet UILabel *ocsaoxGoLoginL;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxProtocolButton;
@property (weak, nonatomic) IBOutlet UILabel *andL;
@property (weak, nonatomic) IBOutlet UIButton *ocsaoxUserProtocolBtn;
@property (weak, nonatomic) IBOutlet UIButton *ocsaoxPrivacyProtocolBtn;

@property (weak, nonatomic) IBOutlet UIButton *ocsaoxCustomerBtn;

@end

@implementation LaRegisterVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.subviews[0].alpha = 0.0;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.subviews[0].alpha = 1.0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    
    _ocsaoxArea_name = @"+84";
    _area_view_width = 55.0;
    _ocsaoxAreaViewWidth.constant = _area_view_width;
    
    _scrollView.delegate = self;
    [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)]];

    _ocsaoxAccountTF.delegate = self;
    _ocsaoxCodeTF.delegate = self;
    [_ocsaoxAccountTF addTarget:self action:@selector(registerTextField:) forControlEvents:UIControlEventEditingChanged];
    [_ocsaoxCodeTF addTarget:self action:@selector(registerTextField:) forControlEvents:UIControlEventEditingChanged];
    
    [self preferredStatusBarStyle];
    
    _ocsaoxRegisterButton.userInteractionEnabled = NO;
    
    _ocsaoxRegisterTypeAButton.titleLabel.font = PINGFANG_M(20);
    [self ocsaoxType];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    [_ocsaoxRegisterTypeAButton setTitle:LLLLLL(@"Tel") forState:UIControlStateNormal];
    [_ocsaoxRegisterTypeBButton setTitle:LLLLLL(@"E-mail") forState:UIControlStateNormal];
    
    _ocsaoxCodeTF.placeholder = (_isChinese ? @"请输入验证码" : LLLLLL(@"VerificationCode"));
    _ocsaoxAccountLabel.text = LLLLLL(@"MobileNumber");
    _ocsaoxCodeLabel.text = LLLLLL(@"Code");
    
    [_ocsaoxSendcodeButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
    [_ocsaoxRegisterButton setTitle:LLLLLL(@"SignUp") forState:UIControlStateNormal];
    
    _ocsaoxHaveAmountL.text = _isChinese ? @"已有账户？" : @"Đã có tài khoản?";
    _ocsaoxGoLoginL.text = _isChinese ? @"去登录" : @"Đăng nhập";
    
    [_ocsaoxProtocolButton setTitle:(_isChinese ? @"我已阅读并同意": @"Tôi đã đọc và đồng ý với ") forState:UIControlStateNormal];
    _andL.text = (_isChinese ? @"和" : @"và");
    [_ocsaoxUserProtocolBtn setTitle:UNString(@"《%@》", LLLLLL(@"UserAgreement")) forState:UIControlStateNormal];
    [_ocsaoxPrivacyProtocolBtn setTitle:UNString(@"《%@》", LLLLLL(@"PrivacyPolicy")) forState:UIControlStateNormal];
    
    [_ocsaoxCustomerBtn setTitle:LLLLLL(@"CustomerService") forState:UIControlStateNormal];
}

- (IBAction)registerAccount:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self isValid]) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = _isChinese ? @"注册中..." : @"Đăng ký …";
    [hud showAnimated:YES];
    
    ConnectionStatus status = [WFCCNetworkService.sharedInstance currentConnectionStatus];
    if (status >= 0) { // 说明进了客服的界面、证明该im已被连接、需要断开连接才能再次进行连接 3秒
        [WFCCNetworkService.sharedInstance disconnect:YES clearSession:NO];
        WS(weakself) // 链接客服后、立马进行账号登录、未到3秒、也不会奔溃  奇怪、、、
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself registerAcc:hud];
        });
    }else {
        [self registerAcc:hud];
    }
}
- (void)registerAcc:(MBProgressHUD *)hud {
    NSString *url = @"";
    NSMutableDictionary *params = NSMutableDictionary.new;
    params[@"clientId"] = WFCCNetworkService.sharedInstance.getClientId;
    params[@"platform"] = @(Platform_iOS);
    
    params[@"deviceUId"] = [KeyChainTool readData:kUUIDStringValue];
    params[@"deviceType"] = UIDevice.currentDevice.name;
    
    if (_eogcsaioxType == 0) { // 手机号码注册
        url = @"/register";
        params[@"area"] = _ocsaoxArea_name;
        params[@"mobile"] = _ocsaoxAccountTF.text;
    }else {
        url = @"/register_email";
        params[@"email"] = _ocsaoxAccountTF.text;
    }
    params[@"code"] = _ocsaoxCodeTF.text;
    
    WS(weakself)
    [AppService.sharedAppService requestUrl:url params:params success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        [SVProgressHUD showSuccessWithStatus:(self->_isChinese ? @"注册成功..." : @"Đăng ký thành công...")];
        [SVProgressHUD dismissWithDelay:1.0];
        
        [weakself registerAccountSuccess:dict];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        NSString *text = message;
//        if (self->_isChinese) {
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

- (void)registerAccountSuccess:(NSDictionary *)dict {
    NSString *userId = dict[@"result"][@"userId"];
    NSString *token = dict[@"result"][@"token"];
    NSString *hasPassword = dict[@"result"][@"hasPassword"];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"savedToken"];
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"savedUserId"];
    [[NSUserDefaults standardUserDefaults] setInteger:hasPassword.integerValue forKey:@"kHasPassword"];
    [[NSUserDefaults standardUserDefaults] setInteger:_eogcsaioxType forKey:kLOGIN_TYPE]; // 登录方式 0 手机号码    1 邮箱
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [WFCCIMService.sharedWFCIMService getUserInfo:userId refresh:YES];
    
    //需要注意token跟clientId是强依赖的，一定要调用getClientId获取到clientId，然后用这个clientId获取token，这样connect才能成功，如果随便使用一个clientId获取到的token将无法链接成功。
    [[WFCCNetworkService sharedInstance] connect:userId token:token];
    
    [self setAvatar];

    
//    LaTabBarVC *tabBarVC = LaTabBarVC.new;
//    [UIApplication sharedApplication].delegate.window.rootViewController =  tabBarVC;
}

- (void)setAvatar {
    [self.navigationController pushViewController:[RegisterSetAvatarVC new] animated:YES];
}


/**
 code = 0; -> 注册成功返回的字段
 message = success;
 result =     {
     deviceLockStatus = 0;
     hasEmail = 0;
     hasMobile = 1;
     hasPassword = 0;
     portrait = "";
     register = 0;
     resetCode = 437730;
     token = "KHJ/C+oSM2MIkYkRzlcbDvf2a1jIM76yFypzR5YbH6094R3lkTMTMBxhELMRzer9yUWCJmo/2WtOreU/mnhKyi/gnXIAbEVpza7XujS39arPja3xM0crTDRt53S/rNxzyDzhBsyAJNY3XZztJU1XAF5V1dFFID3H7tJcxdezVRA=";
     userId = 7lgqmws2k;
     userName = 6KUDZDF7;
 };
 
 code = 0; -> 登录返回的数据
 message = success;
 result =     {
     deviceLockStatus = 0;
     hasEmail = 0;
     hasMobile = 1;
     hasPassword = 0;
     portrait = "";
     register = 0;
     resetCode = 173321;
     token = "mVnd76afDwmVRNA6lDyaSFRtjQLvNKOOQthAaENzIHvQpGgacEpesPbhD/tIBcvR6Ef2B4eVEg5rFmluATrDQEbOmlOkDdCv1C034KbsXCUiLwLyj4CQ26SwI574oq+sWBCJTsZOkCDiHZJsphNkm09fLxdVn45SnaEUFMWPVCw=";
     userId = 7lgqmws2k;
     userName = 6KUDZDF7;
 };
 */


// 发送验证码
- (IBAction)eogcsaioxSendCode:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_ocsaoxAccountTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxAccountTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return ;
    }
    sender.userInteractionEnabled = NO;
    if (_eogcsaioxType == 0) { // 手机号码获取验证码
        [AppService.sharedAppService requestUrlNoLogin:@"/send_register_code" params:@{@"area":_ocsaoxArea_name, @"mobile":_ocsaoxAccountTF.text} success:^(NSDictionary * _Nonnull dict) {
            sender.userInteractionEnabled = NO;
            [self.view makeToast:LLLLLL(@"SentSuccessfully") duration:1.0 position:CSToastPositionCenter];
            
            [CommonHelper.main handleTimer:sender];
        } error:^(int errCode, NSString * _Nonnull message) {
            sender.userInteractionEnabled = YES;
            [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
        }];
    }else {
        [AppService.sharedAppService requestUrlNoLogin:@"/send_register_email_code" params:@{@"email":_ocsaoxAccountTF.text} success:^(NSDictionary * _Nonnull dict) {
            sender.userInteractionEnabled = NO;
            [self.view makeToast:LLLLLL(@"SentSuccessfully") duration:1.0 position:CSToastPositionCenter];
            
            [CommonHelper.main handleTimer:sender];
        } error:^(int errCode, NSString * _Nonnull message) {
            sender.userInteractionEnabled = YES;
            [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
        }];
    }
    _ocsaoxCodeTF.text = @"";
}

- (IBAction)loginType:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_eogcsaioxType == sender.tag) {
        return;
    }
    _eogcsaioxType = sender.tag;
    [self ocsaoxType];
}
- (void)ocsaoxType {
    if (_eogcsaioxType == 0) {
        _boxBgView.image = IMAGENAME(@"LoginType0");
        _ocsaoxAccountLabel.text = LLLLLL(@"MobileNumber");
        _ocsaoxAccountTF.placeholder = LLLLLL(@"MobileNumbers");
        _ocsaoxAccountTF.keyboardType = UIKeyboardTypeNumberPad;
        _ocsaoxAreaView.hidden = NO;
        _ocsaoxAreaLabel.text = _ocsaoxArea_name;
        _ocsaoxAreaViewWidth.constant = _area_view_width;
        _ocsaoxAccountImgView.image = IMAGENAME(@"phoneIcon");
        _ocsaoxRegisterTypeAButton.titleLabel.font = PINGFANG_M(20);
        _ocsaoxRegisterTypeBButton.titleLabel.font = PINGFANG_R(15);
    }else {
        _boxBgView.image = IMAGENAME(@"LoginType1");
        _ocsaoxAccountLabel.text = LLLLLL(@"Email");
        _ocsaoxAccountTF.placeholder = LLLLLL(@"Email");
        _ocsaoxAccountTF.keyboardType = UIKeyboardTypeEmailAddress;
        _ocsaoxAreaView.hidden = YES;
        _ocsaoxAreaLabel.text = @"";
        _ocsaoxAreaViewWidth.constant = 0.0;
        _ocsaoxAccountImgView.image = IMAGENAME(@"eogcsaioxEmail");
        _ocsaoxRegisterTypeAButton.titleLabel.font = PINGFANG_R(15);
        _ocsaoxRegisterTypeBButton.titleLabel.font = PINGFANG_M(20);
    }
    _ocsaoxRegisterTypeAButton.selected = (_eogcsaioxType == 0);
    _ocsaoxRegisterTypeBButton.selected = (_eogcsaioxType == 1);
    _ocsaoxAccountTF.text = @"";
    _ocsaoxCodeTF.text = @"";
    [_ocsaoxSendcodeButton setTitle:LLLLLL(@"ObtainCode") forState:UIControlStateNormal];
    [_ocsaoxSendcodeButton setTitleColor:MAINCOLOR forState:UIControlStateNormal];
}

// 手机号码的区号
- (IBAction)phoneArea:(UIButton *)sender {
    [self.view endEditing:YES];
    LaAreacodeVC *vc = LaAreacodeVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    vc.deleagete = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)returnCountryName:(NSString *)countryName code:(NSString *)code {
    _ocsaoxAccountTF.text = @"";
    _ocsaoxArea_name = UNString(@"+%@", code);
    _ocsaoxAreaLabel.text = _ocsaoxArea_name;
    
    CGSize size = [QWERUtilities getTextDrawingSize:_ocsaoxArea_name font:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:15.0] constrainedSize:CGSizeMake(WIDTH, 8000)];
    _area_view_width = size.width + 27.0;
    _ocsaoxAreaViewWidth.constant = _area_view_width;
}


- (IBAction)login:(UIButton *)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)eogcsaioxProtocol:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.selected = !sender.selected;
}
//0  LAVA官网    1 使用帮助  2 用户服务协议  3 隐私协议  4 法律申明
- (IBAction)protocolDetails:(UIButton *)sender {
    [self.view endEditing:YES];
//    LaProtocolVC *vc = LaProtocolVC.new;
//    vc.eogcsaioxType = sender.tag;
//    [self.navigationController pushViewController:vc animated:YES];
    LaWebviewVC *vc = LaWebviewVC.new;
    vc.type = sender.tag + 2;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)isValid {
    if (_ocsaoxAccountTF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxAccountTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return YES;
    }
    if (_eogcsaioxType == 0) {
//        if (![_ocsaoxAccountTF.text checkPhoneNum]) {
//            [SVProgressHUD showErrorWithStatus:@"手机号码格式有误"];
//            [SVProgressHUD dismissWithDelay:1.0];
//            return YES;
//        }
        if (_ocsaoxAccountTF.text.length < 6) {
            [SVProgressHUD showErrorWithStatus:(_isChinese ? @"手机号码格式有误" : @"Định dạng số điện thoại không chính xác")];
            [SVProgressHUD dismissWithDelay:1.0];
            return YES;
        }
    }
    if (_ocsaoxCodeTF.text.length < 4) {
        [SVProgressHUD showErrorWithStatus:_ocsaoxCodeTF.placeholder];
        [SVProgressHUD dismissWithDelay:1.0];
        return YES;
    }
    if (!_ocsaoxProtocolButton.selected) {
        [SVProgressHUD showErrorWithStatus:(_isChinese ? @"请您阅读协议" : @"Vui lòng chọn tôi đồng ý")];
        [SVProgressHUD dismissWithDelay:1.0];
        return YES;
    }
    return NO;
}


- (void)registerTextField:(UITextField *)textField {
    BOOL account = (_eogcsaioxType == 0 ? ([_ocsaoxArea_name isEqualToString:@"+86"] ? _ocsaoxAccountTF.text.length >= 11 : _ocsaoxAccountTF.text.length >= 6) : _ocsaoxAccountTF.text.length >= 6);
    if (account && (_ocsaoxCodeTF.text.length >= 4)) {
        if (_ocsaoxRegisterButton.userInteractionEnabled) {
            return;
        }
        _ocsaoxRegisterButton.userInteractionEnabled = YES;
        [_ocsaoxRegisterButton setBackgroundImage:IMAGENAME(@"eogcsaioxBtnS")  forState:UIControlStateNormal];
        [_ocsaoxRegisterButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }else {
        if (!_ocsaoxRegisterButton.userInteractionEnabled) {
            return;
        }
        _ocsaoxRegisterButton.userInteractionEnabled = NO;
        [_ocsaoxRegisterButton setBackgroundImage:IMAGENAME(@"eogcsaioxBtnN")  forState:UIControlStateNormal];
        [_ocsaoxRegisterButton setTitleColor:MAINCOLOR forState:UIControlStateNormal];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger length = textField.text.length - range.length + string.length;
    if (_ocsaoxAccountTF == textField) {
        if (_eogcsaioxType == 0) {
            if ([_ocsaoxArea_name isEqualToString:@"+86"]) {
                return (length <= 11);
            }
            return (length <= 15);
        }else {
            return (length <= 50);
        }
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:true];
}
- (void)close {
    [self.view endEditing:true];
}


// 客服
- (IBAction)customerService:(UIButton *)sender {
    ConnectionStatus status = [WFCCNetworkService.sharedInstance currentConnectionStatus];
    if (status >= 0) { // 已连接
        [self enterMessageVC];
        return;
    }
    
    NSString *userId = [KeyChainTool readData:@"kCustomerService_UserId"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    NSMutableDictionary *params = NSMutableDictionary.new;
    params[@"clientId"] = WFCCNetworkService.sharedInstance.getClientId;
    params[@"platform"] = @(Platform_iOS);
    
    if (userId.length > 0) {
        params[@"userId"] = userId;
    }
    params[@"deviceUId"] = [KeyChainTool readData:kUUIDStringValue];
    params[@"deviceType"] = UIDevice.currentDevice.name;
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/register_temp" params:params success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        NSDictionary *resultDic = dict[@"result"];
        NSString *userId = resultDic[@"userId"];
        NSString *token = resultDic[@"token"];
        if (userId.length > 0 && token.length > 0) {
            [KeyChainTool saveData:userId withIdentifier:@"kCustomerService_UserId"];
            
            [WFCCNetworkService.sharedInstance connect:userId token:token];
            [weakself enterMessageVC];
        }
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
    }];
}

- (void)enterMessageVC {
    LaMessageVC *mvc = LaMessageVC.new;
    mvc.hidesBottomBarWhenPushed = YES;
    mvc.conversation = [WFCCConversation conversationWithType:Single_Type target:@"customer_service" line:0];
    [self.navigationController pushViewController:mvc animated:YES];
}




- (void)dealloc {
    NSLog(@"%@ --- dealloc",NSStringFromClass(self.class));
}

@end
