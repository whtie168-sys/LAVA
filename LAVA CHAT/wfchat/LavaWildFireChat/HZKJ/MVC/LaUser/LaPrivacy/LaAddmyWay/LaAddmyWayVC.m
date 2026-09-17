//
//  LaAddmyWayVC.m
//  WildFireChat
//
//  Created by Ruby on 1/30/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaAddmyWayVC.h"

@interface LaAddmyWayVC ()

@property (weak, nonatomic) IBOutlet UISwitch *mobileSW;

@property (weak, nonatomic) IBOutlet UISwitch *idSW;

@property (nonatomic, strong) WFCCUserInfo *userInfo;


@property (weak, nonatomic) IBOutlet UILabel *descL;
@property (weak, nonatomic) IBOutlet UILabel *phoneL;

@end

@implementation LaAddmyWayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([CommonHelper.main isChinese]) {
        self.navigationItem.title = @"添加我的方式";
    }else {
        self.navigationItem.title = @"Phương thức kết bạn với tôi";
        _descL.text = @"    Bạn có thể tìm thấy tôi bằng những cách sau đây";
    }
    _phoneL.text = LLLLLL(@"MobileNumbers");
    
    self.userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    for (WFCCUserInfo *userInfo in userInfoList) {
        if ([WFCCNetworkService.sharedInstance.userId isEqualToString:userInfo.userId]) {
            self.userInfo = userInfo;
            break;
        }
    }
}
- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra];
    
    _mobileSW.on = (extraInfo.openMobileSearch == 1);
    
    _idSW.on = (extraInfo.openAccountSearch == 1);
}

- (IBAction)actionSW:(UISwitch *)sender {
    if ([sender isEqual:_mobileSW]) {
        [self requestStateSW:sender params:@{@"openMobileSearch":@(sender.on ? 1 : 0)}];
    }else if ([sender isEqual:_idSW]) {
        [self requestStateSW:sender params:@{@"openAccountSearch":@(sender.on ? 1 : 0)}];
    }
}

- (void)requestStateSW:(UISwitch *)sw params:(NSDictionary *)params {
    [AppService.sharedAppService requestUrl:@"/user/set_option" params:params success:^(NSDictionary * _Nonnull dict) {
    } error:^(int errCode, NSString * _Nonnull message) {
//        if (sw) {
//            sw.on = !sw.on;
//        }
    }];
}

@end
