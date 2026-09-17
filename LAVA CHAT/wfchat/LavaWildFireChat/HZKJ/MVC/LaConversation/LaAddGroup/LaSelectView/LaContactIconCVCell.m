//
//  LaContactIconCVCell.m
//  LAVA
//
//  Created by Rubyuer on 10/13/23.
//

#import "LaContactIconCVCell.h"

@interface LaContactIconCVCell ()



@end
@implementation LaContactIconCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    ViewRadius(_oxgcseoaiIconView, 20.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.oxgcseoaiIconView sd_cancelCurrentImageLoad];
    self.oxgcseoaiIconView.image = nil;
}


@end
