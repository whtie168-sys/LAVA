//
//  LaUserVC.m
//  WildFireChat
//
//  Created by Ruby on 11/7/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaUserVC.h"
#import <AVKit/AVKit.h>
#import <MessageUI/MessageUI.h>
#import "LaNormalVC.h"
#import "LaSafetyVC.h"
#import "LaUserinfoVC.h"
#import "LaPrivacyVC.h"
#import "LaNoticeVC.h"
#import "LaUserWalletVC.h"

@interface LaUserVC ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (weak, nonatomic) IBOutlet UIView *mbView;

@property (strong, nonatomic) WFCCUserInfo *userInfo;


@property (weak, nonatomic) IBOutlet UILabel *notificationL;
@property (weak, nonatomic) IBOutlet UILabel *chatL;
@property (weak, nonatomic) IBOutlet UILabel *privacyL;
@property (weak, nonatomic) IBOutlet UILabel *securityL;
@property (weak, nonatomic) IBOutlet UILabel *universalL;

@property IBOutlet UILabel *mywalletL;
@end

@implementation LaUserVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.subviews[0].alpha = 0.0;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.subviews[0].alpha = 1.0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _iconView.layer.cornerRadius = 30.0;
    _qrView.layer.cornerRadius = 4.0;
    _mbView.layer.cornerRadius = 30.0;
    
    self.userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userdataUpdated) name:@"kUserDataUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userdataUpdated) name:kUserInfoUpdated object:nil];
    [self updateADFLanguage];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateADFLanguage) name:kLanguageNoti object:nil];
}
- (void)updateADFLanguage {
    _notificationL.text = LLLLLL(@"NotificationSetting");
    _chatL.text = LLLLLL(@"ChatSetting");
    _privacyL.text = LLLLLL(@"PrivacySetting");
    _securityL.text = LLLLLL(@"SecuritySetting");
    _universalL.text = LLLLLL(@"Universal");
    _mywalletL.text = LLLLLL(@"MyWallet");

    for (NSInteger i = 0; i < self.tabBarController.viewControllers.count; i ++) {
        NSString *title = @[LLLLLL(@"Message"), LLLLLL(@"Contacts"), LLLLLL(@"Community"), LLLLLL(@"AI"), LLLLLL(@"Mine"), @"", @"", @""][i];
        UINavigationController *navc = self.tabBarController.viewControllers[i];
        navc.title = title;
    }
}

- (void)userdataUpdated {
    self.userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:YES];
//    NSLog(@"toJsonObj===%@",self.userInfo.toJsonObj);
}
- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
//    NSLog(@"toJsonObj===%@",_userInfo.toJsonObj);
    [_iconView sd_setImageWithURL:URL(userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    _asoucNameLabel.text = userInfo.displayName;
    _idLabel.text = userInfo.name;
}

- (IBAction)copyId:(UIButton *)sender {
    if (_idLabel.text.length <= 0) {
        return;
    }
    UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;
    pasteboard.string = _idLabel.text;
    
    [SVProgressHUD showSuccessWithStatus:LLLLLL(@"CopySuccessfully")];
    [SVProgressHUD dismissWithDelay:1.0];
}

- (IBAction)userinfo:(UIButton *)sender {
    LaUserinfoVC *vc = LaUserinfoVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)tongZhi_setup:(UIButton *)sender {
    LaNoticeVC *vc = LaNoticeVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)chatSetup:(UIButton *)sender {
    
}
- (IBAction)privacy_setup:(UIButton *)sender {
    LaPrivacyVC *vc = LaPrivacyVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)secure_setup:(UIButton *)sender {
    LaSafetyVC *vc = LaSafetyVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)normal_setup:(UIButton *)sender {
    LaNormalVC *vc = LaNormalVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)walletA:(UIButton *)sender {
    [self.navigationController pushViewController:[LaUserWalletVC new] animated:YES];
}

@end
