//
//  LaSafetyVC.m
//  WildFireChat
//
//  Created by Ruby on 11/8/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaSafetyVC.h"
#import "OrgService.h"

#import "LaDestroyVC.h"
#import "LaTextModifyVC.h"
#import "LaLoginpswVC.h"
#import "LaLockVC.h"

#import "LaModityPswVC.h"
#import "LaMobileEmailVerityVC.h"
#import "LaMobileBindingVC.h"
#import "LaEmailBindingVC.h"
#import "LaDeviceVC.h"
#import "ConversationDeleteManager.h"

@interface LaSafetyVC ()

@property (weak, nonatomic) IBOutlet UILabel *loginPswLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loginPswRedView;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *phoneRedView;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emailRedView;

@property (nonatomic, strong) WFCCUserInfo *userInfo;


@property (weak, nonatomic) IBOutlet UILabel *loginPswL;
@property (weak, nonatomic) IBOutlet UILabel *phoneL;
@property (weak, nonatomic) IBOutlet UILabel *emailL;

@property (weak, nonatomic) IBOutlet UILabel *equipmentL;
@property (weak, nonatomic) IBOutlet UILabel *safetyLockL;
@property (weak, nonatomic) IBOutlet UILabel *clearAccountL;
@property (weak, nonatomic) IBOutlet UILabel *deactivateAccountL;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoAccountSetL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoOtherSetL;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoLogoutBtn;

@end

@implementation LaSafetyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:savedUserId refresh:NO];
    
    [self setMobile];
    [self setEmail];
    [self setPassword];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userdataUpdated) name:@"kUserDataUpdated" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(modityData:) name:kMODITY_MOBILE_EMAIL_NOTI object:nil];
    
    [self updateADFLanguage];
    
    _ceoxsoLogoutBtn.layer.cornerRadius = 15.0;
}

- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"SecuritySetting");
    _loginPswL.text = LLLLLL(@"LoginPassword");
    _phoneL.text = LLLLLL(@"MobileNumbers");
    _emailL.text = LLLLLL(@"E-mail");
    _equipmentL.text = LLLLLL(@"Equipment");
    _safetyLockL.text = LLLLLL(@"SafetyLock");
    _clearAccountL.text = LLLLLL(@"ClearAccount");
    _deactivateAccountL.text = LLLLLL(@"DeactivateAccount");
    
    _ceoxsoAccountSetL.text = LLLLLL(@"AccountSetting");
    _ceoxsoOtherSetL.text = LLLLLL(@"OtherSetting");
    [_ceoxsoLogoutBtn setTitle:LLLLLL(@"Logout") forState:UIControlStateNormal];
}

- (void)userdataUpdated {
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:savedUserId refresh:YES];
    [self setMobile];
    [self setEmail];
    [self setPassword];
}
- (void)setMobile {
    if (_userInfo.mobile.length > 0) {
        _phoneRedView.hidden = YES;
        
        NSArray *phones = [_userInfo.mobile componentsSeparatedByString:@" "];
        NSString *mobile = phones.lastObject;
        NSMutableString *star = NSMutableString.new;
        for (NSInteger i = 0; i < mobile.length-7; i ++) {
            [star appendString:@"*"];
        }
        _phoneLabel.text = [NSString stringWithFormat:@"%@ %@",phones.firstObject, [mobile stringByReplacingCharactersInRange:NSMakeRange(3, mobile.length - 7) withString:UNString(@" %@ ", star)]];
    }else {
        _phoneLabel.text = LLLLLL(@"NotYetBound");
        _phoneRedView.hidden = NO;
    }
}
- (void)setEmail {
    if (_userInfo.email.length > 0) {
        _emailRedView.hidden = YES;
        NSArray *emails = [_userInfo.email componentsSeparatedByString:@"@"];
        NSString *emailFront = emails.firstObject; // 类似于->Rubyuer
        if (emailFront.length <= 4) {
            if (emailFront.length <= 2) {
                _emailLabel.text = _userInfo.email;
            }else {
                _emailLabel.text = [NSString stringWithFormat:@"%@**%@@%@",[emailFront substringToIndex:1], [emailFront substringFromIndex:(emailFront.length-1)], emails.lastObject];
            }
        }else {
            _emailLabel.text = [NSString stringWithFormat:@"%@****%@@%@",[emailFront substringToIndex:2], [emailFront substringFromIndex:(emailFront.length-2)], emails.lastObject];
        }
    }else {
        _emailLabel.text = LLLLLL(@"NotYetBound");
        _emailRedView.hidden = NO;
    }
}
- (void)setPassword {
    NSInteger hasPassword = [[NSUserDefaults standardUserDefaults] integerForKey:@"kHasPassword"];
    if (hasPassword == 1) {
        _loginPswLabel.text = LLLLLL(@"AlreadySet");
        _loginPswRedView.hidden = YES;
    }else {
        _loginPswLabel.text = LLLLLL(@"NotSet");
        _loginPswRedView.hidden = NO;
    }
}
- (void)modityData:(NSNotification *)noti {
    if ([noti.object[@"mobile"] length]) {
        _userInfo.mobile = noti.object[@"mobile"];
        [self setMobile];
    }
    if ([noti.object[@"email"] length]) {
        _userInfo.email = noti.object[@"email"];
        [self setEmail];
    }
    if ([noti.object[@"loginPsw"] integerValue] == 1) {
        [self setPassword];
    }
}

