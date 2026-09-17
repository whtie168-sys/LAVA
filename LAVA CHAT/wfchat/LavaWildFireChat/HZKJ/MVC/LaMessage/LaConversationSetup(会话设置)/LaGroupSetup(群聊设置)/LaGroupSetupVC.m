//
//  LaGroupSetupVC.m
//  WildFireChat
//
//  Created by Ruby on 12/11/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaGroupSetupVC.h"
#import "LaGroupIconCVCell.h"

#import "LaGroupAnnouncementVC.h"
#import "LaGroupManagerVC.h"
#import "LaTextModifyVC.h"
#import "LaContactsVC.h"
#import "LaMemberInfoVC.h"
#import "LaGroupIconVC.h"
#import "LaComplaintVC.h"
#import "LaFriendInfoVC.h"
#import "LaConversationSearchVC.h"
#import "LaGroupMemberVC.h"

@interface LaGroupSetupVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupMemberCollectionViewHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *groupMemberCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *groupMemberLayout;
@property (nonatomic, strong) NSMutableArray<WFCCGroupMember *> *memberList;
@property (nonatomic, assign) NSInteger memberCollectionCount;
@property (nonatomic, assign) NSInteger extraBtnNumber;

@property (weak, nonatomic) IBOutlet UILabel *groupasoucNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *groupIconView;
@property (weak, nonatomic) IBOutlet UILabel *groupMemberNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *groupIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupAnnouncementLabel;

@property (weak, nonatomic) IBOutlet UILabel *groupNickasoucNameLabel;

@property (weak, nonatomic) IBOutlet UISwitch *topChatSW;
@property (weak, nonatomic) IBOutlet UISwitch *noDisturbingSW;
@property (weak, nonatomic) IBOutlet UISwitch *saveBookSW;

@property (weak, nonatomic) IBOutlet UIView *groupManagerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *findChatHistoryTop;

@property (weak, nonatomic) IBOutlet UIView *disbandView;
@property (weak, nonatomic) IBOutlet UILabel *disbandLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *disbandViewBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gonggaoHeight;
@property (weak, nonatomic) IBOutlet UIView *gonggaoView;

@property (nonatomic, strong) WFCCGroupInfo *groupInfo;


@property (weak, nonatomic) IBOutlet UILabel *groupMemberL;
@property (weak, nonatomic) IBOutlet UILabel *groupIdL;
@property (weak, nonatomic) IBOutlet UILabel *groupQrL;
@property (weak, nonatomic) IBOutlet UILabel *groupAnnouncementL;
@property (weak, nonatomic) IBOutlet UILabel *groupManagerL;
@property (weak, nonatomic) IBOutlet UILabel *chatContentL;
@property (weak, nonatomic) IBOutlet UILabel *groupNicknameL;
@property (weak, nonatomic) IBOutlet UILabel *topChatL;
@property (weak, nonatomic) IBOutlet UILabel *noDisturbingL;
@property (weak, nonatomic) IBOutlet UILabel *saveBookL;
@property (weak, nonatomic) IBOutlet UILabel *complaintL;

@property (weak, nonatomic) IBOutlet UILabel *clearChatL;
@property (weak, nonatomic) IBOutlet UILabel *deleteExitL;
@property (weak, nonatomic) IBOutlet UILabel *disbandL;
@end

