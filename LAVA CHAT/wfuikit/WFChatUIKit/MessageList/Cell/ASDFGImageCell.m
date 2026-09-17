//
//  ImageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGImageCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>

@interface ASDFGImageCell ()
@property(nonatomic, strong) UIImageView *shadowMaskView;
@end

@implementation ASDFGImageCell

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)msgModel.message.content;
    CGSize size = CGSizeMake(120, 120);
    if(imgContent.thumbnail) {
        size = imgContent.thumbnail.size;
    } else {
        size = [WFCCUtilities imageScaleSize:imgContent.size targetSize:CGSizeMake(120, 120) thumbnailPoint:nil];
    }
    
    
    // 该逻辑0126新增 主要是为视频缩略图压缩成120规格所定义
    if (size.height == 301 || size.width == 301) {
        if (size.height == 301) {
            size = CGSizeMake(size.width/301.0*120.0, 120.0);
        }else {
            size = CGSizeMake(120.0, size.height/301.0*120.0);
        }
    }else {
        if (size.height > width || size.width > width) {
            float scale = MIN(width/size.height, width/size.width);
            size = CGSizeMake(size.width * scale, size.height * scale);
        }
    }
    return size;
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    WFCCImageMessageContent *imgContent = (WFCCImageMessageContent *)model.message.content;
    self.asouThumbnailView.frame = self.asoucBubbleView.bounds;
    if (!imgContent.thumbnail && imgContent.thumbParameter) {
        [self.asouThumbnailView sd_setImageWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@?%@", imgContent.remoteUrl, imgContent.thumbParameter] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    } else {
        // 小图模糊的原因～～～在这儿
//        self.asouThumbnailView.image = imgContent.thumbnail;
//        [self.asouThumbnailView sd_setImageWithURL:[NSURL URLWithString:[imgContent.remoteUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        [self.asouThumbnailView sd_setImageWithURL:[NSURL URLWithString:[imgContent.remoteUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:imgContent.thumbnail options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
//        [self.asouThumbnailView sd_setImageWithURL:[NSURL URLWithString:[imgContent.remoteUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
}

- (UIImageView *)asouThumbnailView {
    if (!_asouThumbnailView) {
        _asouThumbnailView = [[UIImageView alloc] init];
        _asouThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        [self.asoucBubbleView addSubview:_asouThumbnailView];
    }
    return _asouThumbnailView;
}

- (void)setMaskImage:(UIImage *)maskImage{
    [super setMaskImage:maskImage];
    if (_shadowMaskView) {
        [_shadowMaskView removeFromSuperview];
    }
    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];
    
    CGRect frame = CGRectMake(self.asoucBubbleView.frame.origin.x - 1, self.asoucBubbleView.frame.origin.y - 1, self.asoucBubbleView.frame.size.width + 2, self.asoucBubbleView.frame.size.height + 2);
    _shadowMaskView.frame = frame;
    [self.contentView addSubview:_shadowMaskView];
    [self.contentView bringSubviewToFront:self.asoucBubbleView];
    
}

- (UIView *)getProgressParentView {
    return self.asouThumbnailView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.asouThumbnailView sd_cancelCurrentImageLoad];
    self.asouThumbnailView.image = nil;
}
@end
