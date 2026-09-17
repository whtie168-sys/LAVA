//
//  LaMemberInfoVC.m
//  LAVA
//
//  Created by Rubyuer on 10/18/23.
//

#import "LaMemberInfoVC.h"
#if WFCU_SUPPORT_VOIP
#import <Chat86AVEngineKit/Chat86AVEngineKit.h>
#endif
#import "LaMessageVC.h"

#import "LaContactVC.h"
#import "LaTextModifyVC.h"
#import "LaCommonGroupVC.h"
#import "LaShareCardVC.h"


@interface LaMemberInfoVC ()
{
    NSArray *_groupIds;
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIScrollView *oxaicsgoeScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *oxaicsgoeIconView;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeasoucNameLabel;

@property (weak, nonatomic) IBOutlet UIView *oxaicsgoeIDView;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeSignLabel;

@property (weak, nonatomic) IBOutlet UIView *muteView;
@property (weak, nonatomic) IBOutlet UISwitch *muteSW;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sexTop;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeSexLabel;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoePhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeRemarkLabel;

@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeNumLabel;

@property (weak, nonatomic) IBOutlet UISwitch *oxaicsgoeDisturbSW;

@property (weak, nonatomic) IBOutlet UIButton *oxaicsgoeStarButton;
@property (weak, nonatomic) IBOutlet UIButton *oxaicsgoeMsgButton;


@property (nonatomic, strong) WFCCUserInfo *userInfo;
@property (nonatomic, strong) WFCCConversation *conversation;
@property (nonatomic, strong) WFCCConversationInfo *conversationInfo;
@property (nonatomic, strong) UserExtraInfo *extraInfo;

@property (nonatomic, strong)NSMutableArray<WFCCGroupMember *> *memberList;
@property (nonatomic, strong) WFCCGroupInfo *groupInfo;


@property (weak, nonatomic) IBOutlet UILabel *muteL;
@property (weak, nonatomic) IBOutlet UILabel *sexL;
@property (weak, nonatomic) IBOutlet UILabel *phoneL;
@property (weak, nonatomic) IBOutlet UILabel *remarkL;
@property (weak, nonatomic) IBOutlet UILabel *commonGroupL;
@property (weak, nonatomic) IBOutlet UILabel *shareL;
@property (weak, nonatomic) IBOutlet UILabel *disturbL;

@property (weak, nonatomic) IBOutlet UILabel *voiceL;
@property (weak, nonatomic) IBOutlet UILabel *videoL;
@property (weak, nonatomic) IBOutlet UILabel *starL;


@end

@implementation LaMemberInfoVC

- (void)onGroupMemberUpdated:(NSNotification *)notification {
    if ([self.conversation.target isEqualToString:notification.object]) {
        _memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:_groupId forceUpdate:NO].mutableCopy;
    }
}
- (void)onGroupInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCGroupInfo *> *groupInfoList = notification.userInfo[@"groupInfoList"];
    for (WFCCGroupInfo *groupInfo in groupInfoList) {
        if ([self.conversation.target isEqualToString:groupInfo.target]) {
            _groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:_groupId refresh:NO];
            break;
        }
    }
}
//- (void)onGroupMemberUpdated:(NSNotification *)notification {
//    if ([self.groupId isEqualToString:notification.object]) {
//        _memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:_groupId forceUpdate:NO].mutableCopy;
//    }
//}
//- (void)onGroupInfoUpdated:(NSNotification *)notification {
//    NSArray<WFCCGroupInfo *> *groupInfoList = notification.userInfo[@"groupInfoList"];
//    for (WFCCGroupInfo *groupInfo in groupInfoList) {
//        if ([self.groupId isEqualToString:groupInfo.target]) {
//            _groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:_groupId refresh:NO];
//        }
//    }
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self itemImage:@"xaicosgoeMore" action:@selector(oxaicsgoeMore)]];
    
    _isChinese = [CommonHelper.main isChinese];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState) name:kUserOnlineStateUpdated object:nil];
    
    _groupIds = NSArray.new;
    if (_groupId.length > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupMemberUpdated:) name:kGroupMemberUpdated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
        _memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:_groupId forceUpdate:YES].mutableCopy;
        _groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:_groupId refresh:YES];
    }
    
    ViewRadius(_oxaicsgoeIconView, 38.0);
    ViewRadius(_oxaicsgoeIDView, 15.0)
    ViewRadius(_oxaicsgoeMsgButton, 20.0);
    
    self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:_userId inGroup:_groupId refresh:YES];
