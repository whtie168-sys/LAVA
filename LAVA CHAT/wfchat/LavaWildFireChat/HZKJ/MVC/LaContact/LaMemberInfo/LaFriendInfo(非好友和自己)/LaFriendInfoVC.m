//
//  LaFriendInfoVC.m
//  WildFireChat
//
//  Created by Ruby on 12/13/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaFriendInfoVC.h"

#import "LaTextModifyVC.h"
#import "LaAddValidationVC.h"


@interface LaFriendInfoVC ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIScrollView *oxaicsgoeScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *oxaicsgoeIconView;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeasoucNameLabel;

@property (weak, nonatomic) IBOutlet UIView *oxaicsgoeIDView;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeIdLabel;

@property (weak, nonatomic) IBOutlet UIView *muteView;
@property (weak, nonatomic) IBOutlet UISwitch *muteSW;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewTop;

@property (weak, nonatomic) IBOutlet UIView *oxaicsgoe86IDView;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeSexLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oxaicsgoeSexTop;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeSignLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oxaicsgoeSignLabelRight;

@property (weak, nonatomic) IBOutlet UIButton *signButton;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;


@property (nonatomic, strong) WFCCUserInfo *userInfo;
@property (nonatomic, strong) UserExtraInfo *extraInfo;

@property (nonatomic, strong) NSMutableArray<WFCCGroupMember *> *memberList;
@property (nonatomic, strong) WFCCGroupInfo *groupInfo;


@property (weak, nonatomic) IBOutlet UILabel *muteL;
@property (weak, nonatomic) IBOutlet UILabel *sexL;
@property (weak, nonatomic) IBOutlet UILabel *signL;

@end

@implementation LaFriendInfoVC

- (void)loadData {
    self.extraInfo = [UserExtraInfo mj_objectWithKeyValues:self.userInfo.extra];
//    NSLog(@"userInfo2===%@",_userInfo.mj_JSONObject);
    
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
    _oxaicsgoeIDLabel.text = _userInfo.name;
    _oxaicsgoeSexLabel.text = (_userInfo.gender == 2 ? LLLLLL(@"Male") : (_userInfo.gender == 1 ? LLLLLL(@"Female") : LLLLLL(@"Other")));
    
    BOOL isImy = [self.userId isEqualToString:WFCCNetworkService.sharedInstance.userId]; // 是否是本人
    _oxaicsgoeSignLabel.text = _extraInfo.sign.length ? _extraInfo.sign : (isImy ? (_isChinese?@"我什么都没写":@"Đối phương không viêt gì") : (_isChinese?@"对方什么都没有写":@"Đối phương không viêt gì"));
    
    if ([self isGroupOwner:WFCCNetworkService.sharedInstance.userId] || [self isGroupManager:WFCCNetworkService.sharedInstance.userId] || isImy) {
        // 是群主或管理员或者本人
        
    }else { // 非本人 非好友
        _oxaicsgoeIDView.hidden = YES;
        _lineViewTop.constant = 20.0;
        _oxaicsgoe86IDView.hidden = YES;
        _oxaicsgoeSexTop.constant = 0.0;
    }
    if (isImy) { // 本人
        _addFriendButton.hidden = YES;
    }else {
        _signButton.hidden = YES;
        _oxaicsgoeSignLabelRight.constant = 20.0;
        
        if (_groupId.length > 0) { // 通过群聊过来的、要判断群扩展字段(是否允许群成员互加好友)
            if (_isCardEnter) { // 名片消息进来的
                _addFriendButton.hidden = NO;
            }else {
                WFCCGroupInfo *groupInfo = [WFCCIMService.sharedWFCIMService getGroupInfo:_groupId refresh:NO];
                GroupExtraInfo *groupExtra = [GroupExtraInfo mj_objectWithKeyValues:groupInfo.extra];
                if (groupExtra.disableAddFriend == 1) { // 是否禁止群成员互加好友
                    if ([self isGroupOwner:WFCCNetworkService.sharedInstance.userId] || [self isGroupManager:WFCCNetworkService.sharedInstance.userId]) {
                        _addFriendButton.hidden = NO;
                    } else {
                        _addFriendButton.hidden = YES;
                    }
                }else {
                    _addFriendButton.hidden = NO;
                }
            }
        }else {
            _addFriendButton.hidden = NO;
        }
    }
    if (_userInfo == nil) {
        _addFriendButton.hidden = YES;
    }
}
- (void)onGroupMemberUpdated:(NSNotification *)notification {
    if ([self.groupId isEqualToString:notification.object]) {
        _memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:_groupId forceUpdate:NO].mutableCopy;
    }
}
- (void)onGroupInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCGroupInfo *> *groupInfoList = notification.userInfo[@"groupInfoList"];
    for (WFCCGroupInfo *groupInfo in groupInfoList) {
        if ([self.groupId isEqualToString:groupInfo.target]) {
            _groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:_groupId refresh:NO];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    
    if (![self.userId isEqualToString:WFCCNetworkService.sharedInstance.userId]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self itemImage:@"xaicosgoeMore" action:@selector(oxaicsgoeMore)]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState) name:kUserOnlineStateUpdated object:nil];
    
    _oxaicsgoeIconView.layer.cornerRadius = 38.0;
    _oxaicsgoeIDView.layer.cornerRadius = 15.0;
    _addFriendButton.layer.cornerRadius = 25.0;
    
    self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:_userId inGroup:_groupId refresh:YES];
    if (_groupId.length > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupMemberUpdated:) name:kGroupMemberUpdated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
        _memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:_groupId forceUpdate:YES].mutableCopy;
        _groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:_groupId refresh:YES];
    }
    
    [self loadData];
    [self muteStatus];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateOnlineState];
    });
    
    _muteL.text = LLLLLL(@"Mute");
    _sexL.text = LLLLLL(@"Gender");
    _signL.text = LLLLLL(@"PersonalSignature");
    [_addFriendButton setTitle:(_isChinese ? @"添加" : @"Thêm") forState:UIControlStateNormal];
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

- (void)oxaicsgoeMore {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
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
    [actionSheet addAction:blackListAction];
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

- (IBAction)sign:(UIButton *)sender { // 个性签名
    LaTextModifyVC *vc = LaTextModifyVC.new;
    vc.modifyType = Modify_Sign;
    vc.defaultValue = _extraInfo.sign;
    WS(weakself)
    [vc setOnModified:^(NSString * _Nonnull value) {
        weakself.oxaicsgoeSignLabel.text = value;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)addFriend:(UIButton *)sender { // 添加好友
    WFCCUserInfo *myUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    
    LaAddValidationVC *vc = LaAddValidationVC.new;
    vc.userInfo = _userInfo;
    vc.name = (myUserInfo.friendAlias.length > 0 ? myUserInfo.friendAlias : myUserInfo.displayName);
    [self.navigationController pushViewController:vc animated:YES];
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




#pragma mark - 禁言相关

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
        if ([self.userId isEqualToString:WFCCNetworkService.sharedInstance.userId]) { // 是否进入自己的信息页面
            isShowMute = NO;
        }
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
        _lineViewTop.constant = 66.0 + 20.0;
    }else {
        _muteView.hidden = YES;
        _lineViewTop.constant = 20.0;
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



@end
