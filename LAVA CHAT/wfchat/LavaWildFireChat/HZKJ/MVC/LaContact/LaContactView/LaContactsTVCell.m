//
//  LaContactsTVCell.m
//  WildFireChat
//
//  Created by Ruby on 12/4/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaContactsTVCell.h"

@interface LaContactsTVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *trewqPortraitView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTop;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UIView *asoucOnlineView;

@property (nonatomic, assign) BOOL isEnableOnline;

@property (nonatomic, strong) WFCCUserInfo *userInfo;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *groupId;

@property (weak, nonatomic) IBOutlet UILabel *groupOwenLabel;

@end

@implementation LaContactsTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _trewqPortraitView.layer.cornerRadius = 25.0;
    _asoucOnlineView.layer.cornerRadius = 5.0;
    _asoucOnlineView.layer.masksToBounds = YES;
    _asoucOnlineView.layer.borderColor = UIColor.whiteColor.CGColor;
    _asoucOnlineView.layer.borderWidth = 2.0;
    _groupOwenLabel.layer.cornerRadius = 10.0;
    _groupOwenLabel.layer.masksToBounds = YES;
    
    _groupOwenLabel.text = UNString(@"   %@   ", LLLLLL(@"Owner")); // Chủ nhóm
//    _groupOwenLabel.text = LLLLLL(@"Owner");
}

//显示管理员
- (void)showGroupManager {
    _groupOwenLabel.hidden = NO;
    _groupOwenLabel.text = UNString(@"   %@   ", LLLLLL(@"Manager"));
    _groupOwenLabel.clipsToBounds = YES;
    _groupOwenLabel.layer.cornerRadius = 5;
    _groupOwenLabel.backgroundColor = [UIColor colorWithHexString:@"#2BDD30"];
}

//显示群主
- (void)showGroupOwn {
    _groupOwenLabel.hidden = NO;
    _groupOwenLabel.text = UNString(@"   %@   ", LLLLLL(@"Owner"));
    _groupOwenLabel.clipsToBounds = YES;
    _groupOwenLabel.layer.cornerRadius = 5;
    _groupOwenLabel.backgroundColor = [UIColor colorWithHexString:@"#F8C21F"];
}

//普通成员
- (void)showMember {
    _groupOwenLabel.hidden = YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    for (WFCCUserInfo *userInfo in userInfoList) {
        if ([self.userId isEqualToString:userInfo.userId]) {
            [self updateUserInfo:userInfo];
            break;
        }
    }
}

- (void)setUserId:(NSString *)userId groupId:(NSString *)groupId {
    _userId = userId;
    _groupId = groupId;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState) name:kUserOnlineStateUpdated object:nil];
    
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId inGroup:groupId refresh:NO];
    if(userInfo.userId.length == 0) {
        userInfo = [[WFCCUserInfo alloc] init];
        userInfo.userId = userId;
    }
    [self updateUserInfo:userInfo];
}

- (void)updateOnlineState {
    [self updateUserInfo:_userInfo];
}

- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
    if(!userInfo) {
        return;
    }
    _userInfo = userInfo;
    
    [self.trewqPortraitView sd_setImageWithURL:URL(userInfo.portrait) placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    if (userInfo.friendAlias.length) {
        self.asoucNameLabel.text = userInfo.friendAlias;
    } else if (userInfo.groupAlias.length) {
        self.asoucNameLabel.text = userInfo.groupAlias;
    } else if(userInfo.displayName.length > 0) {
        self.asoucNameLabel.text = userInfo.displayName;
    } else {
        self.asoucNameLabel.text = [NSString stringWithFormat:@"Người dùng<%@>", userInfo.userId];
    }
    
    if ([WFCCIMService.sharedWFCIMService isEnableUserOnlineState]) { // 是否开启了在线状态
        
        UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra];
        if (extraInfo.disableShowLastLoginTime == 0) { // 0 所有人    1 仅通讯录联系人    2 不显示在线时间
            [self onlineState];
        }else if (extraInfo.disableShowLastLoginTime == 1) {
            if ([CommonHelper.main isAddressBookContact:_userInfo.mobile]) {
                [self onlineState];
            }else {
                self.isEnableOnline = NO;
            }
        }else {
            self.isEnableOnline = NO;
        }
        
    }else {
        self.isEnableOnline = NO;
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
    self.isEnableOnline = (online || hasMobileSession);
    self.asoucOnlineView.hidden = !online;
    
    if (!online) {
        if (hasMobileSession && mobileLastSeen > 0) {
            NSString *strSeenTime = [CommonHelper.main onlineStatusDesc:mobileLastSeen];
            if (strSeenTime.length) {
                _onlineLabel.text = [NSString stringWithFormat:@"%@ %@",strSeenTime, LLLLLL(@"Online")];
            }else {
                _onlineLabel.text = LLLLLL(@"JustOffTheLine");
            }
        }
    }else {
        _onlineLabel.text = LLLLLL(@"Online");
    }
}

- (void)setIsEnableOnline:(BOOL)isEnableOnline {
    _isEnableOnline = isEnableOnline;
    if (_isEnableOnline) {
        _nameTop.constant = 3.0;
        _onlineLabel.hidden = NO;
        _asoucOnlineView.hidden = NO;
    }else {
        _nameTop.constant = (50.0-21.0)/2.0;
        _onlineLabel.hidden = YES;
        _asoucOnlineView.hidden = YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.trewqPortraitView sd_cancelCurrentImageLoad];
    self.trewqPortraitView.image = nil;
}


@end
