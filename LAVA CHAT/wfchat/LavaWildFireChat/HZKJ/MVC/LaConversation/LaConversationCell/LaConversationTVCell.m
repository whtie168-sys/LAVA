//
//  LaConversationTVCell.m
//  WildFireChat
//
//  Created by Ruby on 1/31/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaConversationTVCell.h"

@interface LaConversationTVCell ()
{
    BOOL _isManager;
    
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIView *contentBgView;

@property (weak, nonatomic) IBOutlet UIImageView *wsedcPotraitView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wsedcPotraitViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *wsedcTargetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wsedcStatusView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wsedcStatusViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *wsedcDigestLabel;

@property (weak, nonatomic) IBOutlet UILabel *wsedcTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wsedcSilentImgView;

@property (weak, nonatomic) IBOutlet UIView *asoucOnlineView;


@property (nonatomic, strong) WSEDCBubbleTipView *asoucBubbleView;
@property (nonatomic, strong) WFCCConversationSearchInfo *searchInfo;

@property (strong, nonatomic) WFCCUserInfo *userInfo; // 0129新增

@end

@implementation LaConversationTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _stateButton.hidden = YES;
    _iconLeft.constant = 0.0;
    
    _wsedcPotraitView.layer.cornerRadius = 24.0;
    
    _asoucOnlineView.hidden = YES;
    _asoucOnlineView.layer.cornerRadius = 5.0;
    _asoucOnlineView.layer.masksToBounds = YES;
    _asoucOnlineView.layer.borderColor = UIColor.whiteColor.CGColor;
    _asoucOnlineView.layer.borderWidth = 2.0;
    
    _wsedcSilentImgView.image = [QWERImage imageNamed:@"conversation_mute"];
    
    _isManager = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState) name:kUserOnlineStateUpdated object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isBig) {
        _wsedcPotraitViewWidth.constant = 40.0;
        _wsedcPotraitView.layer.cornerRadius = 20.0;
    }
}

- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    _isChinese = [CommonHelper.main isChinese];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    
    [self.wsedcPotraitView sd_setImageWithURL:URL(userInfo.portrait) placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                      context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];

    if (userInfo.friendAlias.length) {
        self.wsedcTargetLabel.text = userInfo.friendAlias;
    } else if(userInfo.displayName.length > 0) {
        self.wsedcTargetLabel.text = userInfo.displayName;
    } else {
        self.wsedcTargetLabel.text = [NSString stringWithFormat:@"Người dùng<%@>", self.info.conversation.target];
    }
    
    if ([userInfo.userId isEqualToString:@"customer_service"]) {
        self.wsedcPotraitView.image = IMAGENAME(@"customerService");
        self.wsedcTargetLabel.text = LLLLLL(@"AppCustomerService");
    }else if ([userInfo.userId isEqualToString:@"group_message"]) {
        self.wsedcPotraitView.image = [QWERImage imageNamed:@"GroupNotiIcon"];
        self.wsedcTargetLabel.text = LLLLLL(@"GroupNotifications");
    }else if ([userInfo.userId isEqualToString:@"FireRobot"]) {
        if (userInfo.portrait.length <= 0) {
            self.wsedcPotraitView.image = IMAGENAME(@"LAVA Messenger");
        }
        self.wsedcTargetLabel.text = @"LAVA Quản lý";
    }else if ([userInfo.userId isEqualToString:@"wfc_file_transfer"]) {
        if (_isChinese) {
            self.wsedcTargetLabel.text = @"文件传输助手";
        }else {
            self.wsedcTargetLabel.text = @"Trợ lý truyền tải tập tin";
        }
    }
    
    [self updateOnlineState];
}
- (void)updateOnlineState {
    // 在线状态
    if ([WFCCIMService.sharedWFCIMService isEnableUserOnlineState]) { // 是否开启了在线状态
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:self->_userInfo.extra];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateOnlineViewWithExtraInfo:extraInfo];
            });
        });
        
//        UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra];
//        
//        if (extraInfo != nil) {
//            // 0 所有人    1 仅通讯录联系人    2 不显示在线时间
//            if (extraInfo.disableShowLastLoginTime == 0) {
//                [self onlineState];
//            }else if (extraInfo.disableShowLastLoginTime == 1) {
//                if ([CommonHelper.main isAddressBookContact:_userInfo.mobile]) {
//                    [self onlineState];
//                }else {
//                    self.asoucOnlineView.hidden = YES;
//                }
//            }else {
//                self.asoucOnlineView.hidden = YES;
//            }
//        }else {
//            self.asoucOnlineView.hidden = YES;
//        }
    }else {
        self.asoucOnlineView.hidden = YES;
    }
}


