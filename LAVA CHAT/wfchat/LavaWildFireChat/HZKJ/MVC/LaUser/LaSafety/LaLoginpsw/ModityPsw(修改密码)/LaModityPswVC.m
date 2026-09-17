//
//  LaModityPswVC.m
//  WildFireChat
//
//  Created by Ruby on 1/23/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaModityPswVC.h"

#import "LaMobileEmailVerifyVC.h"
#import "LaLoginpswVerifyVC.h"

@interface LaModityPswVC ()

@property (weak, nonatomic) IBOutlet UIView *aBgView;
@property (weak, nonatomic) IBOutlet UIView *bBgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bViewTop;


@property (weak, nonatomic) IBOutlet UILabel *phoneVerificationL;
@property (weak, nonatomic) IBOutlet UILabel *emailVerificationL;
@property (weak, nonatomic) IBOutlet UILabel *loginPswVerificationL;

@end

@implementation LaModityPswVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WFCCUserInfo *userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    if (userInfo.mobile.length > 0 && userInfo.email.length > 0) {
        // 如果该账号手机号和邮箱都存在 -> 三种修改方式
    }else {
        if (userInfo.mobile.length > 0) {
            _bBgView.hidden = YES;
        }else {
            _aBgView.hidden = YES;
        }
        _bViewTop.constant = 0.0;
    }
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"ModityLoginPassword");
    
    _phoneVerificationL.text = LLLLLL(@"MobileNumberVerification");
    _emailVerificationL.text = LLLLLL(@"EmailVerification");
    _loginPswVerificationL.text = LLLLLL(@"LoginPasswordVerification");
}

- (IBAction)modify_type:(UIButton *)sender {
    if (sender.tag <= 1) {
        LaMobileEmailVerifyVC *vc = LaMobileEmailVerifyVC.new;
        vc.isMobile = (sender.tag == 0 ? YES : NO);
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        LaLoginpswVerifyVC *vc = LaLoginpswVerifyVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
