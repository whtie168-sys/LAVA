//
//  LaSystemNotiVC.m
//  WildFireChat
//
//  Created by Rubyuer on 7/22/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaSystemNotiVC.h"

@interface LaSystemNotiVC ()

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoAllowNotiL;

@property (weak, nonatomic) IBOutlet UIView *ceoxsoQuanxianV;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoNotiQuanxL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoJiaobL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoXuanfuL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoXuanfuDescL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoAudioL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoVibrationL;

@property (weak, nonatomic) IBOutlet UISwitch *ceoxsoYXTZSw;

@property (weak, nonatomic) IBOutlet UISwitch *ceoxsoZMJBSw;
@property (weak, nonatomic) IBOutlet UISwitch *ceoxsoXFTZSw;
@property (weak, nonatomic) IBOutlet UISwitch *ceoxsoSYSw;
@property (weak, nonatomic) IBOutlet UISwitch *ceoxsoZDSw;

@end

@implementation LaSystemNotiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([CommonHelper.main isChinese]) {
        self.navigationItem.title = @"系统通知";
    }else {
        self.navigationItem.title = @"Hệ thống thông báo";
        
        _ceoxsoAllowNotiL.text = @"Cho phép thông báo";
        
        _ceoxsoNotiQuanxL.text = @"Thông báo thiết lập quyền";
        _ceoxsoJiaobL.text = @"Góc bàn";
        _ceoxsoXuanfuL.text = @"Thông báo bay";
        _ceoxsoXuanfuDescL.text = @"Cho phép bật thông báo lên trên màn hình";
        _ceoxsoAudioL.text = @"Âm thanh";
        _ceoxsoVibrationL.text = @"Rung";
    }
    
    WFCCUserInfo *userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:userInfo.extra];
    _ceoxsoSYSw.on = (extraInfo.sound == 1);
    _ceoxsoZDSw.on = (extraInfo.shake == 1);
    
    
    // 0730
    _ceoxsoYXTZSw.on = ![NSUserDefaults.standardUserDefaults boolForKey:kIsAllowNotification];
    _ceoxsoQuanxianV.hidden = !_ceoxsoYXTZSw.on;
    _ceoxsoZMJBSw.on = ![NSUserDefaults.standardUserDefaults boolForKey:kDesktopCornerMark];
    _ceoxsoXFTZSw.on = ![NSUserDefaults.standardUserDefaults boolForKey:kSuspensionNotice];
}

- (IBAction)ceoxsoYXTZ:(UISwitch *)sender {
    _ceoxsoQuanxianV.hidden = !sender.on;
    [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kIsAllowNotification];
    [NSUserDefaults.standardUserDefaults synchronize];
}


// 通知权限设置
- (IBAction)ceoxsoTZQXSetting:(UISwitch *)sender {
    if ([sender isEqual:_ceoxsoZMJBSw]) {
        [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kDesktopCornerMark];
        [NSUserDefaults.standardUserDefaults synchronize];
    }else if ([sender isEqual:_ceoxsoXFTZSw]) {
        [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kSuspensionNotice];
        [NSUserDefaults.standardUserDefaults synchronize];
    }else if ([sender isEqual:_ceoxsoSYSw]) {
        [self requestStateSW:sender params:@{@"sound":@(sender.on ? 1 : 0)}];
    }else if ([sender isEqual:_ceoxsoZDSw]) {
        [self requestStateSW:sender params:@{@"shake":@(sender.on ? 1 : 0)}];
    }
}

- (void)requestStateSW:(UISwitch *)sw params:(NSDictionary *)params {
    [AppService.sharedAppService requestUrl:@"/user/set_option" params:params success:^(NSDictionary * _Nonnull dict) {
    } error:^(int errCode, NSString * _Nonnull message) {
    }];
}


@end
