//
//  WFCFavoriteUnknownCell.m
//  WildFireChat
//
//  Created by Tom Lee on 2020/11/1.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "WFCFavoriteFileCell.h"
#import <WFChatUIKitLava/WFChatUIKit.h>


@interface WFCFavoriteFileCell ()
@property(nonatomic, strong)UIImageView *iconView;
@property(nonatomic, strong)UILabel *asoucNameLabel;
@property(nonatomic, strong)UILabel *asoucAsdfgInfoLabel;
@end

@implementation WFCFavoriteFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFavoriteItem:(QWERFavoriteItem *)favoriteItem {
    [super setFavoriteItem:favoriteItem];
    [self iconView];
    self.asoucNameLabel.text = favoriteItem.title;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[favoriteItem.data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    long size = [dict[@"size"] longValue];
    self.asoucAsdfgInfoLabel.text = [QWERUtilities formatSizeLable:size];
}

+ (CGFloat)contentHeight:(QWERFavoriteItem *)favoriteItem {
    return 56;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        _iconView.image = [UIImage imageNamed:@"file_icon"];
        _iconView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
        [self.asoucContentArea addSubview:_iconView];
    }
    return _iconView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 4, self.bounds.size.width-72, 20)];
        _asoucNameLabel.font = [UIFont systemFontOfSize:18];
        [self.asoucContentArea addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}

- (UILabel *)asoucAsdfgInfoLabel {
    if (!_asoucAsdfgInfoLabel) {
        _asoucAsdfgInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 30, self.bounds.size.width-80, 18)];
        _asoucAsdfgInfoLabel.font = [UIFont systemFontOfSize:14];
        _asoucAsdfgInfoLabel.textColor = [UIColor grayColor];
        [self.asoucContentArea addSubview:_asoucAsdfgInfoLabel];
    }
    return _asoucAsdfgInfoLabel;
}
@end
