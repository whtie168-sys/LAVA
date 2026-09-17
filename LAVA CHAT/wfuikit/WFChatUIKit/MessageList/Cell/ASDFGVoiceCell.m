//
//  VoiceCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGVoiceCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERImage.h"

@interface ASDFGVoiceCell ()
@property(nonatomic, strong) NSTimer *animationTimer;
@property(nonatomic) int animationIndex;
@end

@implementation ASDFGVoiceCell
+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCSoundMessageContent *soundContent = (WFCCSoundMessageContent *)msgModel.message.content;
    long duration = soundContent.duration;
    return CGSizeMake(50 + 30 * (MIN(MAX(0, duration-5), 20)/20.0), 30);
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    CGRect bounds = self.asoucContentArea.bounds;
    if (model.message.direction == MessageDirection_Send) {
        self.asouVoiceBtn.frame = CGRectMake(bounds.size.width - 30, 4, 22, 22);
        self.asouDurationLabel.frame = CGRectMake(bounds.size.width - 48, 12, 18, 9);
        self.asouUnplayedView.hidden = YES;
    } else {
        self.asouVoiceBtn.frame = CGRectMake(4, 4, 22, 22);
        self.asouDurationLabel.frame = CGRectMake(32, 12, 18, 9);
        
        if (model.message.status == Message_Status_Played) {
            self.asouUnplayedView.hidden = YES;
        } else {
            self.asouUnplayedView.hidden = NO;
            CGRect frame = [self.contentView convertRect:CGRectMake(self.asoucContentArea.bounds.size.width + 10, 12, 10, 10) fromView:self.asoucContentArea];
            self.asouUnplayedView.frame = frame;
        }
    }
    WFCCSoundMessageContent *soundContent = (WFCCSoundMessageContent *)model.message.content;
    self.asouDurationLabel.text = [NSString stringWithFormat:@"%ld''", soundContent.duration];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimationTimer) name:kVoiceMessageStartPlaying object:@(model.message.messageId)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimationTimer) name:kVoiceMessagePlayStoped object:nil];
    if (model.voicePlaying) {
        [self startAnimationTimer];
    } else {
        [self stopAnimationTimer];
    }
}

- (UIView *)asouUnplayedView {
    if (!_asouUnplayedView) {
        _asouUnplayedView = [[UIView alloc] init];
        _asouUnplayedView.layer.cornerRadius = 5.f;
        _asouUnplayedView.layer.masksToBounds = YES;
        _asouUnplayedView.backgroundColor = [UIColor redColor];
        
        [self.contentView addSubview:_asouUnplayedView];
    }
    return _asouUnplayedView;
}

- (UIImageView *)asouVoiceBtn {
    if (!_asouVoiceBtn) {
        _asouVoiceBtn = [[UIImageView alloc] init];
        [self.asoucContentArea addSubview:_asouVoiceBtn];
    }
    return _asouVoiceBtn;
}

- (UILabel *)asouDurationLabel {
    if (!_asouDurationLabel) {
        _asouDurationLabel = [[UILabel alloc] init];
        _asouDurationLabel.font = [UIFont systemFontOfSize:10];
        [self.asoucContentArea addSubview:_asouDurationLabel];
    }
    return _asouDurationLabel;
}

- (void)startAnimationTimer {
    [self stopAnimationTimer];
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(scheduleAnimation:)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.animationTimer fire];
}


- (void)scheduleAnimation:(id)sender {
    NSString *_playingImg;
    
    if (MessageDirection_Send == self.model.message.direction) {
        _playingImg = [NSString stringWithFormat:@"sent_voice_%d", (self.animationIndex++ % 3) + 1];
    } else {
        _playingImg = [NSString stringWithFormat:@"received_voice_%d", (self.animationIndex++ % 3) + 1];
    }

    [self.asouVoiceBtn setImage:[QWERImage imageNamed:_playingImg]];
}

- (void)stopAnimationTimer {
    if (self.animationTimer && [self.animationTimer isValid]) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.animationIndex = 0;
    }
    
    if (self.model.message.direction == MessageDirection_Send) {
        [self.asouVoiceBtn setImage:[QWERImage imageNamed:@"sent_voice"]];
    } else {
        [self.asouVoiceBtn setImage:[QWERImage imageNamed:@"received_voice"]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