@implementation LaGroupSetupVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:_conversation.target refresh:NO];
//    NSLog(@"groupInfo====%@",_groupInfo.mj_JSONObject);
    
    [_memberList removeAllObjects];
    NSArray *datas = [[WFCCIMService sharedWFCIMService] getGroupMembers:_conversation.target forceUpdate:NO];
    for (WFCCGroupMember *member in datas) {
        if (member.type == Member_Type_Owner) {
            [_memberList addObject:member];
            break;
        }
    }
    for (WFCCGroupMember *member in datas) {
        if (member.type == Member_Type_Manager) {
            [_memberList addObject:member];
        }
    }
    for (WFCCGroupMember *member in datas) {
        if (member.type != Member_Type_Owner && member.type != Member_Type_Manager) {
            [_memberList addObject:member];
        }
    }

    [self setupMemberCollectionView];
    [self.groupMemberCollectionView reloadData];
    
    [self initUiData];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(groupAnnouncementUpdate:) name:kGroup_Announcement_Update object:nil];
}
- (void)groupAnnouncementUpdate:(NSNotification *)noti {
    _groupAnnouncement = noti.object;
    _groupAnnouncementLabel.text = _groupAnnouncement.text;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"ConversationDetail");
    _isChinese = [CommonHelper.main isChinese];
    
    _groupIconView.layer.cornerRadius = 20.0;
    _groupAnnouncementLabel.text = @"";
    
    _memberList = NSMutableArray.new;
    _groupMemberLayout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    _groupMemberLayout.itemSize = CGSizeMake((WIDTH - 20.0)/5.0, 85.0);
    _groupMemberLayout.minimumInteritemSpacing = 0.0;
    _groupMemberLayout.minimumLineSpacing = 0.0;
    _groupMemberCollectionView.delegate = self;
    _groupMemberCollectionView.dataSource = self;
    [_groupMemberCollectionView registerNib:[UINib nibWithNibName:@"LaGroupIconCVCell" bundle:nil] forCellWithReuseIdentifier:@"LaGroupIconCVCell"];
    
    [[WFCCIMService sharedWFCIMService] getGroupInfo:_conversation.target refresh:YES];
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kGroupMemberUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([ws.conversation.target isEqualToString:note.object]) {
            ws.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:ws.conversation.target refresh:NO];
            ws.memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.conversation.target forceUpdate:NO].mutableCopy;
            [ws setupMemberCollectionView];
            [ws.groupMemberCollectionView reloadData];
        }
    }];

    _groupAnnouncementLabel.text = _groupAnnouncement.text;
    if (arc4random() % 3 == 0) {
        [AppService.sharedAppService getGroupAnnouncement:_conversation.target success:^(TREWQGroupAnnouncement * announcement) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.groupAnnouncement = announcement;
                ws.groupAnnouncementLabel.text = announcement.text;
            });
        } error:^(int error_code) {
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessages:) name:kReceiveMessages object:nil];
    
    if (_isChinese) {
    }else {
        _groupMemberL.text = @"Thành viên";
        _groupIdL.text = @"ID nhóm";
        _groupQrL.text = @"Mã QR nhóm";
        _groupAnnouncementL.text = @"Thông báo";
        _groupManagerL.text = @"Quản lý nhóm";
        _chatContentL.text = @"Tìm kiếm nội dung trò chuyện";
        _groupNicknameL.text = @"Biệt danh trong nhóm của tôi";
        _topChatL.text = @"Ghim trò chuyện";
        _noDisturbingL.text = @"Không làm phiền";
        _saveBookL.text = @"Lưu vào danh bạ";
        
        _deleteExitL.text = @"Xóa và thoát";
        _disbandL.text = @"Xóa nhóm";
    }
    _complaintL.text = LLLLLL(@"Complain");
    _clearChatL.text = LLLLLL(@"ClearChatHistory");
}

- (void)setupMemberCollectionView {
    if (_groupInfo.type == GroupType_Organization) {
        _extraBtnNumber = 0;
    } else if ([self isGroupManager]) {
        _extraBtnNumber = 2;
    } else if(_groupInfo.type == GroupType_Restricted) {
        if (_groupInfo.joinType == 1 || _groupInfo.joinType == 0) {
            _extraBtnNumber = 1;
        }else {
            _extraBtnNumber = 0;
        }
    }else {
        _extraBtnNumber = 1;
    }
    _memberCollectionCount = _memberList.count + _extraBtnNumber;
    
    _memberCollectionCount = MIN(15, _memberCollectionCount);
    
    _groupMemberCollectionViewHeight.constant = (_memberCollectionCount + 4)/5 * 85.0;
}

- (void)onReceiveMessages:(NSNotification *)notification {
    if (self.conversation.type == Group_Type) {
        NSArray<WFCCMessage *> *messages = notification.object;
        __block BOOL reload = NO;
        [messages enumerateObjectsUsingBlock:^(WFCCMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.content isKindOfClass:WFCCGroupSettingsNotificationContent.class]) {
                WFCCGroupSettingsNotificationContent *notiContent = (WFCCGroupSettingsNotificationContent *)obj.content;
                if([notiContent.groupId isEqualToString:self.conversation.target]) {
                    reload = YES;
                    *stop = YES;
                }
            }else if ([obj.content isKindOfClass:WFCCGroupSetManagerNotificationContent.class]) { // 设置/取消群管理员通知消息 1213新增
                reload = YES;
            }
        }];
        if(reload) {
            __weak typeof(self)ws = self;
            ws.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:ws.conversation.target refresh:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws initUiData];
            });
        }
    }
}