- (void)updateOnlineViewWithExtraInfo:(UserExtraInfo *)extraInfo {
    if (!extraInfo) {
        self.asoucOnlineView.hidden = YES;
        return;
    }

    if (extraInfo.disableShowLastLoginTime == 0) {
        [self onlineState];
    } else if (extraInfo.disableShowLastLoginTime == 1) {
        if ([CommonHelper.main isAddressBookContact:_userInfo.mobile]) {
            [self onlineState];
        } else {
            self.asoucOnlineView.hidden = YES;
        }
    } else {
        self.asoucOnlineView.hidden = YES;
    }
}


- (void)onlineState {
    WFCCUserOnlineState *state = [[WFCCIMService sharedWFCIMService] getUserOnlineState:self.info.conversation.target];
    BOOL online = NO;
    if (state.clientStates.count) { //有设备在线
        if(state.customState.state != 4) { //没有设置为隐身
            for (WFCCClientState *cs in state.clientStates) {
                if(cs.state == 0) { // 设备的在线状态，0是在线，1是有session但不在线，其它不在线。
                    online = YES;
                    break;
                }
            }
        }
    }
    self.asoucOnlineView.hidden = !online;
}

- (void)updateGroupInfo:(WFCCGroupInfo *)groupInfo {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GroupPortraitChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    
    if (groupInfo.type == GroupType_Organization) {
        if (groupInfo.portrait.length) {
            [self.wsedcPotraitView sd_setImageWithURL:URL(groupInfo.portrait) placeholderImage:[QWERImage imageNamed:@"organization_icon"] options:SDWebImageScaleDownLargeImages
                                              context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        }else {
            self.wsedcPotraitView.image = [QWERImage imageNamed:@"organization_icon"];
        }
    } else { // 群头像  群聊头像
        if (groupInfo.portrait.length) { // 未传群头像 将会生成以9个用户头像组成的群头像、 WFCCIMService 里2277行被注视，实现未传群头像进行显示默认群头像的功能
            [self.wsedcPotraitView sd_setImageWithURL:URL(groupInfo.portrait) placeholderImage:[QWERImage imageNamed:@"groupIcon"] options:SDWebImageScaleDownLargeImages
                                              context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        }else {
            __weak typeof(self)ws = self;
            NSString *groupId = groupInfo.target;
            
            [[NSNotificationCenter defaultCenter] addObserverForName:@"GroupPortraitChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                NSString *path = [note.userInfo objectForKey:@"path"];
                if ([groupId isEqualToString:note.object] &&
                    ((ws.info.conversation.type == Group_Type && [ws.info.conversation.target isEqualToString:groupId]) ||
                     (ws.searchInfo.conversation.type == Group_Type  && [ws.searchInfo.conversation.target isEqualToString:groupId]))) {
                    [ws.wsedcPotraitView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[QWERImage imageNamed:@"groupIcon"] options:SDWebImageScaleDownLargeImages
                                                    context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
                }
            }];
            [self.wsedcPotraitView setImage:[QWERImage imageNamed:@"groupIcon"]];
        }
    }
  
    if (groupInfo.displayName.length > 0) {
        self.wsedcTargetLabel.text = groupInfo.displayName;
    }else {
        self.wsedcTargetLabel.text = LLLLLL(@"GroupChat");
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.wsedcPotraitView sd_cancelCurrentImageLoad];
    self.wsedcPotraitView.image = nil;
}

- (void)setInfo:(WFCCConversationInfo *)info {
    _info = info;
    if (![WFCCIMService.sharedWFCIMService isEnableSyncDraft]) {
        _info.draft = @"";
    }
    
    _isManager = [self isGroupManager:WFCCNetworkService.sharedInstance.userId];
    
    if (info.unreadCount.unread == 0) {
        self.asoucBubbleView.hidden = YES;
    } else {
        self.asoucBubbleView.hidden = NO;
        if (info.isSilent) {
            self.asoucBubbleView.isShowNotificationNumber = NO;
        } else {
            self.asoucBubbleView.isShowNotificationNumber = YES;
        }
        [self.asoucBubbleView setBubbleTipNumber:info.unreadCount.unread];
    }
    
    if (info.isSilent) {
        _wsedcSilentImgView.hidden = NO;
    }else {
        _wsedcSilentImgView.hidden = YES;
    }
  
    [self update:info.conversation];
    self.wsedcTimeLabel.hidden = NO;
    self.wsedcTimeLabel.text = [QWERUtilities formatTimeLabel:info.timestamp];
    
    BOOL darkMode = NO;
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            darkMode = YES;
        }
    }
    if (darkMode) {
        if (info.isTop) {
            [self.contentView setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.f]];
        } else {
            self.contentView.backgroundColor = [QWERConfigManager globalManager].backgroudColor;
        }
    } else {
        if (info.isTop) {
            [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"0xf7f7f7"]];
        } else {
            self.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (info.lastMessage && info.lastMessage.direction == MessageDirection_Send) {
        if (info.lastMessage.status == Message_Status_Sending) {
            self.wsedcStatusView.image = [QWERImage imageNamed:@"conversation_message_sending"];
            self.wsedcStatusView.hidden = NO;
            self.wsedcStatusViewWidth.constant = 17.0;
        } else if(info.lastMessage.status == Message_Status_Send_Failure) {
            self.wsedcStatusView.image = [QWERImage imageNamed:@"MessageSendError"];
            self.wsedcStatusView.hidden = NO;
            self.wsedcStatusViewWidth.constant = 17.0;
        } else {
            self.wsedcStatusView.hidden = YES;
            self.wsedcStatusViewWidth.constant = 0.0;
        }
    }else {
        self.wsedcStatusView.hidden = YES;
        self.wsedcStatusViewWidth.constant = 0.0;
    }
}