//    NSLog(@"userInfo===%@",_userInfo.mj_JSONObject);
    [self loadData];
    [self muteStatus];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateOnlineState];
    });
    
    if (_isChinese) {
        
    }else {
        _phoneL.text = @"Số điện thoại";
        _remarkL.text = @"Tên ghi chú";
        _commonGroupL.text = @"Cùng nhóm";
        _shareL.text = @"Chia sẻ liên hệ";
        _disturbL.text = @"Không làm phiền";
        
        _voiceL.text = @"Gọi thoại";
        _videoL.text = @"Gọi video";
        _starL.text = @"Gắn sao";
        
        [_oxaicsgoeMsgButton setTitle:@"Gửi tin nhắn" forState:UIControlStateNormal];
        _oxaicsgoeMsgButton.titleLabel.numberOfLines = 2;
    }
    _muteL.text = LLLLLL(@"Mute");
    _sexL.text = LLLLLL(@"Gender");
}
- (void)updateOnlineState {
    if ([WFCCIMService.sharedWFCIMService isEnableUserOnlineState]) { // 是否开启了在线状态
        
        UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra];
        if (extraInfo.disableShowLastLoginTime == 0) { // 0 所有人    1 仅通讯录联系人    2 不显示在线时间
            [self onlineState];
        }else if (extraInfo.disableShowLastLoginTime == 1) {
            if ([CommonHelper.main isAddressBookContact:_userInfo.mobile]) {
                [self onlineState];
            }else {
                
            }
        }else {
            
        }
        
    }
}
- (void)onlineState {
    WFCCUserOnlineState *state = [[WFCCIMService sharedWFCIMService] getUserOnlineState:self.userId];
    BOOL online = NO;
    BOOL hasMobileSession = NO;
    long long mobileLastSeen = 0;
    if(state.clientStates.count) { //有设备在线
        if(state.customState.state != 4) { //没有设置为隐身
            for (WFCCClientState *cs in state.clientStates) {
                if(cs.state == 0) { // 设备的在线状态，0是在线，1是有session但不在线，其它不在线。
                    online = YES;
                    break;
                }
                if (cs.state == 1 && (cs.platform == 1 || cs.platform == 2)) {
                    hasMobileSession = YES;
                    if(mobileLastSeen < cs.lastSeen) {
                        mobileLastSeen = cs.lastSeen;
                    }
                }
            }
        }
    }
    if (!online) {
        if (hasMobileSession && mobileLastSeen > 0) {
            NSString *strSeenTime = [CommonHelper.main onlineStatusDesc:mobileLastSeen];
            if (strSeenTime.length) {
                self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",strSeenTime, LLLLLL(@"Online")];
            }else {
                self.navigationItem.title = LLLLLL(@"JustOffTheLine");
            }
        }
    }else {
        self.navigationItem.title = LLLLLL(@"Online");
    }
}

- (void)loadData {
    self.conversation = [WFCCConversation conversationWithType:Single_Type target:_userId line:0];
    self.conversationInfo = [WFCCIMService.sharedWFCIMService getConversationInfo:_conversation];
    
    self.extraInfo = [UserExtraInfo mj_objectWithKeyValues:self.userInfo.extra];
    
    [_oxaicsgoeIconView sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    if (_userInfo.friendAlias.length) {
        _oxaicsgoeasoucNameLabel.text = _userInfo.friendAlias;
    }else if (_userInfo.groupAlias.length) {
        _oxaicsgoeasoucNameLabel.text = _userInfo.groupAlias;
    }else if (_userInfo.displayName.length) {
        _oxaicsgoeasoucNameLabel.text = _userInfo.displayName;
    }else {
        _oxaicsgoeasoucNameLabel.text = @"";
    }
    
    _oxaicsgoeIdLabel.text = _userInfo.name;
    _oxaicsgoeSexLabel.text = (_userInfo.gender == 2 ? LLLLLL(@"Male") : (_userInfo.gender == 1 ? LLLLLL(@"Female") : LLLLLL(@"Other")));
    _oxaicsgoeRemarkLabel.text = _userInfo.friendAlias;
    
    _oxaicsgoeDisturbSW.on = _conversationInfo.isSilent;
    
    
    _oxaicsgoeSignLabel.text = _extraInfo.sign.length ? _extraInfo.sign : (_isChinese?@"对方什么都没有写":@"Đối phương không viêt gì");
    _oxaicsgoePhoneLabel.text = (_extraInfo.disableShowPhone == 1 ? _userInfo.mobile : (_isChinese?@"联系人不展示电话":@"Không công khai"));
    
    
    WS(weakself)
    [WFCCIMService.sharedWFCIMService getCommonGroups:self.userId success:^(NSArray<NSString *> *groupIds) {
        self->_groupIds = groupIds;
        weakself.oxaicsgoeNumLabel.text = [NSString stringWithFormat:@"%ld%@",groupIds.count, (self->_isChinese?@"个":@"")];
    } error:^(int error_code) {
    }];
    
    _oxaicsgoeStarButton.selected = [WFCCIMService.sharedWFCIMService isFavUser:self.userId];
}

- (void)oxaicsgoeMore {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WS(weakself)
    UIAlertAction *blackListAction = [UIAlertAction actionWithTitle:LLLLLL(@"JoinTheBlacklist") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:(self->_isChinese?@"加入黑名单后，你将不再接收到对方的任何消息":@"Sau khi thêm vào danh sách đen, bạn sẽ không thể nhận được bất kỳ tin nhắn nào từ người này") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        WS(weakself)
        UIAlertAction *okAct = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakself addBlackList];
        }];
        [actionSheet addAction:cancelAct];
        [actionSheet addAction:okAct];
        [self presentViewController:actionSheet animated:YES completion:nil];
        
    }];
    UIAlertAction *deleteFriendAction = [UIAlertAction actionWithTitle:(_isChinese?@"删除联系人":@"Xóa người liên hệ") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
        hud.label.text = LLLLLL(@"Loading");
        [hud showAnimated:YES];
        
        [[WFCCIMService sharedWFCIMService] deleteFriend:weakself.userId success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];

                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = LLLLLL(@"SuccessfulOperation");
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
                
                [weakself.navigationController popViewControllerAnimated:YES];
            });
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];

                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = LLLLLL(@"LoadFailure");
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            });
        }];
    }];
    [actionSheet addAction:blackListAction];
    [actionSheet addAction:deleteFriendAction];
    [actionSheet addAction:actionCancel];
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (void)addBlackList {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    [[WFCCIMService sharedWFCIMService] setBlackList:self.userId isBlackListed:YES success:^{
        [hud hideAnimated:YES];

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = LLLLLL(@"SuccessfulOperation");
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:1.f];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(int error_code) {
        [hud hideAnimated:YES];

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = LLLLLL(@"LoadFailure");
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:1.f];
    }];
}

