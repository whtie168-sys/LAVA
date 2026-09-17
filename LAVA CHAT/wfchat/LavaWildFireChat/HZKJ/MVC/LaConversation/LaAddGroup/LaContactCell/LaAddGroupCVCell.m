//
//  LaAddGroupCVCell.m
//  LAVA
//
//  Created by Rubyuer on 10/13/23.
//

#import "LaAddGroupCVCell.h"

@interface LaAddGroupCVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *oxgcseoaiIconView;
@property (weak, nonatomic) IBOutlet UILabel *oxgcseoaiasoucNameLabel;


@end
@implementation LaAddGroupCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    ViewRadius(_oxgcseoaiIconView, 20.0);
}

- (void)setModel:(WFCCUserInfo *)model {
    _model = model;
    
    [_oxgcseoaiIconView sd_setImageWithURL:URL(_model.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                   context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    _oxgcseoaiasoucNameLabel.text = (_model.friendAlias.length > 0 ? _model.friendAlias : _model.displayName);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.oxgcseoaiIconView sd_cancelCurrentImageLoad];
    self.oxgcseoaiIconView.image = nil;
}

@end