- (void)update:(WFCCConversation *)conversation {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _isChinese = [CommonHelper.main isChinese];
    
    WFCCGroupInfo *groupInfo;
    if(conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:conversation.target refresh:NO];
        if(userInfo.userId.length == 0) {
            userInfo = [[WFCCUserInfo alloc] init];
            userInfo.userId = conversation.target;
        }
        [self updateUserInfo:userInfo];
    } else if (conversation.type == Group_Type) {
        groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:conversation.target refresh:NO];
        if(groupInfo.target.length == 0) {
            groupInfo = [[WFCCGroupInfo alloc] init];
            groupInfo.target = conversation.target;
        }
        [self updateGroupInfo:groupInfo];
        self.asoucOnlineView.hidden = YES;
    } else if(conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:conversation.target refresh:NO];
        if (channelInfo.channelId.length == 0) {
            channelInfo = [[WFCCChannelInfo alloc] init];
            channelInfo.channelId = conversation.target;
        }
        [self updateChannelInfo:channelInfo];
        self.asoucOnlineView.hidden = YES;
    } else if(conversation.type == SecretChat_Type){
//        WFCCSecretChatInfo *secretInfo = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:conversation.target];
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:conversation.target].userId;
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
        [self updateUserInfo:userInfo];
    } else {
        self.wsedcTargetLabel.text = LLLLLL(@"Chatroom");
        self.asoucOnlineView.hidden = YES;
    }
    
    self.wsedcDigestLabel.attributedText = nil;
    
    NSString *secretChatStateText = nil;
    if(conversation.type == SecretChat_Type) {
        WFCCSecretChatState secretChatState = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:conversation.target].state;
        if (secretChatState == SecretChatState_Starting) {
            secretChatStateText = _isChinese ? @"密聊会话建立中，正在等待对方响应。" : @"Hội thoại mật được thiết lập, đang chờ đáp ứng.";
        } else if(secretChatState == SecretChatState_Canceled) {
            secretChatStateText = _isChinese ? @"密聊会话已取消！" : @"Cuộc trò chuyện mật đã bị hủy bỏ!";
        }
    }
    
    if (secretChatStateText) {
        self.wsedcDigestLabel.text = secretChatStateText;
    }else if (_info.draft.length) { // 草稿
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:(_isChinese ? @"[草稿]" : @"[Dự thảo]") attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
        
        NSError *__error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[_info.draft dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:kNilOptions
                                                                     error:&__error];
        
        NSString *text = _info.draft;
        if (!__error) {
            //兼容android/web端
            if([dictionary[@"content"] isKindOfClass:[NSString class]]) {
                text = dictionary[@"content"];
            } else if([dictionary[@"text"] isKindOfClass:[NSString class]]) {
                text = dictionary[@"text"];
            }
        }
        
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:text]];

        if (_info.conversation.type == Group_Type && _info.unreadCount.unreadMentionAll + _info.unreadCount.unreadMention > 0) {
            NSMutableAttributedString *tmp = [[NSMutableAttributedString alloc] initWithString:(_isChinese ? @"[有人@你]" : @"[Ai đó @ bạn]") attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
            [tmp appendAttributedString:attString];
            attString = tmp;
        }
        self.wsedcDigestLabel.attributedText = attString;
    } else if (_info.lastMessage.direction == MessageDirection_Receive && _info.conversation.type == Group_Type) { // 接收
        NSString *groupId = nil;
        if (_info.conversation.type == Group_Type) {
            groupId = _info.conversation.target;
        }
        WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:_info.lastMessage.fromUser inGroup:groupId refresh:NO];
        if (sender.friendAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.wsedcDigestLabel.text = [NSString stringWithFormat:@"%@:%@", sender.friendAlias, _info.lastMessage.digest];
        }else if (sender.groupAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.wsedcDigestLabel.text = [NSString stringWithFormat:@"%@:%@", sender.groupAlias, _info.lastMessage.digest];
        }else if (sender.displayName.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.wsedcDigestLabel.text = [NSString stringWithFormat:@"%@:%@", sender.displayName, _info.lastMessage.digest];
        }else {
//            self.wsedcDigestLabel.text = _info.lastMessage.digest;
            if ([self filteringData:_info.lastMessage.content]) { // YES 可以将最后一条消息显示出来  0229新增判断
                self.wsedcDigestLabel.text = _info.lastMessage.digest;
            }else {
                self.wsedcDigestLabel.text = @"";
            }
        }
        
        if (_info.unreadCount.unreadMentionAll + _info.unreadCount.unreadMention > 0) {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:(_isChinese ? @"[有人@你]" : @"[Ai đó @ bạn]") attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
            if (self.wsedcDigestLabel.text.length) {
                [attString appendAttributedString:[[NSAttributedString alloc] initWithString:self.wsedcDigestLabel.text]];
            }
            
            self.wsedcDigestLabel.attributedText = attString;
        }
    } else { // WFCCGroupSetManagerNotificationContent      子类重写：- (NSString *)digest:(WFCCMessage *)message
//        if ([_info.lastMessage.content.class isEqual:NSClassFromString(@"WFCCGroupSetManagerNotificationContent")]) {
//            self.wsedcDigestLabel.text = @"";
//            return;
//        }
        if ([self filteringData:_info.lastMessage.content]) { // YES 可以将最后一条消息显示出来  0229新增判断
            if (_isChinese) {
                self.wsedcDigestLabel.text = _info.lastMessage.digest;
            }else {
                if ([_info.lastMessage.digest containsString:@"我是群通知"]) {
                    self.wsedcDigestLabel.text = @"Xin chào, đây là nhóm thông báo";
                }else if ([_info.lastMessage.digest containsString:@"我是文件传输助手"]) {
                    self.wsedcDigestLabel.text = @"Xin chào, tôi là trợ lý chuyển tập tin";
                }else if ([_info.lastMessage.digest containsString:@"我是官方客服"]) {
                    self.wsedcDigestLabel.text = @"Xin chào, tôi là dịch vụ khách hàng chính thức! Anh có thể nói chuyện với tôi";
                }else {
                    self.wsedcDigestLabel.text = _info.lastMessage.digest;
                }
            }
        }else {
            self.wsedcDigestLabel.text = @"";
        }
    }
}

