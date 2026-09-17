//
//  LaSingleSetupVC.m
//  WildFireChat
//
//  Created by Ruby on 12/12/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaSingleSetupVC.h"

#import "MessageBurnTimePopView.h"

#import "LaMemberInfoVC.h"
#import "LaComplaintVC.h"
#import "LaMessageVC.h"
#import "LaFriendInfoVC.h"
#import "LaConversationSearchVC.h"
#import "LaIngleSetupSaveTimeView.h"
#import "ConversationDeleteManager.h"


@interface LaSingleSetupVC ()
{
    NSInteger _burnSelectIndex;
    BOOL _isChinese;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *tzboeuNameLabel;

@property (weak, nonatomic) IBOutlet UISwitch *yzdoajBurnSW;
@property (weak, nonatomic) IBOutlet UIView *burnwsedcTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *yzdoajBurnTimeLabel;
@property (nonatomic, strong) NSMutableArray *yzdoajBurnTimes;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *findChatViewHeight;

@property (weak, nonatomic) IBOutlet UISwitch *topChatSW;
@property (weak, nonatomic) IBOutlet UISwitch *noDisturbingSW;


@property (nonatomic, strong) WFCCUserInfo *userInfo;
@property (nonatomic, strong) WFCCChannelInfo *channelInfo;
@property (nonatomic, strong) NSString *userId;


@property (weak, nonatomic) IBOutlet UILabel *burnL;
@property (weak, nonatomic) IBOutlet UILabel *burnDescL;
@property (weak, nonatomic) IBOutlet UILabel *burnTimeL;
@property (weak, nonatomic) IBOutlet UILabel *chatContentL;
@property (weak, nonatomic) IBOutlet UILabel *topChatL;
@property (weak, nonatomic) IBOutlet UILabel *noDisturbingL;
@property (weak, nonatomic) IBOutlet UILabel *complaintL;

@property (weak, nonatomic) IBOutlet UILabel *clearChatL;
@property (weak, nonatomic) IBOutlet UILabel *saveDayL;
@property (weak, nonatomic) IBOutlet UILabel *chatsaveL;
@property (weak, nonatomic) IBOutlet UILabel *chatsaveInfoL;
@property (weak, nonatomic) IBOutlet UILabel *deletchatL;

@end

@implementation LaSingleSetupVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.conversation.type == Single_Type) {
        _userId = self.conversation.target;
        self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.conversation.target refresh:NO];
    }else if (self.conversation.type == Channel_Type) {
        _userId = self.conversation.target;
        self.channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:NO];
    }else if (self.conversation.type == SecretChat_Type) {
        WFCCSecretChatInfo *secretChatInfo = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:self.conversation.target];
        if(!secretChatInfo) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        _userId = secretChatInfo.userId;
        self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:_userId refresh:YES];
    }
