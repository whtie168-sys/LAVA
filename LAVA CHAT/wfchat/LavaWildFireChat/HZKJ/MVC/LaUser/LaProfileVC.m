//
//  LaProfileVC.m
//  WildFireChat
//
//  Created by Rubyuer on 7/22/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaProfileVC.h"
#import <MessageUI/MessageUI.h>
#import "LaNormalVC.h"
#import "LaSafetyVC.h"
#import "LaUserinfoVC.h"
#import "LaPrivacyVC.h"
#import "LaNoticeVC.h"
#import "LaFontsizeVC.h"
#import "LaLangugeVC.h"
#import "LaAboutVC.h"
#import "LaNormalQrcodeVC.h"
#import "LaTextModifyVC.h"
#import "LaUserQrcodeVC.h"
#import "LaAvatarVC.h"
#import "LaAppearanceVC.h"
#import "LaUserWalletVC.h"
#import "WOPMKDIOFZTCheckInVC.h"


@interface LaProfileVC ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoIconV;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoNameL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoIdL;
@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoSignL;

@property (weak, nonatomic) IBOutlet UIView *ceoxsoMbV;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoNotiL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoChatL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoPrivacyL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoSecurityL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoLanguageL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoSkinL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoFontL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoAboutL;

@property (strong, nonatomic) WFCCUserInfo *userInfo;
@property IBOutlet UILabel *mywalletL;
@property (nonatomic, strong) UIButton *checkInButton;

@end

@implementation LaProfileVC

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
    _isChinese = [CommonHelper.main isChinese];
    _ceoxsoIconV.layer.cornerRadius = 30.0;
    _qrView.layer.cornerRadius = 4.0;
    _ceoxsoMbV.layer.cornerRadius = 30.0;
    [self setupCheckInEntry];
    
    self.userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userdataUpdated) name:@"kUserDataUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userdataUpdated) name:kUserInfoUpdated object:nil];
    
    [self updateADFLanguage];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateADFLanguage) name:kLanguageNoti object:nil];
}

- (void)updateADFLanguage {
    _ceoxsoNotiL.text = LLLLLL(@"NotificationSetting");
    _ceoxsoChatL.text = LLLLLL(@"ChatSetting");
    _ceoxsoPrivacyL.text = LLLLLL(@"PrivacySetting");
    _ceoxsoSecurityL.text = LLLLLL(@"SecuritySetting");
    _ceoxsoLanguageL.text = LLLLLL(@"Language");
    _ceoxsoSkinL.text = LLLLLL(@"Appearance");
    _ceoxsoFontL.text = LLLLLL(@"FontSize");
    _ceoxsoAboutL.text = LLLLLL(@"About");
    _mywalletL.text = LLLLLL(@"MyWallet");
    [_checkInButton setTitle:LLLLLL(@"MyCheckIn") forState:UIControlStateNormal];
    
    for (NSInteger i = 0; i < self.tabBarController.viewControllers.count; i ++) {
        NSString *title = @[LLLLLL(@"Message"), LLLLLL(@"Contacts"), LLLLLL(@"Community"), LLLLLL(@"AI"), LLLLLL(@"Mine"), @"", @"", @""][i];
        UINavigationController *navc = self.tabBarController.viewControllers[i];
        navc.title = title;
    }
}

- (void)userdataUpdated {
    self.userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:YES];
}

- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    [_ceoxsoIconV sd_setImageWithURL:URL(userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    _ceoxsoNameL.text = userInfo.displayName;
    _ceoxsoIdL.text = userInfo.name;
    
    NSString *ceoxsoSign = [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra].sign;
    _ceoxsoSignL.text = (ceoxsoSign.length > 0 ? ceoxsoSign : (_isChinese ? @"这个用户很懒，暂无签名~" : @"Chưa cập nhật trạng thái. "));
}

- (void)setupCheckInEntry {
    UIView *containerView = self.mywalletL.superview;
    if (!containerView) {
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"me_wallet_bg"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"me_checkIn_rili"] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 8);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [button addTarget:self action:@selector(checkInA:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button];
    self.checkInButton = button;
    
    [NSLayoutConstraint activateConstraints:@[
        [button.leadingAnchor constraintEqualToAnchor:self.mywalletL.trailingAnchor constant:34],
        [button.centerYAnchor constraintEqualToAnchor:self.mywalletL.centerYAnchor],
        [button.heightAnchor constraintEqualToConstant:22],
        [button.widthAnchor constraintEqualToConstant:110]
    ]];
}

- (IBAction)ceoxsoUserinfo:(UIButton *)sender {
    LaUserinfoVC *vc = LaUserinfoVC.new;
//    LaAvatarVC *vc = LaAvatarVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)ceoxsoCopyId:(UIButton *)sender {
    if (_ceoxsoIdL.text.length <= 0) {
        return;
    }
    UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;
    pasteboard.string = _ceoxsoIdL.text;
    
    [SVProgressHUD showSuccessWithStatus:LLLLLL(@"CopySuccessfully")];
    [SVProgressHUD dismissWithDelay:1.0];
}

- (IBAction)ceoxsoQr:(UIButton *)sender {
    LaUserQrcodeVC *vc = LaUserQrcodeVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)ceoxsoSign:(UIButton *)sender {
    LaTextModifyVC *vc = LaTextModifyVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    vc.modifyType = Modify_Sign;
    vc.defaultValue = _ceoxsoSignL.text;
    WS(weakself)
    [vc setOnModified:^(NSString * _Nonnull value) {
        weakself.ceoxsoSignL.text = value;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)ceoxsoItemAct:(UIButton *)sender {
    if (sender.tag == 0) { // 通知设置
        LaNoticeVC *vc = LaNoticeVC.new;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 1) { // 聊天设置
        
    }else if (sender.tag == 2) { // 隐私设置
        LaPrivacyVC *vc = LaPrivacyVC.new;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 3) { // 安全设置
        LaSafetyVC *vc = LaSafetyVC.new;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 4) { // 语言
        LaLangugeVC *vc = LaLangugeVC.new;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 5) { // 外观
        LaAppearanceVC *vc = LaAppearanceVC.new;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 6) { // 字体
        LaFontsizeVC *vc = LaFontsizeVC.new;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 7) { // 关于
        LaAboutVC *vc = LaAboutVC.new;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    LaNormalVC *vc = LaNormalVC.new; / 通用
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)walletA:(UIButton *)sender {
    LaUserWalletVC *vc = LaUserWalletVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)checkInA:(UIButton *)sender {
    WOPMKDIOFZTCheckInVC *vc = WOPMKDIOFZTCheckInVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
