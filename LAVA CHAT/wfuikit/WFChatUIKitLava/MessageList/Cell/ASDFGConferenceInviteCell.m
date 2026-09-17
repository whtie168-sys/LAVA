//
//  InformationCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGConferenceInviteCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERUtilities.h"

#define TEXT_TOP_PADDING 6
#define TEXT_BUTTOM_PADDING 6
#define TEXT_LEFT_PADDING 8
#define TEXT_RIGHT_PADDING 8


#define TEXT_LABEL_TOP_PADDING TEXT_TOP_PADDING + 4
#define TEXT_LABEL_BUTTOM_PADDING TEXT_BUTTOM_PADDING + 4
#define TEXT_LABEL_LEFT_PADDING 30
#define TEXT_LABEL_RIGHT_PADDING 30

@interface ASDFGConferenceInviteCell ()
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *asoucAsdfgInfoLabel;

@property (nonatomic, strong)UIView *separateLine;
@property (nonatomic, strong)UILabel *hint;
@end

@implementation ASDFGConferenceInviteCell

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    return CGSizeMake(width, 84);
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    
    WFCCConferenceInviteMessageContent *content = (WFCCConferenceInviteMessageContent *)model.message.content;
    BOOL isChinese = [WFCCIMService.main isChinese];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@: %@",(isChinese?@"会议邀请":@"Meeting invitation"), content.title];
    if (content.startTime == 0 || content.startTime >= [[NSDate alloc] init].timeIntervalSince1970) {
        self.asoucAsdfgInfoLabel.text = (isChinese?@"会议已经开始了，请尽快加入会议。":@"The meeting has started. Please join the meeting as soon as possible.");
    } else {
        self.asoucAsdfgInfoLabel.text = (isChinese?@"会议还未开始，请准时参加。":@"The meeting hasn't started yet. Please attend on time.");
    }

    [self separateLine];
    [self hint];
}

- (UILabel *)asoucAsdfgInfoLabel {
    if (!_asoucAsdfgInfoLabel) {
        CGRect bounds = self.asoucContentArea.bounds;
        _asoucAsdfgInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 30, bounds.size.width-16, 32)];
        _asoucAsdfgInfoLabel.numberOfLines = 0;
        _asoucAsdfgInfoLabel.font = [UIFont systemFontOfSize:14];
        
        _asoucAsdfgInfoLabel.textColor = [UIColor grayColor];
        _asoucAsdfgInfoLabel.numberOfLines = 0;
        _asoucAsdfgInfoLabel.font = [UIFont systemFontOfSize:12.f];
        
        [self.asoucContentArea addSubview:_asoucAsdfgInfoLabel];
    }
    return _asoucAsdfgInfoLabel; 
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGRect bounds = self.asoucContentArea.bounds;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, bounds.size.width - 16, 18)];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont systemFontOfSize:14.f];
        
        
        [self.asoucContentArea addSubview:_titleLabel];
    }
    return _titleLabel;
}


- (UIView *)separateLine {
    if (!_separateLine) {
        CGRect bounds = self.asoucContentArea.bounds;
        _separateLine = [[UIView alloc] initWithFrame:CGRectMake(8, 64, bounds.size.width - 8 - 8, 1)];
        _separateLine.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        [self.asoucContentArea addSubview:_separateLine];
    }
    return _separateLine;
}

- (UILabel *)hint {
    if (!_hint) {
        _hint = [[UILabel alloc] initWithFrame:CGRectMake(8, 68, 80, 16)];
        _hint.font = [UIFont systemFontOfSize:8];
        _hint.text = @"Meeting";
        _hint.textColor = [UIColor grayColor];
        [self.asoucContentArea addSubview:_hint];
    }
    return _hint;
}
@end