//    NSLog(@"userInfo===%@",_userInfo.mj_JSONObject);
    
    WFCCConversationInfo *conversationInfo = [WFCCIMService.sharedWFCIMService getConversationInfo:_conversation];
    _topChatSW.on = conversationInfo.isTop;
    _noDisturbingSW.on = conversationInfo.isSilent;
    
    
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/single/get_option" params:@{@"current":WFCCNetworkService.sharedInstance.userId, @"target":_userId} success:^(NSDictionary * _Nonnull dict) {
        weakself.autoDelete = [dict[@"result"][@"autoDelete"] longLongValue];
        weakself.waitTime = [dict[@"result"][@"waitTime"] integerValue];
        
        [weakself burnData];
    } error:^(int errCode, NSString * _Nonnull message) {
    }];
    [self burnData];
}
- (void)burnData {
    self.yzdoajBurnSW.on = (self.autoDelete != 0);
    self.yzdoajBurnTimeLabel.text = UNString(@"%@", [self tranfrom:self.waitTime]);
    [self burnStatus];
    
    BOOL isHaved = NO;
    NSInteger i = 0;
    for (; i < BURN_TIMES.count; i ++) {
        if ([BURN_TIMES[i] integerValue] == self.waitTime) {
            isHaved = YES;
            break;
        }
    }
    if (isHaved) {
        self->_burnSelectIndex = i;
    }else {
        self->_burnSelectIndex = 0;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    
    if (self.conversation.type == Channel_Type) {
        self.navigationItem.title = LLLLLL(@"ChannelDesc");
    }else {
        self.navigationItem.title = LLLLLL(@"ConversationDetail");
    }
    
    _iconView.layer.cornerRadius = 22.0;
    _burnSelectIndex = 0;
    
    if (_isChinese) {
        
    }else {
        _burnL.text = @"Xóa sau khi đọc";
        _burnDescL.text = @"Mở tính năng xóa sau khi đọc, tin nhắn đã đọc trong thời gian quy định sẽ bị xóa";
        _burnTimeL.text = @"Thời gian tin nhắn bị xóa";
        _chatContentL.text = @"Tìm kiếm nội dung trò chuyện";
        _topChatL.text = @"Ghim trò chuyện";
        _noDisturbingL.text = @"Không làm phiền";
        
        _chatsaveL.text = @"Thời gian lưu giữ lịch sử trò chuyện";
        _chatsaveInfoL.text = @"Tự động xóa các bản ghi trò chuyện đã hết hạn";
        _deletchatL.text = @"Xóa lịch sử trò chuyện";
        _saveDayL.text = @"Vĩnh viễn";

    }
    _complaintL.text = LLLLLL(@"Complain");
    _clearChatL.text = LLLLLL(@"ClearChatHistory");
    NSString *type = [[ConversationDeleteManager shared] getTypeForTarget:self.conversation.target];
    if (type != nil) {
        self.saveDayL.text = [type isEqualToString:@"7"] ? LLLLLL(@"Record_save_time_seven") : LLLLLL(@"Record_save_time_thirty");
    }
}

- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    [_iconView sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    _tzboeuNameLabel.text = (_userInfo.friendAlias.length > 0 ? _userInfo.friendAlias : _userInfo.displayName);
}
- (void)setChannelInfo:(WFCCChannelInfo *)channelInfo {
    _channelInfo = channelInfo;
    [_iconView sd_setImageWithURL:URL(_channelInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    _tzboeuNameLabel.text = _channelInfo.name;
}



// 目标用户的详细信息
- (IBAction)targetUserinfo:(UIButton *)sender {
//    BOOL isIam = [_userId isEqualToString:WFCCNetworkService.sharedInstance.userId];
    BOOL isMyFriend = [WFCCIMService.sharedWFCIMService isMyFriend:_userId]; // 本人与本人不是好友关系
    if (isMyFriend) { // 是好友关系
        LaMemberInfoVC *vc = LaMemberInfoVC.new;
        vc.userId = _userId;
        [self.navigationController pushViewController:vc animated:YES];
    }else { // 本人或者 非好友关系
        LaFriendInfoVC *vc = LaFriendInfoVC.new;
//        vc.isManager = NO;
        vc.userId = _userId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 添加用户即为创建群聊
- (IBAction)addMember:(UIButton *)sender {
    FRSDASeletedUserVC *pvc = [[FRSDASeletedUserVC alloc] init];
    pvc.disabledUserNotSelected = YES;
    pvc.type = Horizontal;
    
    NSMutableArray *disabledUser = [[NSMutableArray alloc] init];
    [disabledUser addObject:self.conversation.target];
    pvc.disableUserIds = disabledUser;
    
    WS(weakself)
    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        [weakself createGroup:contacts];
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

- (void)createGroup:(NSArray<NSString *> *)contacts {
    __weak typeof(self) ws = self;
    
    NSMutableArray<NSString *> *memberIds = [contacts mutableCopy];
    if (![memberIds containsObject:self.conversation.target]) {
        [memberIds insertObject:self.conversation.target atIndex:0];
    }
    if (![memberIds containsObject:[WFCCNetworkService sharedInstance].userId]) {
        [memberIds insertObject:[WFCCNetworkService sharedInstance].userId atIndex:0];
    }
    
    NSString *name = LLLLLL(@"GroupChat");
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:memberIds.firstObject  refresh:NO];
    name = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
    
    for (int i = 1; i < MIN(8, memberIds.count); i++) {
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:memberIds[i]  refresh:NO];
        NSString *aaName = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
        if (name.length > 0) {
            if (name.length + aaName.length + 1 > 16) {
                name = [name stringByAppendingString:LLLLLL(@"Etc")];
                break;
            }
            name = [name stringByAppendingFormat:@", %@", aaName];
        }
    }
    
    [[WFCCIMService sharedWFCIMService] createGroup:nil name:name portrait:nil type:GroupType_Restricted groupExtra:nil members:memberIds memberExtra:nil notifyLines:@[@(0)] notifyContent:nil success:^(NSString *groupId) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            LaMessageVC *mvc = [[LaMessageVC alloc] init];
            mvc.conversation = [WFCCConversation conversationWithType:Group_Type target:groupId line:0];
            mvc.conversation.type = Group_Type;
            mvc.conversation.target = groupId;
            mvc.conversation.line = 0;
            
            UINavigationController *nav = self.navigationController;
            [self.navigationController popToRootViewControllerAnimated:NO];
            [nav pushViewController:mvc animated:YES];
        });
        
    } error:^(int error_code) {
        [ws.view makeToast:(self->_isChinese?@"创建群组失败":@"Thành lập nhóm chat thất bại") duration:2 position:CSToastPositionCenter];
    }];
}



- (IBAction)findChatHistory:(UIButton *)sender { // 查找聊天记录
    LaConversationSearchVC *mvc = LaConversationSearchVC.new;
    mvc.conversation = self.conversation;
    mvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mvc animated:YES];
}