- (void)initUiData {
    _groupasoucNameLabel.text = (_groupInfo.displayName.length > 0 ? _groupInfo.displayName : _groupInfo.remark);
    [_groupIconView sd_setImageWithURL:URL(_groupInfo.portrait) placeholderImage:IMAGENAME(@"groupIcon")];
    if (_isChinese) {
        _groupMemberNumLabel.text = UNString(@"共%ld人", _memberList.count);
    }else {
        _groupMemberNumLabel.text = UNString(@"Tổng số %ld người", _memberList.count);
    }
    
    _groupIDLabel.text = _groupInfo.target;
    _groupAnnouncementLabel.text = _groupAnnouncement.text;
    
    WFCCGroupMember *groupMember = [[WFCCIMService sharedWFCIMService] getGroupMember:_conversation.target memberId:WFCCNetworkService.sharedInstance.userId];
    _groupNickasoucNameLabel.text = (groupMember.alias.length > 0 ? groupMember.alias : LLLLLL(@"NotSet"));
    
    WFCCConversationInfo *conversationInfo = [WFCCIMService.sharedWFCIMService getConversationInfo:_conversation];
    _topChatSW.on = conversationInfo.isTop;
    _noDisturbingSW.on = conversationInfo.isSilent;
    _saveBookSW.on = [WFCCIMService.sharedWFCIMService isFavGroup:_conversation.target];
    
    if ([self isGroupManager] && _groupInfo.type == GroupType_Restricted) { // 带有群管理
        _groupManagerView.hidden = NO;
        _findChatHistoryTop.constant = 60.0;
    }else {
        _groupManagerView.hidden = YES;
        _findChatHistoryTop.constant = 0.0;
        _gonggaoView.hidden = YES;
        _gonggaoHeight.constant = 0.0;
    }
    
    if ([self isGroupOwner]) { // 我是群主
        _disbandView.hidden = NO;
        _disbandViewBottom.constant = 52.0;
    }else {
        _disbandView.hidden = YES;
        _disbandViewBottom.constant = 2.0;
    }
}


#pragma mark - Btn action event

- (IBAction)groupIcon:(UIButton *)sender { // 群聊name 和 icon
    if (self.groupInfo.type == GroupType_Restricted && ![self isGroupManager]) {
        [self.view makeToast:(_isChinese?@"只有管理员才可以修改群头像和昵称":@"Chỉ quản trị viên mới có thể thay đổi avatar nhóm và nickname") duration:1 position:CSToastPositionCenter];
        return;
    }
    if (![[self getMyself].modifyGroupInfo isEqualToString:@"1"]) {
        [self.view makeToast:LLLLLL(@"GroupAccessManagerInsufficientPermissions") duration:1 position:CSToastPositionCenter];
        return;
    }
    LaGroupIconVC *vc = LaGroupIconVC.new;
    vc.conversation = _conversation;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)groupMember:(UIButton *)sender { // 群成员
//    ASCEDGroupMemberCollectionVC *vc = [[ASCEDGroupMemberCollectionVC alloc] init];
//    vc.groupId = self.groupInfo.target;
//    vc.navigationItem.title = @"群成员";
//    [self.navigationController pushViewController:vc animated:YES];
    LaGroupMemberVC *vc = LaGroupMemberVC.new;
    vc.groupId = self.groupInfo.target;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)copyGroupID:(UIButton *)sender {
    if (_groupInfo.target.length <= 0) {
        return;
    }
    UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;
    pasteboard.string = _groupInfo.target;
    
    [SVProgressHUD showSuccessWithStatus:LLLLLL(@"CopySuccessfully")];
    [SVProgressHUD dismissWithDelay:1.0];
}

- (IBAction)groupQr:(UIButton *)sender { // 群二维码
    if (gQrCodeDelegate) {
        [gQrCodeDelegate showQrCodeViewController:self.navigationController type:QRType_Group target:self.groupInfo.target];
    }
}

