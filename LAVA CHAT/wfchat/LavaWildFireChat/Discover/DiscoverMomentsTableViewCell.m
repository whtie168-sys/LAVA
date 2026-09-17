//
//  DiscoverTableViewCell.m
//  WildFireChat
//
//  Created by Tom Lee on 2020/3/10.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "DiscoverMomentsTableViewCell.h"
#import <SDWebImage/SDWebImage.h>


@interface DiscoverMomentsTableViewCell ()
@property(nonatomic, strong)UIImageView *lastFeedPortrait;
@property (nonatomic, strong)WSEDCBubbleTipView *asoucBubbleView2;
@end

@implementation DiscoverMomentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (WSEDCBubbleTipView *)asoucBubbleView {
    if (!_asoucBubbleView) {
        if(self.textLabel) {
            _asoucBubbleView = [[WSEDCBubbleTipView alloc] initWithSuperView:self.textLabel];
            _asoucBubbleView.hidden = YES;
            _asoucBubbleView.isShowNotificationNumber = YES;
        }
    }
    return _asoucBubbleView;
}

- (WSEDCBubbleTipView *)asoucBubbleView2 {
    if (!_asoucBubbleView2) {
        if(self.lastFeedPortrait) {
            _asoucBubbleView2 = [[WSEDCBubbleTipView alloc] initWithSuperView:self.lastFeedPortrait];
            _asoucBubbleView2.hidden = YES;
            _asoucBubbleView2.bubbleTipPositionAdjustment = CGPointMake(-25, -8);
            _asoucBubbleView2.isShowNotificationNumber = NO;
        }
    }
    return _asoucBubbleView2;
}

- (UIImageView *)lastFeedPortrait {
    if (!_lastFeedPortrait) {
        _lastFeedPortrait = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 8, 32, 32)];
        [self.contentView addSubview:_lastFeedPortrait];
    }
    return _lastFeedPortrait;
}
#ifdef WFC_MOMENTS
- (void)setLastFeed:(WFMFeed *)lastFeed {
    _lastFeed = lastFeed;
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:lastFeed.sender refresh:NO];
    
    [self.lastFeedPortrait sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    if (lastFeed.serverTime > [[WFMomentService sharedService] getLastReadTimestamp]*1000) {
        [self.asoucBubbleView2 setBubbleTipNumber:1];
        self.asoucBubbleView2.hidden = NO;
    } else {
        [self.asoucBubbleView2 setBubbleTipNumber:0];
        self.asoucBubbleView2.hidden = YES;
    }
}
#endif
@end
