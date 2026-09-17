//
//  LaNoticeVC.m
//  WildFireChat
//
//  Created by Ruby on 1/30/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaNoticeVC.h"
#import "LaSystemNotiVC.h"

@interface LaNoticeVC ()

@property (weak, nonatomic) IBOutlet UISwitch *newsMessageSW;
@property (weak, nonatomic) IBOutlet UISwitch *voiceVideoSW;
@property (weak, nonatomic) IBOutlet UISwitch *senderSW;

@property (weak, nonatomic) IBOutlet UISwitch *noDisturbSW;
@property (weak, nonatomic) IBOutlet UIView *noDisturbwsedcTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noDisturbTimeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveDraftTop;
@property (weak, nonatomic) IBOutlet UISwitch *saveDraftSW;

@property (weak, nonatomic) IBOutlet UISwitch *soundSW;
@property (weak, nonatomic) IBOutlet UISwitch *vibrationSW;


@property(nonatomic, assign) BOOL isNoDisturb;
@property(nonatomic, assign) NSInteger startMins;
@property(nonatomic, assign) NSInteger endMins;


@property (weak, nonatomic) IBOutlet UILabel *unOpenL;
@property (weak, nonatomic) IBOutlet UILabel *noticeAL;
@property (weak, nonatomic) IBOutlet UILabel *noticeBL;
@property (weak, nonatomic) IBOutlet UILabel *noticeCL;
@property (weak, nonatomic) IBOutlet UILabel *noticeDL;
@property (weak, nonatomic) IBOutlet UILabel *noticeEL;
@property (weak, nonatomic) IBOutlet UILabel *noticeFL;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoSystemNotiL;

@property (weak, nonatomic) IBOutlet UILabel *openL;
@property (weak, nonatomic) IBOutlet UILabel *noticeGFL;
@property (weak, nonatomic) IBOutlet UILabel *noticeHL;

@end

@implementation LaNoticeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"NotificationSetting");
    if ([CommonHelper.main isChinese]) {
        
    }else {
        _unOpenL.text = @"    Ứng dụng khi chưa mở";
        _openL.text = @"    Khi ứng dụng được bật";
        
        _noticeAL.text = @"Thông báo mới";
        _noticeBL.text = @"Lời nhắc mời cuộc gọi thoại và video";
        _noticeCL.text = @"Ẩn thông tin người gửi";
        _noticeDL.text = @"Không làm phiền";
        _noticeEL.text = @"Thời gian im lặng";
        _noticeFL.text = @"Lưu bản nháp";
        
        _noticeGFL.text = @"Âm thanh";
        _noticeHL.text = @"Rung";
        
        _ceoxsoSystemNotiL.text = @"Hệ thống thông báo";
    }
    
    // 是否全局静音   YES，当前用户全局静音；NO，没有全局静音
    _newsMessageSW.on = ![[WFCCIMService sharedWFCIMService] isGlobalSilent];
    // 是否实时音视频通知面打扰。服务器端2021.9.20后支持分别设置通知免打扰和实时音视频免打扰  YES，当前用户音视频不通知；NO，当前用户音视频通知
    _voiceVideoSW.on = ![[WFCCIMService sharedWFCIMService] isVoipNotificationSilent];
    // 是否隐藏推送详情    YES，隐藏推送详情，提示“您收到一条消息”；NO，推送显示消息摘要
    _senderSW.on = [[WFCCIMService sharedWFCIMService] isHiddenNotificationDetail];
    // 是否开启草稿同步    YES，同步；NO，不同步
    _saveDraftSW.on = [[WFCCIMService sharedWFCIMService] isEnableSyncDraft];
    
    NSLog(@"isHiddenNotificationDetail======%d",[[WFCCIMService sharedWFCIMService] isHiddenNotificationDetail]);
    
    WFCCUserInfo *userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    UserExtraInfo *extraInfo = [UserExtraInfo mj_objectWithKeyValues:userInfo.extra];
    _soundSW.on = (extraInfo.sound == 1);
    _vibrationSW.on = (extraInfo.shake == 1);
    
    
    NSInteger interval = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:[NSDate date]];
    _startMins = 21 * 60 - interval/60; //本地21:00
    _endMins = 7 * 60 - interval/60;  //本地7:00
    if (_endMins < 0) {
        _endMins += 24 * 60;
    }
    WS(weakself)
    [[WFCCIMService sharedWFCIMService] getNoDisturbingTimes:^(int startMins, int endMins) {
        weakself.startMins = startMins;
        weakself.endMins = endMins;
        weakself.isNoDisturb = YES;
    }error:^(int error_code) {
        weakself.isNoDisturb = NO;
    }];
}

