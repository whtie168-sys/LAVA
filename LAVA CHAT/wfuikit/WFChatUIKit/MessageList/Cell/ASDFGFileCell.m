//
//  FileCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGFileCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERUtilities.h"
#import "UIFont+YH.h"

@implementation ASDFGFileCell
+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    return CGSizeMake(width*4/5, 50);
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    WFCCFileMessageContent *fileContent = (WFCCFileMessageContent *)model.message.content;
    
    NSString *ext = [[fileContent.name pathExtension] lowercaseString];
    
    
    CGRect bounds = self.asoucContentArea.bounds;
    if (model.message.direction == MessageDirection_Send) {
        self.asoucFileImageView.frame = CGRectMake(bounds.size.width - 40, 4, 36, 42);
        self.asoucFileasoucNameLabel.frame = CGRectMake(4, 4, bounds.size.width - 48, 22);
        self.asoucSizeLabel.frame = CGRectMake(4, 30, bounds.size.width - 48, 15);
        self.asoucSizeLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.asoucFileImageView.frame = CGRectMake(4, 4, 36, 42);
        self.asoucFileasoucNameLabel.frame = CGRectMake(44, 4, bounds.size.width - 48, 22);
        self.asoucSizeLabel.frame = CGRectMake(44, 30, bounds.size.width - 48, 15);
        self.asoucSizeLabel.textAlignment = NSTextAlignmentRight;
    }
    
    self.asoucFileImageView.image = [QWERUtilities imageForExt:ext];
    self.asoucFileasoucNameLabel.text = fileContent.name;
    self.asoucSizeLabel.text = [QWERUtilities formatSizeLable:fileContent.size];
}

- (UIView *)getProgressParentView {
    return self.asoucFileImageView;
}

- (UIImageView *)asoucFileImageView {
    if (!_asoucFileImageView) {
        _asoucFileImageView = [[UIImageView alloc] init];
        [self.asoucContentArea addSubview:_asoucFileImageView];
    }
    return _asoucFileImageView;
}

- (UILabel *)asoucFileasoucNameLabel {
    if (!_asoucFileasoucNameLabel) {
        _asoucFileasoucNameLabel = [[UILabel alloc] init];
        _asoucFileasoucNameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16.0];
        [_asoucFileasoucNameLabel setTextColor:[UIColor blackColor]];
        [self.asoucContentArea addSubview:_asoucFileasoucNameLabel];
    }
    return _asoucFileasoucNameLabel;
}
- (UILabel *)asoucSizeLabel {
    if (!_asoucSizeLabel) {
        _asoucSizeLabel = [[UILabel alloc] init];
        _asoucSizeLabel.font =  [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13.0];
        [self.asoucContentArea addSubview:_asoucSizeLabel];
    }
    return _asoucSizeLabel;
}
@end
