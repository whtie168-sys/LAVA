//
//  NewFriendTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "FRSDANewFriendTVCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "UIFont+YH.h"
#import "UIColor+YH.h"

@interface FRSDANewFriendTVCell ()

@end

@implementation FRSDANewFriendTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    _trewqPortraitView.layer.cornerRadius = 20.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.trewqPortraitView.frame = CGRectMake(20, 10, (self.frame.size.height - 20.0), (self.frame.size.height - 20.0));
//    self.trewqPortraitView.center = CGPointMake(self.trewqPortraitView.center.x, self.center.y);
    self.trewqPortraitView.layer.cornerRadius = (self.frame.size.height - 20.0) / 2.0;
//    self.asoucNameLabel.frame = CGRectMake(80.0, _trewqPortraitView.center.y-10.0, [UIScreen mainScreen].bounds.size.width - 64, 20);
    self.asoucNameLabel.frame = CGRectMake(CGRectGetMaxX(self.trewqPortraitView.frame) + 10.0, _trewqPortraitView.center.y-10.0, 0.0, 20);
    [self.asoucNameLabel sizeToFit];
    
    self.asoucRedLabel.frame = CGRectMake(CGRectGetMaxX(_asoucNameLabel.frame)+6.0, _trewqPortraitView.center.y-8.0, 16.0, 16.0);
    
    self.lineView.frame = CGRectMake(CGRectGetMinX(_asoucNameLabel.frame), self.frame.size.height - 0.6, [UIScreen mainScreen].bounds.size.width - CGRectGetMinX(_asoucNameLabel.frame)-20.0, 0.6);
}

- (void)onFriendRequestUpdated:(NSNotification *)notification {
    [self updateBubbleNumber];
}

- (void)updateBubbleNumber {
    int unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadFriendRequestStatus];
    if (unreadCount) {
        self.asoucRedLabel.hidden = NO;
        self.asoucRedLabel.text = [NSString stringWithFormat:@"%d", unreadCount];
//        self.asoucBubbleView.hidden = NO;
//        [self.asoucBubbleView setBubbleTipNumber:unreadCount];
    } else {
        self.asoucRedLabel.hidden = YES;
//        self.asoucBubbleView.hidden = YES;
    }
}

- (void)refresh {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendRequestUpdated:) name:kFriendRequestUpdated object:nil];
    
    [self updateBubbleNumber];
}

- (UILabel *)asoucRedLabel {
    if (!_asoucRedLabel) {
        _asoucRedLabel = [[UILabel alloc] init];
        _asoucRedLabel.backgroundColor = HEXCOLOR(0xEC2E2E);
        _asoucRedLabel.textAlignment = NSTextAlignmentCenter;
        _asoucRedLabel.font = [UIFont boldSystemFontOfSize:10.5];
        _asoucRedLabel.textColor = UIColor.whiteColor;
        _asoucRedLabel.layer.cornerRadius = 8.0;
        _asoucRedLabel.layer.masksToBounds = YES;
        _asoucRedLabel.hidden = YES;
        [self.contentView addSubview:_asoucRedLabel];
    }return _asoucRedLabel;
}
//- (WSEDCBubbleTipView *)asoucBubbleView {
//    if (!_asoucBubbleView) {
//        if (self.trewqPortraitView) {
//            _asoucBubbleView = [[WSEDCBubbleTipView alloc] initWithSuperView:self.contentView];
//            _asoucBubbleView.frame = CGRectMake(CGRectGetMaxX(_asoucNameLabel.frame)+6.0, _trewqPortraitView.center.y-8.0, 16.0, 16.0);
//            _asoucBubbleView.hidden = YES;
//        }
//    }
//    return _asoucBubbleView;
//}

- (UIImageView *)trewqPortraitView {
    if (!_trewqPortraitView) {
        _trewqPortraitView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 50, 50)];
        _trewqPortraitView.layer.masksToBounds = YES;
        _trewqPortraitView.layer.cornerRadius = 25.f;
        [self.contentView addSubview:_trewqPortraitView];
    }
    return _trewqPortraitView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 25, [UIScreen mainScreen].bounds.size.width - 80, 20)];
        _asoucNameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:15.0];
        _asoucNameLabel.textColor = [UIColor colorWithHexString:@"0x1d1d1d"];
        [self.contentView addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
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
    _lineView.hidden = isHiddenLine;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
