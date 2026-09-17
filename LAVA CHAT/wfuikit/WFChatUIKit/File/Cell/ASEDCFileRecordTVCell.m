//
//  FileRecordTableViewCell.m
//  WFChatUIKit
//
//  Created by dali on 2020/10/29.
//  Copyright © 2020 Wildfirechat. All rights reserved.
//

#import "ASEDCFileRecordTVCell.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERUtilities.h"


@interface ASEDCFileRecordTVCell ()
@property(nonatomic, strong)UIImageView *iconView;
@property(nonatomic, strong)UILabel *asoucNameLabel;
@property(nonatomic, strong)UILabel *asoucAsdfgInfoLabel;
@end

@implementation ASEDCFileRecordTVCell

+ (CGFloat)sizeOfRecord:(WFCCFileRecord *)record withCellWidth:(CGFloat)width {
    CGSize size1 = [QWERUtilities getTextDrawingSize:record.name font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake(width - 74, 48)];
    
    NSString *info = [NSString stringWithFormat:@"%@ đến từ %@ %@", [QWERUtilities formatTimeLabel:record.timestamp], [[WFCCIMService sharedWFCIMService] getUserInfo:record.userId inGroup:record.conversation.type == Group_Type ? record.conversation.target : nil refresh:NO].displayName, [QWERUtilities formatSizeLable:record.size]];
    
    
    CGSize size2 = [QWERUtilities getTextDrawingSize:info font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width - 74, 40)];
    
    return 8 + size1.height + 8 + size2.height + 8;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

- (void)setFileIcon:(NSString *)fileName {
    NSString *ext = [[fileName pathExtension] lowercaseString];
    self.iconView.image = [QWERUtilities imageForExt:ext];
}

- (void)setFileRecord:(WFCCFileRecord *)fileRecord {
    _fileRecord = fileRecord;
    
    [self setFileIcon:fileRecord.name];
    self.asoucNameLabel.text = self.fileRecord.name;
    CGSize size = [QWERUtilities getTextDrawingSize:self.fileRecord.name font:[UIFont systemFontOfSize:18] constrainedSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 74, 48)];
    self.asoucNameLabel.frame = CGRectMake(66, 8, size.width, size.height);
    
    NSString *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:fileRecord.userId inGroup:fileRecord.conversation.type == Group_Type ? fileRecord.conversation.target : nil refresh:NO].displayName;
    if(!sender.length) {
        sender = fileRecord.userId;
    }
    
    NSString *info = [NSString stringWithFormat:@"%@ đến từ ", [QWERUtilities formatTimeLabel:fileRecord.timestamp]];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:info];
    [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:sender attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}]];
    [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", [QWERUtilities formatSizeLable:fileRecord.size]]]];
    
    self.asoucAsdfgInfoLabel.attributedText = attStr;
    
//    size = [QWERUtilities getTextDrawingSize:attStr.string font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(self.bounds.size.width - 74, 40)];
    self.asoucAsdfgInfoLabel.frame = CGRectMake(66, self.asoucNameLabel.frame.origin.y + self.asoucNameLabel.frame.size.height + 5, [UIScreen mainScreen].bounds.size.width - 80.0, 24.0);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 50, 50)];
        [self.contentView addSubview:_iconView];
    }
    return _iconView;;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] init];
        _asoucNameLabel.font = [UIFont systemFontOfSize:18];
        _asoucNameLabel.numberOfLines = 0;
        [self.contentView addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}

- (UILabel *)asoucAsdfgInfoLabel {
    if (!_asoucAsdfgInfoLabel) {
        _asoucAsdfgInfoLabel = [[UILabel alloc] init];
        _asoucAsdfgInfoLabel.font = [UIFont systemFontOfSize:14];
        _asoucAsdfgInfoLabel.numberOfLines = 1;
        _asoucAsdfgInfoLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_asoucAsdfgInfoLabel];
    }
    return _asoucAsdfgInfoLabel;
}
@end
