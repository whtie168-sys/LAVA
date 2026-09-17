//
//  RADCOPortraitCVCell.m
//  WFChatUIKit
//
//  Created by dali on 2020/1/20.
//  Copyright © 2020 WildFireChat. All rights reserved.
//
#if WFCU_SUPPORT_VOIP
#import "RADCOConferencePortraitCVCell.h"
#import <SDWebImage/SDWebImage.h>
#import "QWERImage.h"
#import "RADCOConferenceLabelView.h"

@interface RADCOConferencePortraitCVCell ()
@property (nonatomic, strong)UIImageView *trewqPortraitView;
@property (nonatomic, strong)UILabel *asoucNameLabel;
@property (nonatomic, strong)UIImageView *stateLabel;
@property (nonatomic, strong)RADCOConferenceLabelView *conferenceLabelView;
@end

@implementation RADCOConferencePortraitCVCell

- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    self.asoucNameLabel.text = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
    self.conferenceLabelView.name = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVolumeUpdated:) name:@"wfavVolumeUpdated" object:nil];
    
}

- (void)onVolumeUpdated:(NSNotification *)notification {
    if([notification.object isEqual:self.userInfo.userId]) {
        NSInteger volume = [notification.userInfo[@"volume"] integerValue];
        if (volume > 1000) {
            self.layer.borderColor = [UIColor greenColor].CGColor;
        } else {
            self.layer.borderColor = [UIColor clearColor].CGColor;
        }
        self.conferenceLabelView.volume = volume;
    }
}

-(void)setProfile:(WFAVParticipantProfile *)profile {
    _profile = profile;
    if (profile.state == kWFAVEngineStateConnected || profile.state == kWFAVEngineStateIdle) {
        [self.stateLabel stopAnimating];
        self.stateLabel.hidden = YES;
    } else {
        [self.stateLabel startAnimating];
        self.stateLabel.hidden = NO;
    }
    BOOL isVideoMuted = YES;
    BOOL isAudioMuted = YES;
    if(!profile.audience) {
        isVideoMuted = profile.videoMuted;
        isAudioMuted = profile.audioMuted;
    }
    self.conferenceLabelView.isMuteVideo = isVideoMuted;
    self.conferenceLabelView.isMuteAudio = isAudioMuted;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    [self bringSubviewToFront:self.conferenceLabelView];
}

- (UIImageView *)trewqPortraitView {
    if (!_trewqPortraitView) {
        _trewqPortraitView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.itemSize, self.itemSize)];

        _trewqPortraitView.layer.masksToBounds = YES;
        _trewqPortraitView.layer.cornerRadius = self.itemSize / 2.0;
        [self addSubview:_trewqPortraitView];
    }
    return _trewqPortraitView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.itemSize, self.itemSize, self.labelSize)];
        _asoucNameLabel.font = [UIFont systemFontOfSize:self.labelSize - 4];
        _asoucNameLabel.textColor = [UIColor whiteColor];
        _asoucNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}

- (UIImageView *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.itemSize, self.itemSize)];
        
        _stateLabel.animationImages = @[[QWERImage imageNamed:@"connect_ani1"],[QWERImage imageNamed:@"connect_ani2"],[QWERImage imageNamed:@"connect_ani3"]];
        _stateLabel.animationDuration = 1.f;
        _stateLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self addSubview:_stateLabel];
    }
    return _stateLabel;
}

- (RADCOConferenceLabelView *)conferenceLabelView {
    if(!_conferenceLabelView) {
        CGSize size = [RADCOConferenceLabelView sizeOffView];
        _conferenceLabelView = [[RADCOConferenceLabelView alloc] initWithFrame:CGRectMake(4, self.bounds.size.height - size.height - 4, size.width, size.height)];
        [self addSubview:_conferenceLabelView];
    }
    return _conferenceLabelView;
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
#endif