// 复制ID
- (IBAction)oxaicsgoeCopy:(UIButton *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _oxaicsgoeIdLabel.text;
    
    [SVProgressHUD showSuccessWithStatus:LLLLLL(@"CopySuccessfully")];
    [SVProgressHUD dismissWithDelay:1.0];
}


// 备注名
- (IBAction)oxaicsgoeRemark:(UIButton *)sender {
//    RWADCGeneralModifyVC *gmvc = [[RWADCGeneralModifyVC alloc] init];
//    NSString *previousAlias = [[WFCCIMService sharedWFCIMService] getFriendAlias:self.userId];
//    gmvc.defaultValue = previousAlias;
//    gmvc.titleText = @"设置备注";
//    gmvc.canEmpty = YES;
//    __weak typeof(self)ws = self;
//    gmvc.tryModify = ^(NSString *newValue, void (^result)(BOOL success)) {
//        if (![newValue isEqualToString:previousAlias]) {
//            [[WFCCIMService sharedWFCIMService] setFriend:self.userId alias:newValue success:^{
//                result(YES);
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [ws loadData];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCallHistory" object:nil];
//                });
//            } error:^(int error_code) {
//                result(NO);
//            }];
//        }
//    };
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gmvc];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
    LaTextModifyVC *vc = LaTextModifyVC.new;
    vc.modifyType = Modify_FriendAlias;
    vc.userId = self.userId;
    vc.defaultValue = _oxaicsgoeRemarkLabel.text;
    WS(weakself)
    [vc setOnModified:^(NSString * _Nonnull value) {
        weakself.oxaicsgoeRemarkLabel.text = value;
        if (value.length > 0) {
            weakself.oxaicsgoeasoucNameLabel.text = value;
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}


// 共同群聊
- (IBAction)oxaicsgoeGroupchat:(UIButton *)sender {
//    if (_groupIds.count <= 0) {
//        return;
//    }
    LaCommonGroupVC *groupsVC = LaCommonGroupVC.new;
    groupsVC.groupIds = _groupIds;
    [self.navigationController pushViewController:groupsVC animated:YES];
}
// 分享联系人
- (IBAction)oxaicsgoeShare:(UIButton *)sender {
//    LaContactVC *vc = LaContactVC.new;
//    vc.conversationType = Single_Type;
//    vc.type = 1;
//    vc.target = _userId;
//    vc.filterId = _userId;
//    [self.navigationController pushViewController:vc animated:YES];

    LaShareCardVC *vc = LaShareCardVC.new;
    vc.targetId = _userId;
    [self.navigationController pushViewController:vc animated:YES];
}

// 消息免打扰
- (IBAction)oxaicsgoeDisturb:(UISwitch *)sender {
    if (_conversation == nil) {
        return;
    }
    [WFCCIMService.sharedWFCIMService setConversation:_conversation silent:sender.isOn success:^{
    } error:^(int error_code) {
    }];
}


// 语音通话
- (IBAction)oxaicsgoeVoice:(UIButton *)sender {
#if WFCU_SUPPORT_VOIP
    if (_conversation == nil) {
        return;
    }
    RADCOVideoVC *videoVC = [[RADCOVideoVC alloc] initWithTargets:@[_userInfo.userId] conversation:_conversation audioOnly:YES];
    [[Chat86AVEngineKit sharedEngineKit] presentViewController:videoVC];
#endif
}

// 视频通话
- (IBAction)oxaicsgoeVideo:(UIButton *)sender {
#if WFCU_SUPPORT_VOIP
    if (_conversation == nil) {
        return;
    }
    
    RADCOVideoVC *videoVC = [[RADCOVideoVC alloc] initWithTargets:@[_userInfo.userId] conversation:_conversation audioOnly:NO];
    [[Chat86AVEngineKit sharedEngineKit] presentViewController:videoVC];
#endif
}

// 设为星标
- (IBAction)oxaicsgoeStar:(UIButton *)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    [[WFCCIMService sharedWFCIMService] setFavUser:_userId fav:!_oxaicsgoeStarButton.selected success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            sender.selected = !sender.selected;

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = LLLLLL(@"SuccessfulOperation");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    } error:^(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = LLLLLL(@"LoadFailure");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    }];
}