- (IBAction)topChatSw:(UISwitch *)sender { // 置顶聊天
    [[WFCCIMService sharedWFCIMService] setConversation:_conversation top:sender.on?1:0 success:nil error:^(int error_code) {
        sender.on = !sender.on;
    }];
}

- (IBAction)noDisturbingSw:(UISwitch *)sender { // 消息免打扰
    [[WFCCIMService sharedWFCIMService] setConversation:_conversation silent:sender.on success:nil error:^(int error_code) {
        sender.on = !sender.on;
    }];
}



- (IBAction)complaint:(UIButton *)sender { // 投诉
    LaComplaintVC *vc = LaComplaintVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)saveRecord:(UIButton *)sender {
    LaIngleSetupSaveTimeView *saveV = [[LaIngleSetupSaveTimeView  alloc] init];
    [saveV setSaveTimeB:^(NSInteger tag) {
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"Record_save_time_alert_title") message:LLLLLL(@"Record_save_time_alert_info") preferredStyle:UIAlertControllerStyleAlert];
        [actionSheet addAction:[UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.saveDayL.text = tag == 1 ? LLLLLL(@"Record_save_time_seven") : LLLLLL(@"Record_save_time_thirty");
            [[ConversationDeleteManager shared] saveScheduleWithTarget:self.conversation.target type:(tag == 1 ? @"7":@"30")];
            [self.view makeToast:LLLLLL(@"SaveSuccessfully") duration:2 position:CSToastPositionCenter];
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }];
    [saveV setDefaultData:[[ConversationDeleteManager shared] getTypeForTarget:self.conversation.target]];
    [saveV show];
}

