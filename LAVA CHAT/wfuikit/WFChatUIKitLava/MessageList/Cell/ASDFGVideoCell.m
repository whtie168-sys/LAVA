//
//  VideoCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGVideoCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERImage.h"

@interface ASDFGVideoCell ()
@property(nonatomic, strong) UIImageView *shadowMaskView;
@end

@implementation ASDFGVideoCell

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width { // width 269
    WFCCVideoMessageContent *imgContent = (WFCCVideoMessageContent *)msgModel.message.content;
    
    CGSize size = imgContent.thumbnail.size;
    
//    if (size.height > width || size.width > width) {
//        float scale = MIN(width/size.height, width/size.width);
//        size = CGSizeMake(size.width * scale, size.height * scale);
//        isCustom = NO;
//    }

    // 该逻辑0126新增 主要是为视频缩略图压缩成120规格所定义
    if (size.height == 750 || size.width == 750) {
        if (size.height == 750) {
            size = CGSizeMake(size.width/750.0*120.0, 120.0);
        }else {
            size = CGSizeMake(120.0, size.height/750.0*120.0);
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
    
    WFCCVideoMessageContent *imgContent = (WFCCVideoMessageContent *)model.message.content;
    self.asouThumbnailView.frame = self.asoucBubbleView.bounds;
    self.asouThumbnailView.image = imgContent.thumbnail;
    self.asouVideoCoverView.frame = CGRectMake((self.asoucBubbleView.bounds.size.width - 40)/2, (self.asoucBubbleView.bounds.size.height - 40)/2, 40, 40);
    self.asouVideoCoverView.image = [QWERImage imageNamed:@"video_msg_cover_w"];
}

- (UIImageView *)asouThumbnailView {
    if (!_asouThumbnailView) {
        _asouThumbnailView = [[UIImageView alloc] init];
        [self.asoucBubbleView addSubview:_asouThumbnailView];
    }
    return _asouThumbnailView;
}

- (UIImageView *)asouVideoCoverView {
    if (!_asouVideoCoverView) {
        _asouVideoCoverView = [[UIImageView alloc] init];
        _asouVideoCoverView.backgroundColor = [UIColor clearColor];
        [self.asoucBubbleView addSubview:_asouVideoCoverView];
    }
    return _asouVideoCoverView;
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
@end
