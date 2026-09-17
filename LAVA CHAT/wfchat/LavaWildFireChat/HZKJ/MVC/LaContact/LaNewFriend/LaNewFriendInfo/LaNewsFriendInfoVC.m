//
//  LaNewsFriendInfoVC.m
//  LAVA
//
//  Created by Rubyuer on 10/22/23.
//

#import "LaNewsFriendInfoVC.h"

#import "LaMemberInfoVC.h"


@interface LaNewsFriendInfoVC ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIScrollView *eubnxowScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *eubnxowIconView;
@property (weak, nonatomic) IBOutlet UILabel *eubnxowtzboeuNameLabel;

@property (weak, nonatomic) IBOutlet UIView *eubnxowIdView;
@property (weak, nonatomic) IBOutlet UILabel *eubnxowIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *eubnxowWayLabel;

@property (weak, nonatomic) IBOutlet UILabel *eubnxowSexLabel;
@property (weak, nonatomic) IBOutlet UILabel *eubnxowSignLabel;

@property (weak, nonatomic) IBOutlet UIView *eubnxowBgView;
@property (weak, nonatomic) IBOutlet UILabel *eubnxowDescLabel;

@property (weak, nonatomic) IBOutlet UIButton *eubnxowOkButton;
@property (weak, nonatomic) IBOutlet UIButton *eubnxowBlacklistButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;



@property (weak, nonatomic) IBOutlet UILabel *sexL;
@property (weak, nonatomic) IBOutlet UILabel *signL;
@property (weak, nonatomic) IBOutlet UILabel *sysPromptL;

@end

@implementation LaNewsFriendInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    ViewRadius(_eubnxowIconView, 38.0);
    ViewRadius(_eubnxowIdView, 10.0);
    ViewRadius(_eubnxowBgView, 20.0)
    ViewRadius(_eubnxowOkButton, 16.0);
    ViewRadius(_eubnxowBlacklistButton, 16.0);
    
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:_request.target refresh:NO];
    UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:userInfo.extra];
    
    [self.eubnxowIconView sd_setImageWithURL:URL(userInfo.portrait) placeholderImage: [QWERImage imageNamed:@"PersonalChat"]];
    if (userInfo.friendAlias.length) {
        self.eubnxowtzboeuNameLabel.text = userInfo.friendAlias;
    } else if (userInfo.groupAlias.length) {
        self.eubnxowtzboeuNameLabel.text = userInfo.groupAlias;
    } else if(userInfo.displayName.length > 0) {
        self.eubnxowtzboeuNameLabel.text = userInfo.displayName;
    } else {
        self.eubnxowtzboeuNameLabel.text = [NSString stringWithFormat:@"Người dùng<%@>", userInfo.name.length > 0 ? userInfo.name : userInfo.userId];
    }
    _eubnxowIdLabel.text = userInfo.name;
    _eubnxowSexLabel.text = (userInfo.gender == 2 ? LLLLLL(@"Male") : (userInfo.gender == 1 ? LLLLLL(@"Female") : LLLLLL(@"Other")));
    
    _eubnxowSignLabel.text = (extraInfo.sign.length ? extraInfo.sign : (_isChinese?@"对方什么都没有写":@"Đối phương không viêt gì"));
    [_cancelButton setTitle:LLLLLL(@"Reject") forState:UIControlStateNormal];
    
    _eubnxowDescLabel.text = _request.reason;
    
    if (_isChinese) {
        
    }else {
        _eubnxowWayLabel.text = @"Thêm thông qua tìm kiếm";
        
        _sysPromptL.text = @"Hệ thống nhắc nhở: Gửi lời mời kết bạn";
    }
    _sexL.text = LLLLLL(@"Gender");
    _signL.text = LLLLLL(@"PersonalSignature");
    [_eubnxowOkButton setTitle:LLLLLL(@"Agree") forState:UIControlStateNormal];
    [_eubnxowBlacklistButton setTitle:LLLLLL(@"JoinTheBlacklist") forState:UIControlStateNormal];
}

