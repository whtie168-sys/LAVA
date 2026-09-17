//
//  ContactTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "FRSDAContactTVCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "UIColor+YH.h"
#import "UIFont+YH.h"
#import "QWERConfigManager.h"
#import "QWERImage.h"

@interface FRSDAContactTVCell ()
@property (nonatomic, strong)WFCCUserInfo *userInfo;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, strong)NSString *groupId;
@end

@implementation FRSDAContactTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _trewqPortraitView.layer.cornerRadius = 25.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if (self.isBig) {
//          _trewqPortraitView.frame = CGRectMake(20, (self.frame.size.height - 50.0) / 2.0, 50.0, 50.0);
//        _trewqPortraitView.layer.cornerRadius = 25.0;
//        _asoucNameLabel.frame = CGRectMake(80.0, (self.frame.size.height - 20) / 2.0, [UIScreen mainScreen].bounds.size.width - 80.0, 20);
//        _asoucNameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18.0];
//      } else {
//          _trewqPortraitView.frame = CGRectMake(20, (self.frame.size.height - 40) / 2.0, 40.0, 40.0);
//          _trewqPortraitView.layer.cornerRadius = 20.0;
//          _asoucNameLabel.frame = CGRectMake(70.0, (self.frame.size.height - 20) / 2.0, [UIScreen mainScreen].bounds.size.width - 70.0, 20.0);
//            _asoucNameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:15.0];
//      }
    _trewqPortraitView.frame = CGRectMake(20, 10.0, self.frame.size.height-20, self.frame.size.height-20);
  _trewqPortraitView.layer.cornerRadius = (self.frame.size.height-20)/2.0;
  _asoucNameLabel.frame = CGRectMake(CGRectGetMaxX(_trewqPortraitView.frame)+10.0, (self.frame.size.height - 20) / 2.0, [UIScreen mainScreen].bounds.size.width - 80.0, 20);
  _asoucNameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:15.0];
    self.lineView.frame = CGRectMake(CGRectGetMinX(_asoucNameLabel.frame), self.frame.size.height - 0.6, [UIScreen mainScreen].bounds.size.width - CGRectGetMinX(_asoucNameLabel.frame)-20.0, 0.6);
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
    
    [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
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
    
//    if ([[WFCCIMService sharedWFCIMService] isEnableUserOnlineState]) {
//        WFCCUserOnlineState *state = [[WFCCIMService sharedWFCIMService] getUserOnlineState:self.userId];
//        BOOL online = NO;
//        BOOL hasMobileSession = NO;
//        long long mobileLastSeen = 0;
//        if(state.clientStates.count) { //有设备在线
//            if(state.customState.state != 4) { //没有设置为隐身
//                for (WFCCClientState *cs in state.clientStates) {
//                    if(cs.state == 0) {
//                        online = YES;
//                        break;
//                    }
//                    if(cs.state == 1 && (cs.platform == 1 || cs.platform == 2)) {
//                        hasMobileSession = YES;
//                        if(mobileLastSeen < cs.lastSeen) {
//                            mobileLastSeen = cs.lastSeen;
//                        }
//                    }
//                }
//            }
//        }
//        self.asoucOnlineView.hidden = !(online || hasMobileSession);
//        if(!online && hasMobileSession && mobileLastSeen > 0) {
//            NSString *strSeenTime = nil;
//            long long duration = [[[NSDate alloc] init] timeIntervalSince1970] - (mobileLastSeen/1000);
//            int days = (int)(duration / 86400);
//            if(days) {
//                strSeenTime = [NSString stringWithFormat:@"%d天前", days];
//            } else {
//                int hours = (int)(duration/3600);
//                if(hours) {
//                    strSeenTime = [NSString stringWithFormat:@"%d小时前", hours];
//                } else {
//                    int mins = (int)(duration/60);
//                    if(mins) {
//                        strSeenTime = [NSString stringWithFormat:@"%d分前", mins];
//                    } else {
//                        strSeenTime = [NSString stringWithFormat:@"不久前"];
//                    }
//                }
//            }
//            self.asoucNameLabel.text = [NSString stringWithFormat:@"%@(%@)", self.asoucNameLabel.text, strSeenTime];
//        }
//    }
}

- (UIImageView *)trewqPortraitView {
    if (!_trewqPortraitView) {
        _trewqPortraitView = [UIImageView new];
        _trewqPortraitView.layer.masksToBounds = YES;
        [self.contentView addSubview:_trewqPortraitView];
    }
    return _trewqPortraitView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [UILabel new];
        _asoucNameLabel.textColor = [QWERConfigManager globalManager].textColor;
        [self.contentView addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}

- (UIImageView *)asoucOnlineView {
    if([[WFCCIMService sharedWFCIMService] isEnableUserOnlineState]) {
        if (!_asoucOnlineView) {
            _asoucOnlineView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 48, 16, 24, 24)];
            _asoucOnlineView.image = [QWERImage imageNamed:@"ic_online"];
            _asoucOnlineView.hidden = YES;
            [self.contentView addSubview:_asoucOnlineView];
        }
    }
    return _asoucOnlineView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = RGBCOLOR(224.0, 224.0, 224.0);
        [self.contentView addSubview:_lineView];
    }return _lineView;
}
- (void)setIsHiddenLine:(BOOL)isHiddenLine {
    _isHiddenLine = isHiddenLine;
    self.lineView.hidden = isHiddenLine;
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