- (IBAction)actionSW:(UISwitch *)sender {
    WS(weakself)
    if ([sender isEqual:_newsMessageSW]) { // 新消息通知
        if (sender.on) {
            [[WFCCIMService sharedWFCIMService] setGlobalSilent:!sender.on success:^{
                
            }error:^(int error_code) {
                
            }];
        }else { // 关闭时 弹出提示窗
            sender.on = YES;
            
            BOOL isChinese = [CommonHelper.main isChinese];
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:(isChinese ? @"关闭通知" : @"Tắt thông báo") message:(isChinese ? @"关闭系统通知权限将会错过消息通知" : @"Nếu tắt, bạn sẽ không nhận được bất kỳ thông báo nào từ hệ thống") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *actionLogout = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[WFCCIMService sharedWFCIMService] setGlobalSilent:YES success:^{
                    sender.on = NO;
                }error:^(int error_code) {
                    
                }];
            }];
            [actionSheet addAction:actionCancel];
            [actionSheet addAction:actionLogout];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
    }else if ([sender isEqual:_voiceVideoSW]) { // 语音和视频通话邀请提醒
        [[WFCCIMService sharedWFCIMService] setVoipNotificationSilent:!sender.on success:^{
        }error:^(int error_code) {
        }];
    }else if ([sender isEqual:_senderSW]) { // 隐藏发送人信息
        [[WFCCIMService sharedWFCIMService] setHiddenNotificationDetail:sender.on success:^{
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.senderSW.on = !weakself.senderSW.on;
            });
        }];
    }else if ([sender isEqual:_saveDraftSW]) { // 同步草稿
        [[WFCCIMService sharedWFCIMService] setEnableSyncDraft:sender.on success:^{
        }error:^(int error_code) {
        }];
    }else if ([sender isEqual:_noDisturbSW]) { // 免打扰
        if (sender.on) {
            [[WFCCIMService sharedWFCIMService] setNoDisturbingTimes:(int)_startMins endMins:(int)_endMins success:^{ // 修改免打扰时间
                weakself.isNoDisturb = YES;
            }error:^(int error_code) {
                weakself.isNoDisturb = NO;
            }];
        }else {
            [[WFCCIMService sharedWFCIMService] clearNoDisturbingTimes:^{ // 取消免打扰时间
                weakself.isNoDisturb = NO;
            }error:^(int error_code) {
                weakself.isNoDisturb = NO;
            }];
        }
    }else if ([sender isEqual:_soundSW]) { // 声音

        [self requestStateSW:sender params:@{@"sound":@(sender.on ? 1 : 0)}];
    }else if ([sender isEqual:_soundSW]) { // 震动
        
        [self requestStateSW:sender params:@{@"shake":@(sender.on ? 1 : 0)}];
    }
}

- (void)requestStateSW:(UISwitch *)sw params:(NSDictionary *)params {
    [AppService.sharedAppService requestUrl:@"/user/set_option" params:params success:^(NSDictionary * _Nonnull dict) {
    } error:^(int errCode, NSString * _Nonnull message) {
    }];
}

- (IBAction)noDisturbTime:(UIButton *)sender {
    QWERTSelectNoDisturbingTimeVC *vc = QWERTSelectNoDisturbingTimeVC.new;
    vc.startMins = _startMins;
    vc.endMins = _endMins;
    WS(weakself)
    vc.onSelectTime = ^(NSInteger startMins, NSInteger endMins) {
        weakself.startMins = startMins;
        weakself.endMins = endMins;
        
        [[WFCCIMService sharedWFCIMService] setNoDisturbingTimes:(int)weakself.startMins endMins:(int)weakself.endMins success:^{
            weakself.isNoDisturb = YES;
        } error:^(int error_code) {
        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)ceoxsoSystemNoti:(UIButton *)sender {
    LaSystemNotiVC *vc = LaSystemNotiVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}




- (void)setIsNoDisturb:(BOOL)isNoDisturb {
    _isNoDisturb = isNoDisturb;
    
    if (_isNoDisturb) {
        _noDisturbSW.on = YES;
        _noDisturbwsedcTimeLabel.hidden = NO;
        NSInteger interval = [NSTimeZone.systemTimeZone secondsFromGMTForDate:NSDate.date];
        _noDisturbTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld-%02ld:%02ld", (_startMins/60+interval/3600)%24, _startMins%60, (_endMins/60+interval/3600)%24, _endMins%60];
        _saveDraftTop.constant = 50.0;
    }else {
        _noDisturbSW.on = NO;
        _noDisturbwsedcTimeLabel.hidden = YES;
        _saveDraftTop.constant = 0.0;
    }
}

@end
