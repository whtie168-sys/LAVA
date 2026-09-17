//
//  RADCOConferenceParticipantCVCell.m
//  WFChatUIKit
//
//  Created by dali on 2020/1/20.
//  Copyright © 2020 WildFireChat. All rights reserved.
//
#if WFCU_SUPPORT_VOIP
#import "RADCOConferenceParticipantCVCell.h"
#import <SDWebImage/SDWebImage.h>
#import "RADCOWaitingAnimationView.h"
#import "QWERImage.h"
#import "RADCOConferenceLabelView.h"

@interface RADCOConferenceParticipantCVCell ()
@property (nonatomic, strong)UIImageView *trewqPortraitView;
@property (nonatomic, strong)RADCOWaitingAnimationView *stateLabel;
@property(nonatomic, strong)NSString *userId;
@property (nonatomic, strong)RADCOConferenceLabelView *conferenceLabelView;
@property(nonatomic, strong)WFAVParticipantProfile *profile;
@end

@implementation RADCOConferenceParticipantCVCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.4];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.f;
        self.layer.borderWidth = 1.f;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return self;
}

- (void)setUserInfo:(WFCCUserInfo *)userInfo callProfile:(WFAVParticipantProfile *)profile {
    self.profile = profile;
    self.userId = userInfo.userId;

    [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    self.trewqPortraitView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);

    if (profile.state == kWFAVEngineStateIncomming
        || profile.state == kWFAVEngineStateOutgoing
        || profile.state == kWFAVEngineStateConnecting) {
        [self.stateLabel start];
        self.stateLabel.hidden = NO;
    } else {
        [self.stateLabel stop];
        self.stateLabel.hidden = YES;
    }

    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.trewqPortraitView.layer.borderColor = [UIColor clearColor].CGColor;
    self.conferenceLabelView.name = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
    
    BOOL isVideoMuted = YES;
    BOOL isAudioMuted = YES;
    if ([Chat86AVEngineKit sharedEngineKit].currentSession.isConference) {
        if(!profile.audience) {
            isVideoMuted = profile.videoMuted;
            isAudioMuted = profile.audioMuted;
        }
    } else {
        isVideoMuted = NO;
        isAudioMuted = NO;
    }
    
    self.conferenceLabelView.isMuteVideo = isVideoMuted;
    self.conferenceLabelView.isMuteAudio = isAudioMuted;
    
    if(isAudioMuted) {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVolumeUpdated:) name:@"wfavVolumeUpdated" object:nil];
    
    
    CGRect frame = self.conferenceLabelView.frame;
    if(isVideoMuted) {
        self.conferenceLabelView.frame = CGRectMake(self.bounds.size.width/2 - frame.size.width/2, self.bounds.size.height/2 + 30 + 4, frame.size.width, frame.size.height);
    } else {
        self.conferenceLabelView.frame = CGRectMake(4, self.bounds.size.height - frame.size.height - 4, frame.size.width, frame.size.height);
    }
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    [self bringSubviewToFront:self.conferenceLabelView];
}

- (void)onVolumeUpdated:(NSNotification *)notification {
    if([notification.object isEqual:self.userId]) {
        NSInteger volume = [notification.userInfo[@"volume"] integerValue];
        if(self.conferenceLabelView.isMuteVideo) {
            if (volume > 1000) {
                self.trewqPortraitView.layer.borderColor = [UIColor greenColor].CGColor;
            } else {
                self.trewqPortraitView.layer.borderColor = [UIColor clearColor].CGColor;
            }
            self.layer.borderColor = [UIColor clearColor].CGColor;
        } else {
            if (volume > 1000) {
                self.layer.borderColor = [UIColor greenColor].CGColor;
            } else {
                self.layer.borderColor = [UIColor clearColor].CGColor;
            }
            self.trewqPortraitView.layer.borderColor = [UIColor clearColor].CGColor;
        }
        
        self.conferenceLabelView.volume = volume;
    }
}

- (RADCOConferenceLabelView *)conferenceLabelView {
    if(!_conferenceLabelView) {
        CGSize size = [RADCOConferenceLabelView sizeOffView];
        _conferenceLabelView = [[RADCOConferenceLabelView alloc] initWithFrame:CGRectMake(4, self.bounds.size.height - size.height - 4, size.width, size.height)];
        [self.contentView addSubview:_conferenceLabelView];
    }
    return _conferenceLabelView;
}

- (UIImageView *)trewqPortraitView {
    if (!_trewqPortraitView) {
        _trewqPortraitView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _trewqPortraitView.center = self.contentView.center;
        _trewqPortraitView.layer.masksToBounds = YES;
        _trewqPortraitView.layer.cornerRadius = 30;
        _trewqPortraitView.layer.borderWidth = 1;
        _trewqPortraitView.layer.borderColor = [UIColor clearColor].CGColor;
        [self.contentView addSubview:_trewqPortraitView];
    }
    return _trewqPortraitView;
}

- (RADCOWaitingAnimationView *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[RADCOWaitingAnimationView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _stateLabel.animationImages = @[[QWERImage imageNamed:@"connect_ani1"],[QWERImage imageNamed:@"connect_ani2"],[QWERImage imageNamed:@"connect_ani3"]];
        _stateLabel.animationDuration = 1;
        _stateLabel.animationRepeatCount = 200;
        _stateLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _stateLabel.hidden = YES;
        _stateLabel.layer.masksToBounds = YES;
        _stateLabel.layer.cornerRadius = 30;
        [self.trewqPortraitView addSubview:_stateLabel];
    }
    return _stateLabel;
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
