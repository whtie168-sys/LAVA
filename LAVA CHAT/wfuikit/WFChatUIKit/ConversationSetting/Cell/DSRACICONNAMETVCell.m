//
//  DSRACICONNAMETVCell.m
//  WFChatUIKit
//
//  Created by Ruby on 11/24/23.
//  Copyright © 2023 Tom Lee. All rights reserved.
//

#import "DSRACICONNAMETVCell.h"
#import "SDWebImage/SDWebImage.h"

@implementation DSRACICONNAMETVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.asoucNameLabel];
    }
    return self;
}


- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 10.0, 40.0, 40.0)];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.layer.cornerRadius = 20.0;
        _iconView.layer.masksToBounds = YES;
    }return _iconView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 15.0, UIScreen.mainScreen.bounds.size.width - 80.0, 30.0)];
        _asoucNameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0];
        _asoucNameLabel.textAlignment = NSTextAlignmentLeft;
        _asoucNameLabel.textColor = UIColor.blackColor;
    }return _asoucNameLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView sd_cancelCurrentImageLoad];
    self.iconView.image = nil;
}

@end
