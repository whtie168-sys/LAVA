//
//  InformationCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGCallSummaryCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERUtilities.h"
#import "QWERImage.h"
#import "UIFont+YH.h"

#define TEXT_TOP_PADDING 6
#define TEXT_BUTTOM_PADDING 6
#define TEXT_LEFT_PADDING 8
#define TEXT_RIGHT_PADDING 8


#define TEXT_LABEL_TOP_PADDING TEXT_TOP_PADDING + 4
#define TEXT_LABEL_BUTTOM_PADDING TEXT_BUTTOM_PADDING + 4
#define TEXT_LABEL_LEFT_PADDING 30
#define TEXT_LABEL_RIGHT_PADDING 30

#if WFCU_SUPPORT_VOIP
#import <Chat86AVEngineKit/Chat86AVEngineKit.h>
#endif
@implementation ASDFGCallSummaryCell

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    NSString *text = [ASDFGCallSummaryCell getCallText:msgModel.message.content];
    CGSize textSize = [QWERUtilities getTextDrawingSize:text font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake(width, 8000)];
    return CGSizeMake(textSize.width + 20, 30);
}

+ (NSString *)getCallText:(WFCCCallStartMessageContent *)startContent {
    BOOL isChinese = [WFCCIMService.main isChinese];
    NSString *text;
    if (startContent.isAudioOnly) {
        text = (isChinese?@"语音通话":@"Gọi thoại");
    } else {
        text = (isChinese?@"视频通话":@"Gọi video");
    }
    
#if WFCU_SUPPORT_VOIP
    if(startContent.status == kWFAVCallEndReasonInterrupted) {
        text = (isChinese?@"通话中断":@"Ngắt cuộc gọi");
    } else if(startContent.status == kWFAVCallEndReasonRemoteInterrupted) {
        text = (isChinese?@"对方通话中断":@"Cuộc gọi bị ngắt");
    }
#endif
    
    if (startContent.connectTime > 0 && startContent.endTime > 0) {
        long long duration = startContent.endTime - startContent.connectTime;
        if (duration <= 0) {
            return text;
        }
        duration = duration/1000; //转化成s
        if (duration == 0) {
            return text;
        }
        
        long long hour = duration/3600; //小时数
        duration = duration - hour * 3600; //去除小时
        long long mins = duration/60;  //分钟数
        duration = duration - mins*60;
        long long second = duration;
        
        if (hour) {
            text = [text stringByAppendingFormat:@"%lld:", hour];
        }
        
        text = [text stringByAppendingFormat:@" %02lld:", mins];
        text = [text stringByAppendingFormat:@"%02lld", second];
    } else {
#if WFCU_SUPPORT_VOIP
        switch (startContent.status) {
            case kWFAVCallEndReasonBusy:
                text = (isChinese?@"线路忙":@"Dòng bận");
                break;
            case kWFAVCallEndReasonSignalError:
                text = isChinese ? @"网络错误" : @"Lỗi mạng";
                break;
            case kWFAVCallEndReasonHangup:
                text = isChinese ? @"已取消" : @"Đã hủy";
                break;
            case kWFAVCallEndReasonMediaError:
                text = isChinese ? @"网络错误" : @"Lỗi mạng";
                break;
            case kWFAVCallEndReasonRemoteHangup:
                text = isChinese ? @"对方已取消" : @"nhau bị hủy bỏ";
                break;
            case kWFAVCallEndReasonOpenCameraFailure:
                text = isChinese ? @"网络错误" : @"Lỗi mạng";
                break;
            case kWFAVCallEndReasonTimeout:
                text = isChinese ? @"未接听" : @"Không trả lời";
                break;
            case kWFAVCallEndReasonAcceptByOtherClient:
                text = isChinese ? @"其它端已接听" : @"Các đầu khác đã trả lời";
                break;
            case kWFAVCallEndReasonAllLeft:
                text = isChinese ? @"通话已结束" : @"Đã kết thúc cuộc trò chuyện";
                break;
            case kWFAVCallEndReasonRemoteBusy:
                text = isChinese ? @"对方线路忙" : @"Đường dây đối phương bận rộn";
                break;
            case kWFAVCallEndReasonRemoteTimeout:
                text = isChinese ? @"对方未接听" : @"Đối phương không nghe máy";
                break;
            case kWFAVCallEndReasonRemoteNetworkError:
                text = isChinese ? @"对方网络错误" : @"Lỗi mạng của nhau";
                break;
            case kWFAVCallEndReasonRoomDestroyed:
                text = isChinese ? @"通话已结束" : @"Đã kết thúc cuộc trò chuyện";
                break;
            case kWFAVCallEndReasonRoomNotExist:
                text = isChinese ? @"通话已结束" : @"Đã kết thúc cuộc trò chuyện";
                break;
            case kWFAVCallEndReasonRoomParticipantsFull:
                text = isChinese ? @"已达到最大参与人数" : @"Số lượng người tham gia tối đa đã đạt";
                break;
            case kWFAVCallEndReasonInterrupted:
                text = isChinese ? @"通话中断" : @"Ngắt cuộc gọi";
                break;
            case kWFAVCallEndReasonRemoteInterrupted:
                text = isChinese ? @"对方通话中断" : @"Cuộc gọi bị ngắt";
                break;
            default:
                break;
        }
#endif
    }
    
    return text;
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    CGFloat width = self.asoucContentArea.bounds.size.width;
    
    self.asoucAsdfgInfoLabel.text = [ASDFGCallSummaryCell getCallText:model.message.content];
    self.asoucAsdfgInfoLabel.layoutMargins = UIEdgeInsetsMake(TEXT_TOP_PADDING, TEXT_LEFT_PADDING, TEXT_BUTTOM_PADDING, TEXT_RIGHT_PADDING);
    
    if (model.message.direction == MessageDirection_Send) {
//        self.asoucAsdfgInfoLabel.frame = CGRectMake(0, 0, width - 25, 30);
//        self.asoucModeImageView.frame = CGRectMake(width - 25, 3, 25, 25);
        self.asoucModeImageView.frame = CGRectMake(5.0, 7.0, 17.0, 17.0);
        self.asoucAsdfgInfoLabel.frame = CGRectMake(CGRectGetMaxX(self.asoucModeImageView.frame)+10.0, 0, width - 27.0, 30);
    } else {
//        self.asoucAsdfgInfoLabel.frame = CGRectMake(0, 0, width-25, 30);
//        self.asoucModeImageView.frame = CGRectMake(width-25, 3, 25, 25);
        self.asoucModeImageView.frame = CGRectMake(5.0, 7.0, 17.0, 17.0);
        self.asoucAsdfgInfoLabel.frame = CGRectMake(CGRectGetMaxX(self.asoucModeImageView.frame)+10.0, 0, width - 27.0, 30);
    }
    if ([self.model.message.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
        WFCCCallStartMessageContent *startContent = (WFCCCallStartMessageContent *)self.model.message.content;
        if (startContent.isAudioOnly) {
            self.asoucModeImageView.image = [QWERImage imageNamed:@"vioce_flag1"];
        } else {
            self.asoucModeImageView.image = [QWERImage imageNamed:@"video_flag1"];
        }
    }
}

- (UILabel *)asoucAsdfgInfoLabel {
    if (!_asoucAsdfgInfoLabel) {
        _asoucAsdfgInfoLabel = [[UILabel alloc] init];
        _asoucAsdfgInfoLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13.0];
        
        _asoucAsdfgInfoLabel.numberOfLines = 0;
        _asoucAsdfgInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _asoucAsdfgInfoLabel.textAlignment = NSTextAlignmentLeft;
        _asoucAsdfgInfoLabel.layer.masksToBounds = YES;
        _asoucAsdfgInfoLabel.userInteractionEnabled = YES;
        [self.asoucContentArea addSubview:_asoucAsdfgInfoLabel];
    }
    return _asoucAsdfgInfoLabel; 
}
- (UIImageView *)asoucModeImageView {
    if (!_asoucModeImageView) {
        _asoucModeImageView = [[UIImageView alloc] init];
        [self.asoucContentArea addSubview:_asoucModeImageView];
    }
    return _asoucModeImageView;
}
@end
