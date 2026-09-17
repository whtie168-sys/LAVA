//
//  ImageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGLocationCell.h"
#import <LavaWFChatClient/WFCChatClient.h>

@interface ASDFGLocationCell ()
@property(nonatomic, strong) UIImageView *shadowMaskView;
@property (nonatomic, strong)UIImageView *asouThumbnailView;
@property (nonatomic, strong)UILabel *titleLabel;
@end

@implementation ASDFGLocationCell

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCLocationMessageContent *imgContent = (WFCCLocationMessageContent *)msgModel.message.content;
    
    CGSize size = imgContent.thumbnail.size;
    
    if (size.height > width || size.width > width) {
        float scale = MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    WFCCLocationMessageContent *imgContent = (WFCCLocationMessageContent *)model.message.content;
    self.asouThumbnailView.frame = self.asoucBubbleView.bounds;
    self.asouThumbnailView.image = imgContent.thumbnail;
    self.titleLabel.text = imgContent.title;
}

- (UIImageView *)asouThumbnailView {
    if (!_asouThumbnailView) {
        _asouThumbnailView = [[UIImageView alloc] init];
        [self.asoucBubbleView addSubview:_asouThumbnailView];
    }
    return _asouThumbnailView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.asoucBubbleView.frame.size.width, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:0.5f];
        [self.asoucBubbleView addSubview:_titleLabel];
    }
    return _titleLabel;
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

@end
