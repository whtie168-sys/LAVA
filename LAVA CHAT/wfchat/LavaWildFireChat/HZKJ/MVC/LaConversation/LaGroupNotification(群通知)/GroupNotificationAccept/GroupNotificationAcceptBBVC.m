//
//  GroupNotificationAcceptBBVC.m
//  WildFireChat
//
//  Created by Ruby on 12/26/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "GroupNotificationAcceptBBVC.h"

@interface GroupNotificationAcceptBBVC ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupasoucNameLabel;

@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet UILabel *acceptLabel;

@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;


@property (weak, nonatomic) IBOutlet UILabel *applyAddL;
@property (weak, nonatomic) IBOutlet UILabel *sourceL;
@property (weak, nonatomic) IBOutlet UILabel *idL;
@property (weak, nonatomic) IBOutlet UILabel *sexL;
@property (weak, nonatomic) IBOutlet UILabel *signL;

@end

@implementation GroupNotificationAcceptBBVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    _isChinese = [CommonHelper.main isChinese];
    
    _iconView.layer.cornerRadius = 40.0;
    _acceptView.layer.cornerRadius = 10.0;
    
    _acceptButton.layer.cornerRadius = 12.0;
    _rejectButton.layer.cornerRadius = 12.0;
    
    
    WFCCUserInfo *userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:_acceptList.requestUserId refresh:NO];
    [_iconView sd_setImageWithURL:URL(userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    _asoucNameLabel.text = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
    
    WFCCGroupInfo *groupInfo = [WFCCIMService.sharedWFCIMService getGroupInfo:_acceptList.groupId refresh:NO];
    _groupasoucNameLabel.text = (groupInfo.displayName.length > 0 ? groupInfo.displayName : groupInfo.remark);
    
    _acceptLabel.text = UNString(@"%@向你申请加入群", self.asoucNameLabel.text);
    
    if (_acceptList.source == GroupMemberSource_Unknown || _acceptList.source == GroupMemberSource_Search) {
        _sourceLabel.text = LLLLLL(@"Search");
    }else if (_acceptList.source == GroupMemberSource_Invite) {
        if (_acceptList.inviteUserId.length) {
            WFCCUserInfo *inviteInfo = [WFCCIMService.sharedWFCIMService getUserInfo:_acceptList.inviteUserId refresh:NO];
            // 如果为邀请 requestUser 是邀请人 checkUser是被邀请人
            _sourceLabel.text = [NSString stringWithFormat:@"%@ %@",(inviteInfo.friendAlias.length > 0 ? inviteInfo.friendAlias : inviteInfo.displayName), LLLLLL(@"Invite")];
        }else {
            _sourceLabel.text = LLLLLL(@"Invite");
        }
    }else if (_acceptList.source == GroupMemberSource_QrCode) {
        _sourceLabel.text = (_isChinese?@"二维码扫描":@"Quét mã qr");
    }else if (_acceptList.source == GroupMemberSource_Card) {
        _sourceLabel.text = (_isChinese?@"群名片":@"Nhóm thẻ kinh doanh");
    }
    _idLabel.text = userInfo.name;
    _sexLabel.text = (userInfo.gender == 2 ? LLLLLL(@"Male") : (userInfo.gender == 1 ? LLLLLL(@"Female") : LLLLLL(@"Other")));

    UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:userInfo.extra];
    _signLabel.text = extraInfo.sign.length ? extraInfo.sign : (_isChinese?@"对方什么都没有写":@"Đối phương không viêt gì");
    
    
    if (_isChinese) {
    }else {
        _acceptLabel.text = UNString(@"%@ yêu cầu tham gia nhóm", self.asoucNameLabel.text);
        
        _applyAddL.text = @"Áp dụng để gia nhập";
        _sourceL.text = @"Nguồn gốc";
    }
    _sexL.text = LLLLLL(@"Gender");
    _signL.text = LLLLLL(@"PersonalSignature");
    [_acceptButton setTitle:LLLLLL(@"Agree") forState:UIControlStateNormal];
    [_rejectButton setTitle:LLLLLL(@"Reject") forState:UIControlStateNormal];
}

- (IBAction)accept:(UIButton *)sender {
    [self statusAccept:1 sender:sender];
}

- (IBAction)reject:(UIButton *)sender {
    [self statusAccept:2 sender:sender];
}

- (void)statusAccept:(NSInteger)accept sender:(UIButton *)sender {
    WS(weakself)
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    NSDictionary *params = @{@"id":_acceptList.id, @"accept":@(accept)};
    sender.userInteractionEnabled = NO;
    [AppService.sharedAppService requestUrl:@"/group/accept" params:params success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.5 position:CSToastPositionCenter];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNotificationOperate object:nil userInfo:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself.navigationController popViewControllerAnimated:YES];
        });
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        sender.userInteractionEnabled = YES;
        [weakself.view makeToast:message duration:1.5 position:CSToastPositionCenter];
    }];
}

@end