- (void)reloadCell {
    [self setInfo:self.info];
}


- (void)onUserInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    WFCCConversationInfo *conv = self.info;
    
    for (WFCCUserInfo *userInfo in userInfoList) {
        if (conv.conversation.type == Single_Type || conv.conversation.type == SecretChat_Type) {
            if([userInfo.userId isEqualToString:conv.conversation.target]) {
                [self reloadCell];
                break;
            }
        }
        if ([conv.lastMessage.fromUser isEqualToString:userInfo.userId]) {
            [self reloadCell];
            break;
        }
    }
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCGroupInfo *> *groupInfoList = notification.userInfo[@"groupInfoList"];
    WFCCConversationInfo *conv = self.info;
    if(conv.conversation.type == Group_Type) {
        for (WFCCGroupInfo *groupInfo in groupInfoList) {
            if ([conv.conversation.target isEqualToString:groupInfo.target]) {
                [self reloadCell];
                break;
            }
        }
    }
}

- (void)onChannelInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCChannelInfo *> *channelInfoList = notification.userInfo[@"channelInfoList"];
    WFCCConversationInfo *conv = self.info;
    if(conv.conversation.type == Channel_Type) {
        for (WFCCChannelInfo *channelInfo in channelInfoList) {
            if ([conv.conversation.target isEqualToString:channelInfo.channelId]) {
                [self reloadCell];
                break;
            }
        }
    }
}