- (IBAction)loginPsw:(UIButton *)sender {
    NSInteger hasPassword = [[NSUserDefaults standardUserDefaults] integerForKey:@"kHasPassword"];
    if (hasPassword == 1) { // 已设置了密码
        LaModityPswVC *vc = LaModityPswVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }else { // 未设置密码
        LaLoginpswVC *vc = LaLoginpswVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)phone:(UIButton *)sender {
    if (_userInfo.mobile.length > 0) {
        LaMobileEmailVerityVC *vc = LaMobileEmailVerityVC.new;
        vc.type = 0;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        LaMobileBindingVC *vc = LaMobileBindingVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }
//    LaTextModifyVC *vc = LaTextModifyVC.new;
//    vc.modifyType = Modify_Mobile;
//    vc.defaultValue = (_userInfo.mobile.length > 0) ? _userInfo.mobile : @"";
//    WS(weakself)
//    [vc setOnModified:^(NSString * _Nonnull value) {
//        weakself.phoneLabel.text = value;
//    }];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)email:(UIButton *)sender {
    if (_userInfo.email.length > 0) {
        LaMobileEmailVerityVC *vc = LaMobileEmailVerityVC.new;
        vc.type = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        LaEmailBindingVC *vc = LaEmailBindingVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }
//    LaTextModifyVC *vc = LaTextModifyVC.new;
//    vc.modifyType = Modify_Email;
//    vc.defaultValue = (_userInfo.email.length > 0) ? _userInfo.email : @"";
//    WS(weakself)
//    [vc setOnModified:^(NSString * _Nonnull value) {
//        weakself.emailLabel.text = value;
//        weakself.emailRedView.hidden = YES;
//    }];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)device:(UIButton *)sender {
    LaDeviceVC *vc = LaDeviceVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)safetyLock:(UIButton *)sender {
    LaLockVC *vc = LaLockVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clearAccount:(UIButton *)sender {
    LaDestroyVC *destroyVC = LaDestroyVC.new;
    [self.navigationController pushViewController:destroyVC animated:YES];
}


- (IBAction)ceoxsoClearAccount:(UIButton *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"Record_save_time_alert_title") message:LLLLLL(@"Delete_all_message_alert_info") preferredStyle:UIAlertControllerStyleAlert];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSArray *conversations = [[[WFCCIMService sharedWFCIMService] getConversationInfos:@[@(Single_Type), @(Group_Type), @(Channel_Type), @(SecretChat_Type), @(Chatroom_Type), @(Things_Type)] lines:@[@(0)]] mutableCopy];

        for (NSInteger i = conversations.count - 1; i >= 0; i--) {
            WFCCConversationInfo *conv = conversations[i];
            [[ConversationDeleteManager shared] deleteScheduleWithTarget:conv.conversation.target];
            [[WFCCIMService sharedWFCIMService] clearUnreadStatus:conv.conversation];
            [[WFCCIMService sharedWFCIMService] removeConversation:conv.conversation clearMessage:YES];
        }
       
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)ceoxsoLogout:(UIButton *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"Quit") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *actionLogout = [UIAlertAction actionWithTitle:LLLLLL(@"Logout") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedUserId"];
        [[AppService sharedAppService] clearAppServiceAuthInfos];
        [[OrgService sharedOrgService] clearOrgServiceAuthInfos];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [CommonHelper.main loyout];
        //退出后就不需要推送了，第一个参数为YES
        //如果希望再次登录时能够保留历史记录，第二个参数为NO。如果需要清除掉本地历史记录第二个参数用YES
        [[WFCCNetworkService sharedInstance] disconnect:YES clearSession:NO];
    }];
    
    UIAlertAction *actionDestroy = [UIAlertAction actionWithTitle:LLLLLL(@"DestroyAccount") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        LaDestroyVC *destroyVC = [[LaDestroyVC alloc] init];
        [self.navigationController pushViewController:destroyVC animated:YES];
    }];
    
    //把action添加到actionSheet里
    [actionSheet addAction:actionLogout];
    [actionSheet addAction:actionDestroy];
    [actionSheet addAction:actionCancel];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
}



- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}


@end
