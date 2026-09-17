//
//  ImageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/2.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGStickerCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERMediaMessageDownloader.h"
#import <SDWebImage/SDWebImage.h>
#import "QWERUtilities.h"

@interface ASDFGStickerCell ()
@property (nonatomic, strong)UIImageView *asouThumbnailView;
@end

@implementation ASDFGStickerCell

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCStickerMessageContent *imgContent = (WFCCStickerMessageContent *)msgModel.message.content;
    CGSize size = imgContent.size;
    
    if (size.height > width || size.width > width) {
        float scale = MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)superUpdateModel:(QWERTMessageModel *)model {
    [super setModel:model];
}

- (void)setModel:(QWERTMessageModel *)model {
    WFCCStickerMessageContent *stickerMsg = (WFCCStickerMessageContent *)model.message.content;
    if (model.message.conversation.type == SecretChat_Type && model.message.direction == MessageDirection_Receive && model.message.status != Message_Status_Played) {
        [[WFCCIMService sharedWFCIMService] setMediaMessagePlayed:model.message.messageId];
        model.message.status = Message_Status_Played;
    }
    
    __weak typeof(self) weakSelf = self;
    if (!stickerMsg.localPath.length || ![QWERUtilities isFileExist:stickerMsg.localPath]) {
        BOOL downloading = [[QWERMediaMessageDownloader sharedDownloader] tryDownload:model.message success:^(long long messageUid, NSString *localPath) {
            if (messageUid == weakSelf.model.message.messageUid) {
                weakSelf.model.mediaDownloading = NO;
                stickerMsg.localPath = localPath;
                [weakSelf setModel:weakSelf.model];
            }
        } error:^(long long messageUid, int error_code) {
            if (messageUid == weakSelf.model.message.messageUid) {
                weakSelf.model.mediaDownloading = NO;
                [weakSelf superUpdateModel:weakSelf.model];
            }
        }];
        if (downloading) {
            model.mediaDownloading = YES;
        }
    } else {
        model.mediaDownloading = NO;
    }
    [super setModel:model];
    
    self.asouThumbnailView.frame = self.asoucBubbleView.bounds;
    if (stickerMsg.localPath.length && [QWERUtilities isFileExist:stickerMsg.localPath]) {
        if(model.message.conversation.type == SecretChat_Type && model.message.direction == MessageDirection_Receive) {
            NSData *data = [NSData dataWithContentsOfFile:stickerMsg.localPath];
            data = [[WFCCIMService sharedWFCIMService] decodeSecretChat:model.message.conversation.target mediaData:data];
            self.asouThumbnailView.image = [UIImage imageWithData:data];
        } else {
            [self.asouThumbnailView sd_setImageWithURL:[NSURL fileURLWithPath:stickerMsg.localPath] placeholderImage:nil options:SDWebImageScaleDownLargeImages
                                               context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        }
    }else {
        self.asouThumbnailView.image = nil;
    }
    self.asoucBubbleView.image = nil;
}

- (UIImageView *)asouThumbnailView {
    if (!_asouThumbnailView) {
        _asouThumbnailView = [[UIImageView alloc] init];
        [self.asoucBubbleView addSubview:_asouThumbnailView];
    }
    return _asouThumbnailView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.asouThumbnailView sd_cancelCurrentImageLoad];
    self.asouThumbnailView.image = nil;
}
@end