- (void)setSearchInfo:(WFCCConversationSearchInfo *)searchInfo {
    _searchInfo = searchInfo;
    self.asoucBubbleView.hidden = YES;
    self.wsedcTimeLabel.hidden = YES;
    [self update:searchInfo.conversation];
    if (searchInfo.marchedCount > 1) {
        self.wsedcDigestLabel.text = [NSString stringWithFormat:@"%d %@", searchInfo.marchedCount, (_isChinese?@"条记录":@" hồ sơ")];
    } else {
        NSString *strContent = searchInfo.marchedMessage.digest;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:strContent];
        NSRange range = [strContent rangeOfString:searchInfo.keyword options:NSCaseInsensitiveSearch];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
        self.wsedcDigestLabel.attributedText = attrStr;
    }
}

- (void)updateChannelInfo:(WFCCChannelInfo *)channelInfo {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelInfoUpdated:) name:kChannelInfoUpdated object:nil];
    
    [self.wsedcPotraitView sd_setImageWithURL:URL(channelInfo.portrait) placeholderImage:[QWERImage imageNamed:@"channel_default_portrait"] options:SDWebImageScaleDownLargeImages
                                      context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    
    if (channelInfo.name.length > 0) {
        self.wsedcTargetLabel.text = channelInfo.name;
    }else {
        self.wsedcTargetLabel.text = _isChinese ? @"频道" : @"kênh";
    }
}