- (IBAction)groupAnnouncement:(UIButton *)sender { // 群公告
    __block BOOL isManager = false;
    [self.memberList enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.memberId isEqualToString:self.groupAnnouncement.author]) {
            if (obj.type == Member_Type_Manager) {
                isManager = YES;
            }
            *stop = YES;
        }
    }];
    
    LaGroupAnnouncementVC *vc = [[LaGroupAnnouncementVC alloc] init];
    vc.isCanPost = YES;
    vc.announcement = self.groupAnnouncement;
    vc.groupId = _groupInfo.target;
    if ([_groupInfo.owner isEqualToString:self.groupAnnouncement.author]) {
        vc.type = Member_Type_Owner;
    }
    if (isManager) { // isManager 就只属于管理员、不包括群主
        vc.type = Member_Type_Manager;
    }
    WS(weakself)
    [vc setDeleteAnnouncementBlock:^{
        weakself.groupAnnouncementLabel.text = @"";
        weakself.groupAnnouncement.text = @"";
    }];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)groupManager:(UIButton *)sender { // 群管理
    LaGroupManagerVC *vc = LaGroupManagerVC.new;
    vc.groupInfo = self.groupInfo;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)findChatHistory:(UIButton *)sender { // 查找聊天记录
    LaConversationSearchVC *mvc = LaConversationSearchVC.new;
    mvc.conversation = self.conversation;
    mvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mvc animated:YES];
}


- (IBAction)groupNickname:(UIButton *)sender { // 我在本群的昵称
    LaTextModifyVC *vc = LaTextModifyVC.new;
    vc.modifyType = 101;
    vc.groupId = _conversation.target;
    if ([_groupNickasoucNameLabel.text isEqualToString:LLLLLL(@"NotSet")]) {
        vc.defaultValue = @"";
    }else {
        vc.defaultValue = _groupNickasoucNameLabel.text;
    }
    WS(weakself)
    [vc setOnModified:^(NSString * _Nonnull value) {
        weakself.groupNickasoucNameLabel.text = value;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

//获取自己的权限
- (WFCCGroupMember *)getMyself {
    for (WFCCGroupMember *obj in self.memberList) {
        if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            WFCCGroupMember *mem = [WFCCGroupMember mj_objectWithKeyValues:obj.extra];
            obj.controlOther = mem.controlOther;
            obj.modifyGroupInfo = mem.modifyGroupInfo;
            obj.pushNotice = mem.pushNotice;
            obj.renewRequest = mem.renewRequest;
            return obj;
        }
    }
    return nil;
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

- (IBAction)saveBookSw:(UISwitch *)sender { // 保存到通讯录
    [[WFCCIMService sharedWFCIMService] setFavGroup:_conversation.target fav:sender.on success:^{
//        sender.on = !sender.on;
    } error:^(int error_code) {

    }];
}



- (IBAction)complaint:(UIButton *)sender { // 投诉
    LaComplaintVC *vc = LaComplaintVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)clearAllChatRecord:(UIButton *)sender { // 清空聊天记录
    WS(weakself)
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"ConfirmDelete") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    UIAlertAction *actionLocalDelete = [UIAlertAction actionWithTitle:LLLLLL(@"DeleteLocalMsg") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

- (IBAction)deleteAndQuit:(UIButton *)sender { // 删除并退出
    WS(weakself)
    if ([self isGroupOwner]) {
        UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"Tips") message:(_isChinese?@"您是群主，退出群聊且删除此群的聊天记录前需要先转让群聊":@"Bạn là chủ nhóm, trước khi thoát khỏi cuộc trò chuyện nhóm và xóa lịch sử trò chuyện của nhóm này cần chuyển nhượng cuộc trò chuyện nhóm") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *okAct = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself transferOfGroupChat];
        }];
        [actionSheet addAction:cancelAct];
        [actionSheet addAction:okAct];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }else {
        UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:(_isChinese?@"是否退出群聊?":@"Thoát khỏi group chat?") message:(_isChinese?@"确认要退出群聊，且删除此群的聊天记录？":@"Xác nhận rằng bạn muốn thoát khỏi cuộc trò chuyện nhóm và xóa lịch sử trò chuyện của nhóm này?") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *okAct = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[WFCCIMService sharedWFCIMService] quitGroup:weakself.conversation.target notifyLines:@[@(0)] notifyContent:nil success:^{
                [weakself.navigationController popToRootViewControllerAnimated:YES];
            } error:^(int error_code) {
                
            }];
        }];
        [actionSheet addAction:cancelAct];
        [actionSheet addAction:okAct];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}
