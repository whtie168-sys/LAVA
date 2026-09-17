//
//  LaGroupInfoQrVC.m
//  WildFireChat
//
//  Created by Ruby on 12/27/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaGroupInfoQrVC.h"

#import "LaMessageVC.h"


@interface LaGroupInfoQrVC ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIImageView *groupIconView;
@property (weak, nonatomic) IBOutlet UILabel *groupasoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *addGroupButton;


@property (nonatomic, strong) WFCCGroupInfo *groupInfo;
@property (nonatomic, strong) GroupExtraInfo *groupExtra;
@property (nonatomic, strong) NSArray<WFCCGroupMember *> *members;
@property (nonatomic, assign)BOOL isJoined;

@end

@implementation LaGroupInfoQrVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    
    _groupIconView.layer.cornerRadius = 50.0;
    _addGroupButton.layer.cornerRadius = 12.0;
    
    
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kGroupInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSArray<WFCCGroupInfo *> *groupInfoList = note.userInfo[@"groupInfoList"];
        for (WFCCGroupInfo *groupInfo in groupInfoList) {
            if ([ws.groupId isEqualToString:groupInfo.target]) {
                ws.groupInfo = groupInfo;
                break;
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kGroupMemberUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([ws.groupId isEqualToString:note.object]) {
            ws.members = [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.groupId forceUpdate:NO];
            [ws memberNum:ws.members.count];
        }
    }];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    self.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.groupId refresh:YES];
    self.members = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupId forceUpdate:YES];
}
- (void)onGroupInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCGroupInfo *> *groupInfoList = notification.userInfo[@"groupInfoList"];
    for (WFCCGroupInfo *groupInfo in groupInfoList) {
        if ([_groupId isEqualToString:groupInfo.target]) {
            self.groupInfo = groupInfo;
            break;
        }
    }
}

- (IBAction)addGroup:(UIButton *)sender {
    if (self.isJoined) {
        LaMessageVC *mvc = [[LaMessageVC alloc] init];
        mvc.conversation = [WFCCConversation conversationWithType:Group_Type target:self.groupId line:0];
        mvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mvc animated:YES];
    }else {
        if (self.groupExtra.needReview == 1) { // 进群需要审核
            WS(weakself)
            [AppService.sharedAppService requestUrl:@"/group/request" params:@{@"groupId":self.groupId, @"inviteUser":WFCCNetworkService.sharedInstance.userId, @"source":@(_sourceType)} success:^(NSDictionary * _Nonnull dict) {
                [self.view makeToast:(self->_isChinese?@"申请已发送, 请等待管理员审核":@"Yêu cầu đã được gửi đi, vui lòng đợi xét duyệt") duration:1.5 position:CSToastPositionCenter];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakself.navigationController popToRootViewControllerAnimated:YES];
                });
            } error:^(int errCode, NSString * _Nonnull message) {
                [self.view makeToast:(self->_isChinese?@"申请发送失败":@"Ứng dụng gửi thất bại") duration:1.5 position:CSToastPositionCenter];
            }];
        }else { // 进群不需要审核
            WS(weakself)
            [[WFCCIMService sharedWFCIMService] addMembers:@[WFCCNetworkService.sharedInstance.userId] toGroup:self.groupId memberExtra:nil notifyLines:@[@(0)] notifyContent:nil success:^{
                [[WFCCIMService sharedWFCIMService] getGroupMembers:weakself.groupId forceUpdate:YES];
                weakself.isJoined = YES;
                [weakself addGroup:nil];
            } error:^(int error_code) {
                [self.view makeToast:(self->_isChinese?@"无权操作...":@"Không có quyền hoạt động...")];
            }];
        }
    }
}


- (void)setGroupInfo:(WFCCGroupInfo *)groupInfo {
    _groupInfo = groupInfo;
    if (groupInfo) {
        self.groupExtra = [GroupExtraInfo mj_objectWithKeyValues:groupInfo.extra];
        
        [self.groupIconView sd_setImageWithURL:URL(groupInfo.portrait) placeholderImage:[QWERImage imageNamed:@"groupIcon"]];
        self.groupasoucNameLabel.text = (groupInfo.displayName.length > 0 ? groupInfo.displayName : groupInfo.remark);
        NSInteger memberCount = (groupInfo.memberCount <= 0 ? self.members.count : groupInfo.memberCount);
        [self memberNum:memberCount];
    }
}
- (void)memberNum:(NSInteger)memberCount {
    memberCount = (memberCount == 0 ? arc4random() % 3 + 1 : memberCount); // 0523 生成的随机的群成员数量
    if (_isChinese) {
        self.memberNumLabel.text = [NSString stringWithFormat:@"共%ld人",memberCount];
    }else {
        self.memberNumLabel.text = [NSString stringWithFormat:@"Tổng cộng %ld người",memberCount];
    }
}

- (void)setMembers:(NSArray<WFCCGroupMember *> *)members {
    _members = members;
    __block BOOL isContainMe = NO;
    [members enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            *stop = YES;
            isContainMe = YES;
        }
    }];
    self.isJoined = isContainMe;
}

- (void)setIsJoined:(BOOL)isJoined {
    _isJoined = isJoined;
    if (isJoined) {
        [self.addGroupButton setTitle:LLLLLL(@"StartChat") forState:UIControlStateNormal];
    }else {
        [self.addGroupButton setTitle:(_isChinese?@"加入群聊":@"Tham gia trò chuyện nhóm") forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
