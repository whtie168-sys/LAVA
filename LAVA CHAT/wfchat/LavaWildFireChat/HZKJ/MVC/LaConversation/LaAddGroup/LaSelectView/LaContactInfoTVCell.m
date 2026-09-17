//
//  LaContactInfoTVCell.m
//  LAVA
//
//  Created by Rubyuer on 10/22/23.
//

#import "LaContactInfoTVCell.h"

@interface LaContactInfoTVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *oxgcseoaiIconView;
@property (weak, nonatomic) IBOutlet UILabel *oxgcseoaiasoucNameLabel;

@end

@implementation LaContactInfoTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    ViewRadius(_oxgcseoaiIconView, 20.0);
}

- (void)setModel:(WFCCUserInfo *)model {
    _model = model;

    _oxgcseoaiSelectButton.selected = _model.isSelect;
    [_oxgcseoaiIconView sd_setImageWithURL:URL(_model.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                   context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    _oxgcseoaiasoucNameLabel.text = _model.friendAlias.length > 0 ? _model.friendAlias : _model.displayName;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.oxgcseoaiIconView sd_cancelCurrentImageLoad];
    self.oxgcseoaiIconView.image = nil;
}
@end