/***
 
 WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:friendRequest.target refresh:NO];
 [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]  placeholderImage: [QWERImage imageNamed:@"PersonalChat"]];
 self.asoucNameLabel.text = userInfo.displayName;
 self.reasonLabel.text = friendRequest.reason;
 
 __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
 hud.label.text = WFCString(@"Updating");
 [hud showAnimated:YES];
 
 __weak typeof(self) ws = self;
 [[WFCCIMService sharedWFCIMService] handleFriendRequest:targetUserId accept:YES extra:nil success:^{
     dispatch_async(dispatch_get_main_queue(), ^{
         hud.hidden = YES;
         [ws.view makeToast:WFCString(@"UpdateDone") duration:2 position:CSToastPositionCenter];
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [[WFCCIMService sharedWFCIMService] loadFriendRequestFromRemote];
             dispatch_async(dispatch_get_main_queue(), ^{
                 ws.dataList   = [[WFCCIMService sharedWFCIMService] getIncommingFriendRequest];
                 for (WFCCFriendRequest *request in ws.dataList) {
                     if ([request.target isEqualToString:targetUserId]) {
                         request.status = 1;
                         break;
                     }
                 }
                 [ws.tableView reloadData];
             });
         });
     });
 } error:^(int error_code) {
     dispatch_async(dispatch_get_main_queue(), ^{
         hud.hidden = YES;
         if(error_code == 19) {
             [ws.view makeToast:WFCString(@"Expired") duration:2 position:CSToastPositionCenter];
         } else {
             [ws.view makeToast:WFCString(@"UpdateFailure") duration:2 position:CSToastPositionCenter];
         }
     });
 }];
 
 */
- (IBAction)eubnxowOk:(UIButton *)sender {
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    WS(weakself)
    [[WFCCIMService sharedWFCIMService] handleFriendRequest:_request.target accept:YES extra:nil success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = YES;
            [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];
            
            LaMemberInfoVC *vc = LaMemberInfoVC.new;
            vc.hidesBottomBarWhenPushed = YES;
            vc.userId = weakself.request.target;
            
            NSMutableArray* navArray = [[NSMutableArray alloc] initWithArray:weakself.navigationController.viewControllers];
            [navArray replaceObjectAtIndex:1 withObject:vc];
            [weakself.navigationController setViewControllers:navArray animated:YES];

            [weakself.navigationController popViewControllerAnimated:YES];
            
            [[WFCCIMService sharedWFCIMService] loadFriendRequestFromRemote];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            });
        });
    } error:^(int error_code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = YES;
            if(error_code == 19) {
                [weakself.view makeToast:LLLLLL(@"Expired") duration:2 position:CSToastPositionCenter];
            } else {
                [weakself.view makeToast:LLLLLL(@"LoadFailure") duration:2 position:CSToastPositionCenter];
            }
        });
    }];
}

- (IBAction)eubnxowBlacklist:(UIButton *)sender {
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    WS(weakself)
    [[WFCCIMService sharedWFCIMService] setBlackList:_request.target isBlackListed:YES success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = YES;
            [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:2.0 position:CSToastPositionCenter];
            if (weakself.successBlock) {
                weakself.successBlock();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popViewControllerAnimated:YES];
            });
        });
    } error:^(int error_code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = YES;

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = LLLLLL(@"LoadFailure");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    }];
}

- (IBAction)cancelA:(UIButton *)sender {
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    WS(weakself)
    [[WFCCIMService sharedWFCIMService] handleFriendRequest:_request.target accept:NO extra:nil success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = YES;
            [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:2.0 position:CSToastPositionCenter];
            if (weakself.successBlock) {
                weakself.successBlock();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popViewControllerAnimated:YES];
            });
        });
    } error:^(int error_code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = YES;
            if(error_code == 19) {
                [weakself.view makeToast:LLLLLL(@"Expired") duration:2 position:CSToastPositionCenter];
            } else {
                [weakself.view makeToast:LLLLLL(@"LoadFailure") duration:2 position:CSToastPositionCenter];
            }
        });
    }];
}


@end
