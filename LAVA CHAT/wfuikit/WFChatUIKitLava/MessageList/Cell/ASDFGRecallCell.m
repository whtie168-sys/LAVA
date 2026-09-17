//
//  InformationCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGRecallCell.h"
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

@implementation ASDFGRecallCell

+ (NSString *)recallMsg:(WFCCRecallMessageContent *)content {
    NSString *digest = [content digest:nil];
    return digest;
}
+ (CGSize)sizeForCell:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    CGFloat height = [super hightForHeaderArea:msgModel];
    NSString *infoText = [ASDFGRecallCell recallMsg:(WFCCRecallMessageContent *)msgModel.message.content];
    
    CGSize size = [QWERUtilities getTextDrawingSize:infoText font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width - TEXT_LABEL_LEFT_PADDING - TEXT_LABEL_RIGHT_PADDING - TEXT_LEFT_PADDING - TEXT_RIGHT_PADDING, 8000)];
    size.height += TEXT_LABEL_TOP_PADDING + TEXT_LABEL_BUTTOM_PADDING + TEXT_TOP_PADDING + TEXT_BUTTOM_PADDING;
    size.height += height;
    return CGSizeMake(width, size.height);
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    WFCCRecallMessageContent *content = (WFCCRecallMessageContent *)model.message.content;
    NSString *infoText = [ASDFGRecallCell recallMsg:(WFCCRecallMessageContent *)model.message.content];
    CGFloat width = self.contentView.bounds.size.width;
    
    
    CGFloat reeditBtnWidth = 0;
    
    if (content.originalContentType == MESSAGE_CONTENT_TYPE_TEXT && [content.originalSender isEqualToString:[WFCCNetworkService sharedInstance].userId] && content.originalSearchableContent.length > 0) {
        CGSize btnsize = [QWERUtilities getTextDrawingSize:self.asoucReeditButton.titleLabel.text font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width - TEXT_LABEL_LEFT_PADDING - TEXT_LABEL_RIGHT_PADDING - TEXT_LEFT_PADDING - TEXT_RIGHT_PADDING, 8000)];
        
        reeditBtnWidth = btnsize.width + 4;
    }
    
    
    CGSize size = [QWERUtilities getTextDrawingSize:infoText font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width - TEXT_LABEL_LEFT_PADDING - TEXT_LABEL_RIGHT_PADDING - TEXT_LEFT_PADDING - TEXT_RIGHT_PADDING, 8000)];
    
    
    self.asoucAsdfgInfoLabel.text = infoText;
    
    self.asoucAsdfgInfoLabel.layoutMargins = UIEdgeInsetsMake(TEXT_TOP_PADDING, TEXT_LEFT_PADDING, TEXT_BUTTOM_PADDING, TEXT_RIGHT_PADDING);
    CGFloat timeLableEnd = 0;
    if (!self.timeLabel.hidden) {
        timeLableEnd = self.timeLabel.frame.size.height + self.timeLabel.frame.origin.y;
    }
    self.asoucRecallContainer.frame = CGRectMake((width - size.width - reeditBtnWidth)/2 - 8, timeLableEnd + TEXT_LABEL_TOP_PADDING, size.width + reeditBtnWidth + 16, size.height + TEXT_TOP_PADDING + TEXT_BUTTOM_PADDING);
    
    self.asoucAsdfgInfoLabel.frame = CGRectMake(8, TEXT_BUTTOM_PADDING, size.width, size.height);
    if (reeditBtnWidth) {
        self.asoucReeditButton.frame = CGRectMake(size.width + 8, TEXT_BUTTOM_PADDING, reeditBtnWidth, size.height);
        self.asoucReeditButton.hidden = NO;
    } else {
        self.asoucReeditButton.hidden = YES;
    }
    
}

- (void)onReeditBtn:(id)sender {
    [self.delegate reeditRecalledMessage:self withModel:self.model];
}

- (UILabel *)asoucAsdfgInfoLabel {
    if (!_asoucAsdfgInfoLabel) {
        _asoucAsdfgInfoLabel = [[UILabel alloc] init];
        _asoucAsdfgInfoLabel.numberOfLines = 0;
        _asoucAsdfgInfoLabel.font = [UIFont systemFontOfSize:14];
        
        _asoucAsdfgInfoLabel.textColor = [UIColor whiteColor];
        _asoucAsdfgInfoLabel.numberOfLines = 0;
        _asoucAsdfgInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _asoucAsdfgInfoLabel.textAlignment = NSTextAlignmentCenter;
        _asoucAsdfgInfoLabel.font = [UIFont systemFontOfSize:14.f];
        _asoucAsdfgInfoLabel.textAlignment = NSTextAlignmentCenter;
        _asoucAsdfgInfoLabel.backgroundColor = [UIColor clearColor];
        
        [self.asoucRecallContainer addSubview:_asoucAsdfgInfoLabel];
    }
    return _asoucAsdfgInfoLabel;
}

- (UIButton *)asoucReeditButton {
    if (!_asoucReeditButton) {
        _asoucReeditButton = [[UIButton alloc] init];
        BOOL isChinese = [WFCCIMService.main isChinese];
        [_asoucReeditButton setTitle:(isChinese ? @"重新编辑" : @"Sửa lại") forState:UIControlStateNormal];
        [_asoucReeditButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_asoucReeditButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [_asoucReeditButton addTarget:self action:@selector(onReeditBtn:) forControlEvents:UIControlEventTouchDown];
        [_asoucReeditButton setBackgroundColor:[UIColor clearColor]];
        _asoucReeditButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.asoucRecallContainer addSubview:_asoucReeditButton];
    }
    return _asoucReeditButton;
}

- (UIView *)asoucRecallContainer {
    if (!_asoucRecallContainer) {
        _asoucRecallContainer = [[UIView alloc] init];
        _asoucRecallContainer.backgroundColor = [UIColor colorWithRed:201/255.f green:201/255.f blue:201/255.f alpha:1.f];
        _asoucRecallContainer.layer.masksToBounds = YES;
        _asoucRecallContainer.layer.cornerRadius = 5.f;
        [self.contentView addSubview:_asoucRecallContainer];
    }
    return _asoucRecallContainer;
}
@end
