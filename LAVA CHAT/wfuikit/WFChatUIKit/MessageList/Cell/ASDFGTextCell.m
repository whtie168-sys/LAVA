//
//  TextCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGTextCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERUtilities.h"
#import "WSEDCAttributedLabel.h"
#import "UIFont+YH.h"

#define TEXT_LABEL_TOP_PADDING 3
#define TEXT_LABEL_BUTTOM_PADDING 5

@interface ASDFGTextCell () <WSEDCAttributedLabelDelegate>

@end

@implementation ASDFGTextCell

+ (UIFont *)defaultFont {
    NSInteger fontSize = [NSUserDefaults.standardUserDefaults integerForKey:@"kFontSize"];
    return [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
//    return [UIFont systemFontOfSize:fontSize];
}

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)msgModel.message.content;
    CGSize size = [QWERUtilities getTextDrawingSize:txtContent.text font:[ASDFGTextCell defaultFont] constrainedSize:CGSizeMake(width, 8000)];
    size.height += TEXT_LABEL_TOP_PADDING + TEXT_LABEL_BUTTOM_PADDING;
    if (size.width < 40) {
        size.width += 4;
        if (size.width > 40) {
            size.width = 40;
        } else if (size.width < 24) {
            size.width = 24;
        }
    }
  return size;
}

- (void)setModel:(QWERTMessageModel *)model {
  [super setModel:model];
    
  WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)model.message.content;
    CGRect frame = self.asoucContentArea.bounds;
  self.asofaTextLabel.frame = CGRectMake(0, TEXT_LABEL_TOP_PADDING, frame.size.width, frame.size.height - TEXT_LABEL_TOP_PADDING - TEXT_LABEL_BUTTOM_PADDING);
    self.asofaTextLabel.textAlignment = NSTextAlignmentLeft;
    [self.asofaTextLabel setText:txtContent.text];
}

- (WSEDCAttributedLabel *)asofaTextLabel {
    if (!_asofaTextLabel) {
        _asofaTextLabel = [[WSEDCAttributedLabel alloc] init];
        _asofaTextLabel.attributedLabelDelegate = self;
        _asofaTextLabel.numberOfLines = 0;
        _asofaTextLabel.font = [ASDFGTextCell defaultFont];
        _asofaTextLabel.userInteractionEnabled = YES;
        [self.asoucContentArea addSubview:_asofaTextLabel];
    }
    return _asofaTextLabel;
}

#pragma mark - WSEDCAttributedLabelDelegate
- (void)didSelectUrl:(NSString *)urlString {
    [self.delegate didSelectUrl:self withModel:self.model withUrl:urlString];
}
- (void)didSelectPhoneNumber:(NSString *)phoneNumberString {
    [self.delegate didSelectPhoneNumber:self withModel:self.model withPhoneNumber:phoneNumberString];
}
@end
