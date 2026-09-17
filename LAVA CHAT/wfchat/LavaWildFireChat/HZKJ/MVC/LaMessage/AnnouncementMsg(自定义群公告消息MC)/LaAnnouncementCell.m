//
//  LaAnnouncementCell.m
//  WildFireChat
//
//  Created by Ruby on 11/30/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaAnnouncementCell.h"
#import "LaAnnouncementMessageContent.h"

#define TEXT_LABEL_TOP_PADDING 3
#define TEXT_LABEL_BUTTOM_PADDING 5

@interface LaAnnouncementCell ()<WSEDCAttributedLabelDelegate, UITextViewDelegate>

@property (strong, nonatomic) UILabel *asofaTextLabel;
@property (strong, nonatomic) UITextView *textView;

@property (nonatomic, strong) UIImageView *flagImgView;
@property (nonatomic, strong) UILabel *announcementLabel;
@property (nonatomic, strong) UIImageView *arrowImgView;

@end

@implementation LaAnnouncementCell

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    LaAnnouncementMessageContent *txtContent = (LaAnnouncementMessageContent *)msgModel.message.content;
    CGSize size = [QWERUtilities getTextDrawingSize:txtContent.text font:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13.0] constrainedSize:CGSizeMake(width-5.0, 8000)];
    size.height += 52.0;
    size.width = width-5.0;
    return size;
}

- (void)setModel:(QWERTMessageModel *)model {
    [super setModel:model];
    
    LaAnnouncementMessageContent *txtContent = (LaAnnouncementMessageContent *)model.message.content;
    CGRect frame = self.asoucContentArea.bounds;
    self.asofaTextLabel.frame = CGRectMake(5.0, 40.0, frame.size.width-5.0, frame.size.height - TEXT_LABEL_TOP_PADDING - TEXT_LABEL_BUTTOM_PADDING - 40.0);
    self.asofaTextLabel.textAlignment = NSTextAlignmentLeft;
    [self.asofaTextLabel setText:txtContent.text];
    
    [self flagImgView];
    [self announcementLabel];
    [self arrowImgView];
}

- (UILabel *)asofaTextLabel {
    if (!_asofaTextLabel) {
        _asofaTextLabel = [[WSEDCAttributedLabel alloc] init];
        _asofaTextLabel.numberOfLines = 0;
        _asofaTextLabel.userInteractionEnabled = YES;
        _asofaTextLabel.textColor = RGBA(0x222222);
        _asofaTextLabel.textAlignment = NSTextAlignmentLeft;
        ((WSEDCAttributedLabel*)_asofaTextLabel).attributedLabelDelegate = self;
        _asofaTextLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13.0];
        [self.asoucContentArea addSubview:_asofaTextLabel];
    }
    return _asofaTextLabel;
}


- (UIImageView *)flagImgView {
    if (!_flagImgView) {
        _flagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 8.0, 21.0, 21.0)];
        _flagImgView.image = IMAGENAME(@"oxgcseoai群公告flag");
        [self.asoucContentArea addSubview:_flagImgView];
    }
    return _flagImgView;
}
- (UILabel *)announcementLabel {
    if (!_announcementLabel) {
        _announcementLabel = [[UILabel alloc] initWithFrame:CGRectMake(34.0, 8.0, 120.0, 21.0)];
        _announcementLabel.text = LLLLLL(@"GroupAnnouncement");
        _announcementLabel.textColor = RGBA(0x4478EC);
        _announcementLabel.textAlignment = NSTextAlignmentLeft;
        _announcementLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14.0];
        [self.asoucContentArea addSubview:_announcementLabel];
    }return _announcementLabel;
}
- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        CGRect bounds = self.asoucContentArea.bounds;
        _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(bounds.size.width - 15.0, 12.5, 6.0, 12.0)];
        _arrowImgView.image = IMAGENAME(@"oxgcseoaiBlueArrow");
        [self.asoucContentArea addSubview:_arrowImgView];
    }
    return _arrowImgView;
}



#pragma mark - WSEDCAttributedLabelDelegate
- (void)didSelectUrl:(NSString *)urlString {
    [self.delegate didSelectUrl:self withModel:self.model withUrl:urlString];
}
- (void)didSelectPhoneNumber:(NSString *)phoneNumberString {
    [self.delegate didSelectPhoneNumber:self withModel:self.model withPhoneNumber:phoneNumberString];
}

@end