// 转让群聊
- (IBAction)transferOfGroupChat {
    LaContactsVC *pvc = [[LaContactsVC alloc] init];
    pvc.selectContact = YES;
    pvc.multiSelect = NO;
    WS(weakself)
    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (contacts.count) {
                [weakself transferGroup:contacts.firstObject];
            }
        });
    };
    NSMutableArray *candidateUsers = [[NSMutableArray alloc] init];
    NSArray *memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:NO];
    for (WFCCGroupMember *member in memberList) {
        if (![member.memberId isEqualToString:self.groupInfo.owner]) {
            [candidateUsers addObject:member.memberId];
        }
    }
    pvc.candidateUsers = candidateUsers;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

- (void)transferGroup:(NSString *)newOwner {
    WFCCUserInfo *userinfo = [WFCCIMService.sharedWFCIMService getUserInfo:newOwner refresh:NO];
    NSString *name = (userinfo.friendAlias.length > 0 ? userinfo.friendAlias : (userinfo.groupAlias.length > 0 ? userinfo.groupAlias : userinfo.displayName));
    
    NSString *message = @"";
    if (_isChinese) {
        message = UNString(@"\n转让群聊后将自动成为普通成员，失去所有群主权利，%@成为新群主", name);
    }else {
        message = UNString(@"\nSau khi chuyển nhóm chat sẽ tự động trở thành thành viên bình thường, mất đi tất cả quyền lợi của chủ nhóm, %@ trở thành chủ nhóm mới.", name);
    }
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"Tips") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAct = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [WFCCIMService.sharedWFCIMService transferGroup:self.groupInfo.target to:newOwner notifyLines:@[@(0)] notifyContent:nil success:^{
            [self.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];
        } error:^(int error_code) {
        }];
    }];
    [actionSheet addAction:cancelAct];
    [actionSheet addAction:okAct];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)disbandGroupChat:(UIButton *)sender { // 解散群聊
    __weak typeof(self) ws = self;
    if ([self isGroupOwner]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:(_isChinese?@"请确认是否解散群组?":@"Vui lòng xác nhận xem nhóm có bị giải tán không?") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
        UIAlertAction *actionDismiss = [UIAlertAction actionWithTitle:(_isChinese?@"解散":@"Xóa") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[WFCCIMService sharedWFCIMService] removeConversation:self.conversation clearMessage:YES];
            [[WFCCIMService sharedWFCIMService] dismissGroup:self.conversation.target notifyLines:@[@(0)] notifyContent:nil success:^{
                [ws.navigationController popToRootViewControllerAnimated:YES];
            } error:^(int error_code) {
            }];
        }];
        [alert addAction:actionCancel];
        [alert addAction:actionDismiss];
        [self presentViewController:alert animated:YES completion:nil];
    }
}




#pragma mark - 公共方法

- (BOOL)isGroupOwner {
    if (self.conversation.type != Group_Type) {
        return NO;
    }
    return [self.groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId];
}