- (IBAction)clearAllChatRecord:(UIButton *)sender { // 清空聊天记录
    WS(weakself)
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"ConfirmDelete") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *actionLocalDelete = [UIAlertAction actionWithTitle:LLLLLL(@"DeleteLocalMsg") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ConversationDeleteManager shared] deleteScheduleWithTarget:weakself.conversation.target];
        [[WFCCIMService sharedWFCIMService] clearMessages:weakself.conversation];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:NO];
        hud.label.text = LLLLLL(@"Deleted");
        hud.mode = MBProgressHUDModeText;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:NO afterDelay:1.5];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageListChanged object:weakself.conversation];
    }];
    
    UIAlertAction *actionRemoteDelete = [UIAlertAction actionWithTitle:LLLLLL(@"DeleteRemoteMsg") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
        hud.label.text = LLLLLL(@"Deleting");
        [hud showAnimated:YES];
        
        [[ConversationDeleteManager shared] deleteScheduleWithTarget:weakself.conversation.target];
        [[WFCCIMService sharedWFCIMService] clearRemoteConversationMessage:weakself.conversation success:^{
            [hud hideAnimated:YES];
            hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:NO];
            hud.label.text = LLLLLL(@"Deleted");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageListChanged object:weakself.conversation];
        } error:^(int error_code) {
            [hud hideAnimated:YES];
            hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:NO];
            hud.label.text = LLLLLL(@"DeleteFailed");
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:NO afterDelay:1.5];
        }];
    }];
    
    [actionSheet addAction:actionLocalDelete];
    if(self.conversation.type != SecretChat_Type) {
        [actionSheet addAction:actionRemoteDelete];
    }
    [actionSheet addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:actionSheet animated:YES completion:nil];
    });
}




#pragma mark - 阅后即焚


- (IBAction)yzdoajBurnSW:(UISwitch *)sender {
    NSMutableDictionary *params = NSMutableDictionary.new;
    params[@"autoDelete"] = @(sender.on ? 1 : 0);
    if (sender.on == NO) {
        params[@"waitTime"] = @(0);
    }
    [self requestStateParams:params];
    [self burnStatus];
}

- (void)requestStateParams:(NSMutableDictionary *)params {
    params[@"id"] = @{@"current":WFCCNetworkService.sharedInstance.userId, @"target":_userId};
    
    [AppService.sharedAppService requestUrl:@"/single/set_option" params:params success:^(NSDictionary * _Nonnull dict) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBurnAfterReadingUpdated object:nil];
    } error:^(int errCode, NSString * _Nonnull message) {
    }];
}

// 消息销毁时间
- (IBAction)destructioTime:(UIButton *)sender {
    MessageBurnTimePopView *popView = [[MessageBurnTimePopView alloc] init];
    WS(weakself)
    [popView setTimeBlock:^(NSInteger row) {
        self->_burnSelectIndex = row;
        weakself.yzdoajBurnTimeLabel.text = weakself.yzdoajBurnTimes[row];
        
        NSMutableDictionary *params = NSMutableDictionary.new;
        params[@"waitTime"] = BURN_TIMES[row];
        [weakself requestStateParams:params];
    }];
    [popView showIndex:_burnSelectIndex datas:self.yzdoajBurnTimes];
}

- (void)burnStatus {
    if (_yzdoajBurnSW.on) {
        _burnwsedcTimeLabel.hidden = NO;
        _findChatViewHeight.constant = 52.0;
    }else {
        _burnwsedcTimeLabel.hidden = YES;
        _findChatViewHeight.constant = 0.0;
    }
}

- (NSMutableArray *)yzdoajBurnTimes {
    if (!_yzdoajBurnTimes) {
        _yzdoajBurnTimes = NSMutableArray.new;
        for (NSNumber *number in BURN_TIMES) {
            [_yzdoajBurnTimes addObject:[self tranfrom:number.integerValue]];
        }
    }return _yzdoajBurnTimes;
}

- (NSString *)tranfrom:(NSInteger)sec {
    NSString *value = @"";
    if (sec < 60) {
        value = [NSString stringWithFormat:@"%ld%@",sec, (_isChinese?@"秒":@"giây")];
    }else if (sec < 60*60) {
        value = [NSString stringWithFormat:@"%ld%@",sec/60, (_isChinese?@"分钟":@" phút")];
    }else if (sec < 24*3600) {
        value = [NSString stringWithFormat:@"%ld%@",sec/3600, (_isChinese?@"小时":@" giờ")];
    }else if (sec <= 30*24*3600) {
        value = [NSString stringWithFormat:@"%ld%@",sec/24/3600, (_isChinese?@"天":@" ngày")];
    }
    return value;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
