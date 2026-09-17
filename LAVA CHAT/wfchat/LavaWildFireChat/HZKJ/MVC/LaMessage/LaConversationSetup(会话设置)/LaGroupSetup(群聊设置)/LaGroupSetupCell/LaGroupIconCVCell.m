//
//  LaGroupIconCVCell.m
//  WildFireChat
//
//  Created by Ruby on 12/11/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaGroupIconCVCell.h"

@implementation LaGroupIconCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _iconView.layer.cornerRadius = 22.0;
}

- (void)setMember:(WFCCGroupMember *)member {
    _member = member;
    
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:_member.memberId inGroup:_member.groupId refresh:NO];
    
    [_iconView sd_setImageWithURL:URL(userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]  options:SDWebImageScaleDownLargeImages
                          context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    if (userInfo.friendAlias.length) {
        _asoucNameLabel.text = userInfo.friendAlias;
    }else if (userInfo.groupAlias.length) {
        _asoucNameLabel.text = userInfo.groupAlias;
    }else if (userInfo.displayName.length) {
        _asoucNameLabel.text = userInfo.displayName;
    }else {
        _asoucNameLabel.text = @"";
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView sd_cancelCurrentImageLoad];
    self.iconView.image = nil;
}

@end