// 发消息
- (IBAction)oxaicsgoeMsg:(UIButton *)sender {
    LaMessageVC *mvc = LaMessageVC.new;
    mvc.hidesBottomBarWhenPushed = YES;
    mvc.conversation = _conversation;
    [self.navigationController pushViewController:mvc animated:YES];
}




#pragma mark - 禁言相关

// 禁言   isSet    设置或取消
- (IBAction)mute:(UISwitch *)sender {
    [WFCCIMService.sharedWFCIMService muteGroupMember:_groupId isSet:(sender.isOn) memberIds:@[_userId] notifyLines:@[@(0)] notifyContent:nil success:^{
        
    } error:^(int error_code) {
        if (error_code == ERROR_CODE_NOT_IMPLEMENT) {
            [self.view makeToast:LLLLLL(@"Unrealized")];
        }
    }];
}

/** 禁言 -> 禁言遵循的原则：
* 群主可以设置所有人禁言(包括管理员)、管理员可以设置普通用户禁言
 */
- (void)muteStatus {
    if (_isCardEnter) {
        [self isShowMute:NO];
        return;
    }
    if (_groupId.length <= 0) {
        [self isShowMute:NO];
        return;
    }
    BOOL isShowMute = NO;
    if ([self isGroupOwner:WFCCNetworkService.sharedInstance.userId]) { // 判断当前登录账号是否是群主
        isShowMute = YES;
    }else { // 如果不是群主  进一步判断是否是管理员
        if ([self isGroupManager:WFCCNetworkService.sharedInstance.userId]) { // 是管理员
            // 必须得判断对方是否是管理员或者群主
            if ([self isGroupOwner:_userId] || [self isGroupManager:_userId]) { // 如果对方是管理员或者群组 -> 无权设置对方禁言
                isShowMute = NO;
            }else {
                isShowMute = YES;
            }
        }else {
            isShowMute = NO;
        }
    }
    [self isShowMute:isShowMute];
    
    if (isShowMute) {
        for (WFCCGroupMember *member in _memberList) {
            if ([member.memberId isEqualToString:_userId]) {
                if (member.type == Member_Type_Muted) {
                    _muteSW.on = YES;
                }else {
                    _muteSW.on = NO;
                }
                break;
            }
        }
//        _muteSW.enabled = (_groupInfo.mute == 0);
    }else {
        _muteSW.on = NO;
    }
}

- (void)isShowMute:(BOOL)isShow {
    if (isShow) {
        _muteView.hidden = NO;
        _sexTop.constant = 66.0 + 20.0;
    }else {
        _muteView.hidden = YES;
        _sexTop.constant = 20.0;
    }
}

- (BOOL)isGroupOwner:(NSString *)userId {
    return [self.groupInfo.owner isEqualToString:userId];
}
- (BOOL)isGroupManager:(NSString *)userId {
    __block BOOL isManager = false;
    [self.memberList enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.memberId isEqualToString:userId]) {
            if (obj.type == Member_Type_Manager) {
                isManager = YES;
            }
            *stop = YES;
        }
    }];
    return isManager;
}




- (void)onUserInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    for (WFCCUserInfo *userInfo in userInfoList) {
        if ([self.userId isEqualToString:userInfo.userId]) {
            self.userInfo = userInfo;
            [self loadData];
            break;
        }
    }
}


@end
