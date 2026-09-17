//
//  LaNewsFriendTVCell.m
//  LAVA
//
//  Created by Rubyuer on 10/19/23.
//

#import "LaNewsFriendTVCell.h"

@interface LaNewsFriendTVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *oxgcseoaiIconView;
@property (weak, nonatomic) IBOutlet UILabel *oxgcseoaiasoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oxgcseoaiTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *oxgcseoaiDescLabel;

@property (weak, nonatomic) IBOutlet UIButton *oxgcseoaiInviteButton;

@end

@implementation LaNewsFriendTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    ViewRadius(_oxgcseoaiIconView, 25.0)
    ViewRadius(_oxgcseoaiInviteButton, 12.0)
}

- (void)setFriendRequest:(WFCCFriendRequest *)friendRequest {
    _friendRequest = friendRequest;
    
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:friendRequest.target refresh:NO];
    [self.oxgcseoaiIconView sd_setImageWithURL:URL(userInfo.portrait) placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    self.oxgcseoaiasoucNameLabel.text = userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName;
    self.oxgcseoaiDescLabel.text = friendRequest.reason;
    self.oxgcseoaiTimeLabel.text = UNString(@"(%@)", [UNString(@"%lld", _friendRequest.timestamp) timeIntervalDateFormat:@"MM-dd HH:mm"]);
    BOOL expired = NO;
    if (NSDate.date.timeIntervalSince1970*1000 - friendRequest.timestamp > 7 * 24 * 60 * 60 * 1000) {
        expired = YES;
    }
    //0 未处理。1 已同意。2 已拒绝
    //@[@"待处理", @"已过期", @"已处理"]
    if (friendRequest.status == 0) {
        if (expired) { //expired
            _oxgcseoaiInviteButton.selected = YES;
            _oxgcseoaiInviteButton.backgroundColor = RGBA(0xF6F6F6);
            _oxgcseoaiInviteButton.titleLabel.font = PINGFANG_R(11);
            [_oxgcseoaiInviteButton setTitle:LLLLLL(@"Expired") forState:UIControlStateNormal];
        }else {
            _oxgcseoaiInviteButton.selected = NO;
            _oxgcseoaiInviteButton.backgroundColor = MAINCOLOR;
            _oxgcseoaiInviteButton.titleLabel.font = PINGFANG_M(18);
            [_oxgcseoaiInviteButton setTitle:@"✓" forState:UIControlStateNormal];
        }
    }else { // friendRequest.status == 1   2
        _oxgcseoaiInviteButton.selected = YES;
        _oxgcseoaiInviteButton.backgroundColor = RGBA(0xF6F6F6);
        _oxgcseoaiInviteButton.titleLabel.font = PINGFANG_R(11);
        [_oxgcseoaiInviteButton setTitle:(friendRequest.status == 1 ? LLLLLL(@"Agreed") : LLLLLL(@"Rejected")) forState:UIControlStateNormal];
    }
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.oxgcseoaiIconView sd_cancelCurrentImageLoad];
    self.oxgcseoaiIconView.image = nil;
}
@end
