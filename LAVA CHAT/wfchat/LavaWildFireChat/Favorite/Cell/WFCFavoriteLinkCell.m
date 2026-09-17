//
//  WFCFavoriteUnknownCell.m
//  WildFireChat
//
//  Created by Tom Lee on 2020/11/1.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCFavoriteLinkCell.h"
#import <WFChatUIKitLava/WFChatUIKit.h>


@interface WFCFavoriteLinkCell ()
@property(nonatomic, strong)UIImageView *iconView;
@property(nonatomic, strong)UILabel *asoucNameLabel;
@end

@implementation WFCFavoriteLinkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFavoriteItem:(QWERFavoriteItem *)favoriteItem {
    [super setFavoriteItem:favoriteItem];
    [self iconView];
    
    
    self.asoucNameLabel.text = favoriteItem.title;
}

+ (CGFloat)contentHeight:(QWERFavoriteItem *)favoriteItem {
    return 60;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        _iconView.image = [UIImage imageNamed:@"default_link"];
        _iconView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
        [self.asoucContentArea addSubview:_iconView];
    }
    return _iconView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 4, self.bounds.size.width-72, 56)];
        _asoucNameLabel.font = [UIFont systemFontOfSize:18];
        _asoucNameLabel.numberOfLines = 0;
        [self.asoucContentArea addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}

@end