- (BOOL)isGroupManager {
    if (self.conversation.type != Group_Type) {
        return NO;
    }
    if ([self isGroupOwner]) {
        return YES;
    }
    __block BOOL isManager = false;
    [self.memberList enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            if (obj.type == Member_Type_Manager || obj.type == Member_Type_Owner) {
                isManager = YES;
            }
            *stop = YES;
        }
    }];
    return isManager;
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _memberCollectionCount;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LaGroupIconCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LaGroupIconCVCell" forIndexPath:indexPath];
    if (indexPath.row < (self.memberCollectionCount - self.extraBtnNumber)) {
        cell.member = self.memberList[indexPath.row];
        cell.asoucNameLabel.hidden = NO;
    }else {
        cell.asoucNameLabel.hidden = YES;
        if (indexPath.row == (self.memberCollectionCount - self.extraBtnNumber)) {
            cell.iconView.image = IMAGENAME(@"coaeisgoxAdd");
        }else {
            cell.iconView.image = IMAGENAME(@"coaeisgoxSub");
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == (self.memberCollectionCount - self.extraBtnNumber)) { // 添加群成员。
        __weak typeof(self)ws = self;
        FRSDASeletedUserVC *pvc = [[FRSDASeletedUserVC alloc] init];
        pvc.disabledUserNotSelected = YES;
        pvc.type = Horizontal;
        NSMutableArray *disabledUser = [[NSMutableArray alloc] init];
        for (WFCCGroupMember *member in [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:NO]) {
            [disabledUser addObject:member.memberId];
        }
        [pvc setSelectResult:^(NSArray<NSString *> * _Nonnull contacts) {
            /**  添加新成员  分为2类
             *   1、用户进群不需要验证 -> 直接拉入进群
             *   2、个别用户进群需要验证 -> 发送入群验证消息
             */
            
            NSString *userStr = @"";
            // 入群需要验证的用户
            NSMutableArray *needReviews = NSMutableArray.new;
            NSMutableArray *noneeds = NSMutableArray.new;
            NSArray<WFCCUserInfo *> *users = [WFCCIMService.sharedWFCIMService getUserInfos:contacts inGroup:self.groupInfo.target];
            for (WFCCUserInfo *userInfo in users) {
                if ([UserExtraInfo mj_objectWithKeyValues:userInfo.extra].disableJoinToGroup == 1) { // 邀请我加入群聊是否需要验证
                    [needReviews addObject:userInfo.userId];
                    if (userStr.length >= 25) {
                        continue;
                    }
                    NSString *name = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
                    if (userStr.length <= 0) {
                        userStr = name;
                    }else {
                        userStr = [NSString stringWithFormat:@"%@, %@",userStr, name];
                    }
                }else {
                    [noneeds addObject:userInfo.userId];
                }
            }
            
            if (noneeds.count > 0) {
                // 如果有入群不需要验证的用户。 判断当前用户是否是群主，如果是群主，直接拉进群、否则发送入群审核通知
                GroupExtraInfo *groupExtra = [GroupExtraInfo mj_objectWithKeyValues:ws.groupInfo.extra];
                if ([ws isGroupOwner] || groupExtra.needReview == 0) {
                    [[WFCCIMService sharedWFCIMService] addMembers:noneeds toGroup:ws.conversation.target memberExtra:nil notifyLines:@[@(0)] notifyContent:nil success:^{
                        [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.conversation.target forceUpdate:YES];
                    } error:^(int error_code) {
                        if (error_code == ERROR_CODE_GROUP_EXCEED_MAX_MEMBER_COUNT) {
                            [ws.view makeToast:(self->_isChinese?@"群成员数超过最大限制":@"Số lượng thành viên vượt quá giới hạn tối đa") duration:1 position:CSToastPositionCenter];
                        } else {
                            [ws.view makeToast:LLLLLL(@"NetworkError") duration:1 position:CSToastPositionCenter];
                        }
                    }];
                }else {
                    WS(weakself)
                   [AppService.sharedAppService requestUrl:@"/group/invite" params:@{@"groupId":ws.conversation.target, @"inviteUsers":noneeds, @"source":@(2)} success:^(NSDictionary * _Nonnull dict) {
                       UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(self->_isChinese?@"请求已发送":@"Yêu cầu đã được gửi") message:(_isChinese?@"该群开启了入群需审核，等待群主审核":@"Nhóm này mở ra nhập nhóm cần xét duyệt, chờ nhóm chủ xét duyệt.") preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                       }];
                       [alertController addAction:cancelAction];
                       [self presentViewController:alertController animated:YES completion:nil];
                    } error:^(int errCode, NSString * _Nonnull message) {
                        [weakself.view makeToast:(self->_isChinese?@"邀请加入群组请求失败":@"Lời mời tham gia nhóm Yêu cầu không thành công") duration:2 position:CSToastPositionCenter];
                    }];
                }
            }
            
            if (needReviews.count > 0) { // 如果有入群需要验证的用户。发验证消息
                
                WS(weakself)
               [AppService.sharedAppService requestUrl:@"/group/invite" params:@{@"groupId":ws.conversation.target, @"inviteUsers":needReviews, @"source":@(2)} success:^(NSDictionary * _Nonnull dict) {
                   NSString *message = @"";
                   if (self->_isChinese) {
                       message = UNString(@"%@等开启了入群需审核，对方同意后才会进入群聊", userStr);
                   }else {
                       message = UNString(@"%@ mở yêu cầu xét duyệt để vào nhóm. Sau khi đối phương đồng ý, mới có thể vào nhóm chat.", userStr);
                   }
                   UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(self->_isChinese?@"请求已发送":@"Yêu cầu đã được gửi") message:message preferredStyle:UIAlertControllerStyleAlert];
                   UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                   }];
                   [alertController addAction:cancelAction];
                   [self presentViewController:alertController animated:YES completion:nil];
                } error:^(int errCode, NSString * _Nonnull message) {
                    [weakself.view makeToast:(self->_isChinese?@"邀请加入群组请求失败":@"Lời mời tham gia nhóm Yêu cầu không thành công") duration:2 position:CSToastPositionCenter];
                }];
                
            }
        }];
        pvc.disableUserIds = disabledUser;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        navi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:navi animated:YES completion:nil];
        
    }else if (indexPath.row == self.memberCollectionCount-self.extraBtnNumber + 1) { // 删除群成员
        
        LaContactsVC *pvc = [[LaContactsVC alloc] init];
        pvc.selectContact = YES;
        pvc.multiSelect = YES;
        __weak typeof(self) ws = self;
        pvc.selectResult = ^(NSArray<NSString *> *contacts) { // 踢出群成员
            [[WFCCIMService sharedWFCIMService] kickoffMembers:contacts fromGroup:self.conversation.target notifyLines:@[@(0)] notifyContent:nil success:^{
                [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.conversation.target forceUpdate:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *tmpArray = [ws.memberList mutableCopy];
                    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
                    [tmpArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        WFCCGroupMember *member = obj;
                        if([contacts containsObject:member.memberId]) {
                            [removeArray addObject:member];
                        }
                    }];
                    [tmpArray removeObjectsInArray:removeArray];
                    ws.memberList = [tmpArray mutableCopy];
                    [ws setupMemberCollectionView];
                    [ws.groupMemberCollectionView reloadData];
                });
            } error:^(int error_code) {
            }];
        };
        NSMutableArray *candidateUsers = [[NSMutableArray alloc] init];
        NSMutableArray *disableUsers = [[NSMutableArray alloc] init];
        BOOL isOwner = [self isGroupOwner];
        
        for (WFCCGroupMember *member in [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:NO]) {
            [candidateUsers addObject:member.memberId];
            if (!isOwner && (member.type == Member_Type_Manager || [self.groupInfo.owner isEqualToString:member.memberId])) {
                [disableUsers addObject:member.memberId];
            }
        }
        [disableUsers addObject:[WFCCNetworkService sharedInstance].userId];
        pvc.candidateUsers = candidateUsers;
        pvc.disableUsers = [disableUsers copy];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    }else {
        WFCCGroupMember *member = [self.memberList objectAtIndex:indexPath.row];
        NSString *userId = member.memberId;
          
        if (self.groupInfo.privateChat) {
            if (![self.groupInfo.owner isEqualToString:userId] && ![self.groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
                WFCCGroupMember *gm = [[WFCCIMService sharedWFCIMService] getGroupMember:self.conversation.target memberId:[WFCCNetworkService sharedInstance].userId];
                if (gm.type != Member_Type_Manager) {
                    WFCCGroupMember *gm = [[WFCCIMService sharedWFCIMService] getGroupMember:self.conversation.target memberId:userId];
                    if (gm.type != Member_Type_Manager) {
                        [self.view makeToast:(self->_isChinese?@"管理员关闭了群组私聊权限":@"Quản trị viên tắt quyền trò chuyện nhóm") duration:1 position:CSToastPositionCenter];
                        return;
                    }
                }
            }
        }
        
        
//        BOOL isIam = [userId isEqualToString:WFCCNetworkService.sharedInstance.userId];
        BOOL isMyFriend = [WFCCIMService.sharedWFCIMService isMyFriend:userId]; // 本人与本人不是好友关系
        BOOL isBlackList = [WFCCIMService.sharedWFCIMService isBlackListed:userId];
        if (isMyFriend && !isBlackList) { // 是好友关系
            LaMemberInfoVC *vc = LaMemberInfoVC.new;
            vc.userId = userId;
            vc.groupId = _conversation.target;
//            vc.isManager = [self isGroupManager];
            [self.navigationController pushViewController:vc animated:YES];
        }else { // 本人或者 非好友关系
            LaFriendInfoVC *vc = LaFriendInfoVC.new;
            vc.userId = userId;
            vc.groupId = _conversation.target;
//            vc.isManager = [self isGroupManager];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