- (WSEDCBubbleTipView *)asoucBubbleView {
    if (!_asoucBubbleView) {
        if (self.wsedcPotraitView) {
            _asoucBubbleView = [[WSEDCBubbleTipView alloc] initWithSuperView:self.contentBgView];
            _asoucBubbleView.hidden = YES;
        }
    }
    return _asoucBubbleView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - 公屏显示问题 0229新增


- (BOOL)filteringData:(WFCCMessageContent *)content { // 返回NO 不添加该条数据
    if (_info.conversation.type != Group_Type) {
        return YES;
    }
    
//    NSLog(@"contentClass===%@",NSStringFromClass(content.class));
    
    if ([content isKindOfClass:NSClassFromString(@"WFCCGroupSetManagerNotificationContent")]) { // 设置/取消群管理员的通知消息
        // 群主和管理员可以正常看到 [self isGroupOwner] || [self isGroupManager:WFCCNetworkService.sharedInstance.userId]
        if (_isManager) {
            return YES;
        }
        WFCCGroupSetManagerNotificationContent *contentAA = (WFCCGroupSetManagerNotificationContent *)content;
        for (NSString *userid in contentAA.memberIds) {
            if ([userid isEqualToString:WFCCNetworkService.sharedInstance.userId]) {
                return YES; // 说明该处理的消息与我有关
            }
        }
        [self deleteMessage];
        return NO;
    }else if ([content isKindOfClass:NSClassFromString(@"WFCCGroupMuteNotificationContent")] || // 群禁言的通知消息 - 全禁言
              [content isKindOfClass:NSClassFromString(@"WFCCGroupPrivateChatNotificationContent")] || // 这几个都是建群的通知消息
              [content isKindOfClass:NSClassFromString(@"WFCCGroupJoinTypeNotificationContent")]) {
        return YES;
    }
    else if ([content isKindOfClass:NSClassFromString(@"WFCCRecallMessageContent")]) { // 0415
        // 群聊内，管理员撤回消息提示是全员可见，需要改为仅管理员/群主可见
        WFCCRecallMessageContent *contentAA = (WFCCRecallMessageContent *)content;
        // 该撤回消息的是群主或者管理员  仅管理员和群主可见
        if ([self isGroupManager:contentAA.operatorId]) {
            if (_isManager) { // 仅管理员和群主可见
                return YES;
            }else {
                [self deleteMessage];
                return NO;
            }
        }else { // 普通用户撤回的消息，任何人都可见-->不做更改
                return YES;
        }
    }
    else if ([content isKindOfClass:NSClassFromString(@"WFCCKickoffGroupMemberNotificationContent")] ||
              [content isKindOfClass:NSClassFromString(@"WFCCKickoffGroupMemberVisibleNotificationContent")]) { // 群组踢人的通知消息
        if (_isManager) { // 群主和管理员可以正常看到
            return YES;
        }
        if ([content isKindOfClass:NSClassFromString(@"WFCCKickoffGroupMemberNotificationContent")]) {
            WFCCKickoffGroupMemberNotificationContent *contentAA = (WFCCKickoffGroupMemberNotificationContent *)content;
            for (NSString *userid in contentAA.kickedMembers) {
                if ([userid isEqualToString:WFCCNetworkService.sharedInstance.userId]) {
                    return YES;
                }
            }
        }else {
            WFCCKickoffGroupMemberVisibleNotificationContent *contentAA = (WFCCKickoffGroupMemberVisibleNotificationContent *)content;
            for (NSString *userid in contentAA.kickedMembers) {
                if ([userid isEqualToString:WFCCNetworkService.sharedInstance.userId]) {
                    return YES;
                }
            }
        }
        [self deleteMessage];
        return NO;
    }else if ([content isKindOfClass:NSClassFromString(@"WFCCGroupMemberMuteNotificationContent")]) { // 群成员被禁言
        if (_isManager) { // 群主和管理员可以正常看到
            return YES;
        }
        WFCCGroupMemberMuteNotificationContent *contentAA = (WFCCGroupMemberMuteNotificationContent *)content;
        for (NSString *userid in contentAA.targetIds) {
            if ([userid isEqualToString:WFCCNetworkService.sharedInstance.userId]) {
                return YES;
            }
        }
        [self deleteMessage];
        return NO;
    }else if ([content isKindOfClass:NSClassFromString(@"WFCCGroupMemberAllowNotificationContent")]) { // 群成员禁言被允许的通知消息
        if (_isManager) { // 群主和管理员可以正常看到
            return YES;
        }
        WFCCGroupMemberAllowNotificationContent *contentAA = (WFCCGroupMemberAllowNotificationContent *)content;
        for (NSString *userid in contentAA.targetIds) {
            if ([userid isEqualToString:WFCCNetworkService.sharedInstance.userId]) {
                return YES;
            }
        }
        [self deleteMessage];
        return NO;
    }else if ([content isKindOfClass:NSClassFromString(@"WFCCQuitGroupVisibleNotificationContent")] ||
              [content isKindOfClass:NSClassFromString(@"WFCCQuitGroupNotificationContent")]) { // 退群的通知消息
        if (_isManager) { // 群主和管理员可以正常看到
            return YES;
        }
        [self deleteMessage];
        return NO;
    }else if ([content isKindOfClass:NSClassFromString(@"WFCCChangeGroupNameNotificationContent")] ||
              [content isKindOfClass:NSClassFromString(@"WFCCChangeGroupPortraitNotificationContent")] ||
              [content isKindOfClass:NSClassFromString(@"WFCCModifyGroupAliasNotificationContent")] ||
              [content isKindOfClass:NSClassFromString(@"WFCCModifyGroupMemberExtraNotificationContent")] ||
              [content isKindOfClass:NSClassFromString(@"WFCCModifyGroupExtraNotificationContent")] ||
              [content isKindOfClass:NSClassFromString(@"WFCCGroupSettingsNotificationContent")]) { //
        if (_isManager) { // 群主和管理员可以正常看到
            return YES;
        }
        [self deleteMessage];
        return NO;
    }
    
    return YES;
}

- (void)deleteMessage {
    BOOL isSuccess = [[WFCCIMService sharedWFCIMService] deleteMessage:self.info.lastMessage.messageId];
    if (isSuccess) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteMessages object:@(self.info.lastMessage.messageUid)];
    }
}

- (BOOL)isGroupManager:(NSString *)targetUserId {
    if (self.info.conversation.type != Group_Type) {
        return NO;
    }
    __block BOOL isManager = NO;
    NSArray<WFCCGroupMember *> *groupMembers = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.info.conversation.target forceUpdate:NO];
    [groupMembers enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.memberId isEqualToString:targetUserId]) {
            if (obj.type == Member_Type_Owner || obj.type == Member_Type_Manager) {
                isManager = YES;
            }
            *stop = YES;
        }
    }];
    return isManager;
}

@end
