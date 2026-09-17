//
//  ConversationSettingMemberCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/11/3.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "DSRACConversationSettingMemberCell.h"
#import <SDWebImage/SDWebImage.h>
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERConfigManager.h"
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "QWERImage.h"

@interface DSRACConversationSettingMemberCell ()
@property(nonatomic, strong) NSObject *model;
@end

@implementation DSRACConversationSettingMemberCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [QWERConfigManager globalManager].backgroudColor;
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.headerImageView.frame = CGRectMake(2, 2, self.frame.size.width - 4, self.frame.size.width - 4);
    self.headerImageView.frame = CGRectMake((self.frame.size.width-44.0)/2.0, 2.0, 44.0, 44.0);
//    self.asoucNameLabel.frame = CGRectMake(0, self.frame.size.width + 3, self.frame.size.width, 11);
    self.asoucNameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.headerImageView.frame)+6.0, self.frame.size.width, 16);
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _asoucNameLabel.textColor = [QWERConfigManager globalManager].textColor;
        _asoucNameLabel.textAlignment = NSTextAlignmentCenter;
        _asoucNameLabel.backgroundColor = UIColor.clearColor;
        _asoucNameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
        [[self contentView] addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headerImageView.autoresizingMask =
        UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImageView.clipsToBounds = YES;
        
        _headerImageView.layer.borderWidth = 1;
        _headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _headerImageView.layer.cornerRadius = 22.0;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.backgroundColor = [UIColor clearColor];
        _headerImageView.layer.edgeAntialiasingMask =
        kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge |
        kCALayerTopEdge;
        [[self contentView] addSubview:_headerImageView];
    }
    return _headerImageView;
}

- (void)setModel:(NSObject *)model withType:(WFCCConversationType)type {
    self.contentView.backgroundColor = UIColor.whiteColor;
//    self.asoucNameLabel.textColor = [QWERConfigManager globalManager].textColor;
    
    self.model = model;
    
    WFCCUserInfo *userInfo;
    WFCCGroupMember *groupMember;
    WFCCChannelInfo *channelInfo;
    if (type == Group_Type) {
        groupMember = (WFCCGroupMember *)model;
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:groupMember.memberId inGroup:groupMember.groupId refresh:NO];
    } else if(type == Single_Type) {
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:(NSString *)model refresh:NO];
    } else if(type == Channel_Type) {
        channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:(NSString *)model refresh:NO];
    } else if(type == SecretChat_Type) {
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:(NSString *)model].userId;
        userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
    } else {
        return;
    }
    
    if (type == Channel_Type) {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[channelInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                         context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        self.asoucNameLabel.text = channelInfo.name;
    } else {
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                         context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        
        if (userInfo.friendAlias.length) {
            self.asoucNameLabel.text = userInfo.friendAlias;
        } else if(userInfo.groupAlias.length) {
            self.asoucNameLabel.text = userInfo.groupAlias;
        } else if(userInfo.displayName.length) {
            self.asoucNameLabel.text = userInfo.displayName;
        } else {
            self.asoucNameLabel.text = nil;
        }
    }
    self.asoucNameLabel.hidden = NO;
}

- (void)resetLayout:(CGFloat)asoucNameLabelHeight
       insideMargin:(CGFloat)insideMargin {
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.headerImageView sd_cancelCurrentImageLoad];
    self.headerImageView.image = nil;
}
@end
