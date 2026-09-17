//
//  RWADCGroupMemberTVCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/18.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "RWADCGroupMemberTVCell.h"
#import "QWERImage.h"


@implementation RWADCGroupMemberTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}
- (void)initSubViews {
    self.trewqPortraitView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 48, 48)];
    self.groupNameView = [[UILabel alloc] initWithFrame:CGRectMake(56, 8, 150, 24)];
    if (self.isSelectable) {
        
    }
    [self.trewqPortraitView setImage:[QWERImage imageNamed:@"PersonalChat"]];
    
    
    [self.contentView addSubview:self.trewqPortraitView];
    [self.contentView addSubview:_groupNameView];
    
}

- (void)setIsSelectable:(BOOL)isSelectable {
    _isSelectable = isSelectable;
    if (isSelectable) {
        if (self.selectView == nil) {
            self.selectView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 32, 8, 20, 20)];
            self.selectView.image = [QWERImage imageNamed:@"multi_unselected"];
            [self.contentView addSubview:self.selectView];
        }
    } else {
        if (self.selectView) {
            [self.selectView removeFromSuperview];
            self.selectView = nil;
        }
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (!self.isSelectable) {
        self.isSelectable = YES;
    }
    
    if (isSelected) {
        self.selectView.image = [QWERImage imageNamed:@"multi_selected"];
    } else {
        self.selectView.image = [QWERImage imageNamed:@"multi_unselected"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
