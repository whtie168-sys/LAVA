//
//  ConversationCell.m
//  ShareExtension
//
//  Created by Tom Lee on 2020/10/15.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "ConversationCell.h"
#import <SDWebImage/SDWebImage.h>
#import "ShareUtility.h"

@implementation ConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

- (void)setConversation:(SharedConversation *)sc {
    _conversation = sc;
    
    self.asoucNameLabel.text = sc.title;
    if (sc.type == 0) { //Single_Type
        [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:sc.portraitUrl] placeholderImage:[UIImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    } else if(sc.type == 1) {  //Group_Type
        if (sc.portraitUrl.length) {
            [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:sc.portraitUrl] placeholderImage:[UIImage imageNamed:@"GroupChat"] options:SDWebImageScaleDownLargeImages
                                               context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        } else {
            [self.trewqPortraitView sd_setImageWithURL:[ShareUtility getSavedGroupGridPortrait:sc.target] placeholderImage:[UIImage imageNamed:@"GroupChat"] options:SDWebImageScaleDownLargeImages
                                               context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        }
    } else if(sc.type == 3) { //Channel_Type
        [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:sc.portraitUrl] placeholderImage:[UIImage imageNamed:@"ChannelChat"] options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    } else if(sc.type == 5) { //SecretChat_Type
        [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:sc.portraitUrl] placeholderImage:[UIImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    }
}

- (UIImageView *)trewqPortraitView {
    if (!_trewqPortraitView) {
        _trewqPortraitView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 40, 40)];
        _trewqPortraitView.layer.cornerRadius = 20.0;
        _trewqPortraitView.layer.masksToBounds = YES;
        [self.contentView addSubview:_trewqPortraitView];
    }
    return _trewqPortraitView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 18, self.bounds.size.width - 56 - 16, 20)];
        _asoucNameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.trewqPortraitView sd_cancelCurrentImageLoad];
    self.trewqPortraitView.image = nil;
}

@end
