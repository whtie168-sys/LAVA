//
//  LaPrivacyVC.m
//  WildFireChat
//
//  Created by Ruby on 11/15/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaPrivacyVC.h"

#import "LaLastOnlineVC.h"
#import "LaAddmyWayVC.h"

@interface LaPrivacyVC ()
{
    BOOL _isUpdate;
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UISwitch *addChatSW;
@property (weak, nonatomic) IBOutlet UISwitch *addGroupSW;
@property (weak, nonatomic) IBOutlet UISwitch *showMobileSW;

@property (weak, nonatomic) IBOutlet UISwitch *enterStatusSW;
@property (weak, nonatomic) IBOutlet UISwitch *receiptSW;

@property (nonatomic, strong) WFCCUserInfo *userInfo;
@property (nonatomic, strong) UserExtraInfo *extraInfo;


@property (weak, nonatomic) IBOutlet UILabel *addWayL;
@property (weak, nonatomic) IBOutlet UILabel *addFriendL;
@property (weak, nonatomic) IBOutlet UILabel *inviteL;
@property (weak, nonatomic) IBOutlet UILabel *showPhoneL;

@property (weak, nonatomic) IBOutlet UILabel *lastOnlineL;
@property (weak, nonatomic) IBOutlet UILabel *showEnterStateL;
@property (weak, nonatomic) IBOutlet UILabel *readedL;
@property (weak, nonatomic) IBOutlet UILabel *readedDescL;

@property (weak, nonatomic) IBOutlet UILabel *blackListL;


@end

@implementation LaPrivacyVC


- (void)didMoveToParentViewController:(UIViewController*)parent {
    [super didMoveToParentViewController:parent];
    if (_isUpdate) {
        [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    _isUpdate = NO;
    self.userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"PrivacySetting");
    _blackListL.text = LLLLLL(@"Blacklist");
    
    if (_isChinese) {
    }else {
        _addWayL.text = @"Phương thức kết bạn với tôi";
        _addFriendL.text = @"Xác nhận khi kết bạn";
        _inviteL.text = @"Xác nhận khi mời vào nhóm";
        _showPhoneL.text = @"Hiện thị số điện thoại với bạn bè";
        
        _lastOnlineL.text = @"Lần cuối đăng nhập";
        _showEnterStateL.text = @"Hiển thị trạng thái đăng nhập";
        _readedL.text = @"Xác nhận đã đọc";
        _readedDescL.text = @"Nếu bạn chọn tắt xác nhận đã đọc, bạn cũng sẽ không thể nhìn thấy trạng thái đã đọc của người khác.  Lựa chọn này sẽ không ảnh hưởng đến xác nhận đã đọc trong nhóm";
    }
}

- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    _extraInfo = [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra];
//    NSLog(@"userInfo2===%@",_userInfo.mj_JSONObject);
    
    _addChatSW.on = (_extraInfo.disableAutoAddFriend == 1);
    _addGroupSW.on = (_extraInfo.disableJoinToGroup == 1);
    _showMobileSW.on = (_extraInfo.disableShowPhone == 1);
    
    _enterStatusSW.on = (_extraInfo.disableShowInputState == 1);
    _receiptSW.on = [WFCCIMService.sharedWFCIMService isUserEnableReceipt];
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

- (IBAction)lastOnlineDate:(UIButton *)sender {
    LaLastOnlineVC *vc = LaLastOnlineVC.new;
    vc.showLastLoginTime = _extraInfo.disableShowLastLoginTime;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addMyWay:(UIButton *)sender {
    LaAddmyWayVC *vc = LaAddmyWayVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)blacklist:(UIButton *)sender {
    RWADCBlackListVC *vc = RWADCBlackListVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)receipt:(UISwitch *)sender {
    _isUpdate = YES;
    if ([sender isEqual:_addChatSW]) {
        [self requestStateSW:sender params:@{@"disableAutoAddFriend":@(sender.on ? 1 : 0)}];
    }else if ([sender isEqual:_addGroupSW]) {
        [self requestStateSW:sender params:@{@"disableJoinToGroup":@(sender.on ? 1 : 0)}];
    }else if ([sender isEqual:_showMobileSW]) {
        [self requestStateSW:sender params:@{@"disableShowPhone":@(sender.on ? 1 : 0)}];
    }else if ([sender isEqual:_enterStatusSW]) {
        [self requestStateSW:sender params:@{@"disableShowInputState":@(sender.on ? 1 : 0)}];
    }else if ([sender isEqual:_receiptSW]) {
        _isUpdate = NO;
        [WFCCIMService.sharedWFCIMService setUserEnableReceipt:sender.on success:^{
        } error:^(int error_code) {
            sender.on = !sender.on;
        }];
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
