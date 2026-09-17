//
//  LaCallosTVCell.m
//  WildFireChat
//
//  Created by Ruby on 11/6/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaCallosTVCell.h"

@interface LaCallosTVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowView;

@end

@implementation LaCallosTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _iconView.layer.cornerRadius = 25.0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _stateButton.hidden = YES;
    _iconLeft.constant = 20.0;
}
/*
 createdTime = 1700560070124;
id = b144e8ff25cf83561965d9b05c5c35b6;
jsonObject =             {
    callType = 0;
    "call_out_in" = 1;
    status = 1;
    targetId = 2ygqmws2k;
    time = 0;
};
type = 0;
userId = 9ygqmws2k;
 */
- (void)setAudioModel:(AddAudioModel *)audioModel {
    _audioModel = audioModel;
//    NSLog(@"JSON====%@",audioModel.mj_JSONObject);
    WFCCUserInfo *targetUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:audioModel.jsonObject.targetId refresh:NO];
    [_iconView sd_setImageWithURL:URL(targetUserInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                          context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    _asoucNameLabel.text = targetUserInfo.friendAlias.length > 0 ? targetUserInfo.friendAlias : targetUserInfo.displayName;
    
    if (audioModel.jsonObject.callType == 0) { // 语音
        NSString *image = (audioModel.jsonObject.status == 0 ? @"cseoaixgoVoiceN" : @"cseoaixgoVoiceS");
        _typeView.image = [UIImage imageNamed:image];
    }else { // 视频  status 状态 0 已取消(包括对方挂断)。1 未接听
        NSString *image = (audioModel.jsonObject.status == 0 ? @"cseoaixgoVideoN" : @"cseoaixgoVideoS");
        _typeView.image = [UIImage imageNamed:image];
    }
    
    
    if (audioModel.jsonObject.time > 0) { // 已接听状态
        long sec = audioModel.jsonObject.time;
        if (sec < 60 * 60) {
            _descLabel.text = [NSString stringWithFormat:@"%@ %02ld:%02ld",LLLLLL(@"CallDuration"), sec/60, sec%60];
        } else {
            _descLabel.text = [NSString stringWithFormat:@"%@ %02ld:%02ld:%02ld",LLLLLL(@"CallDuration"), sec/60/60, (sec/60)%60, sec%60];
        }
        _descLabel.textColor = RGBA(0x9D9D9D);
    }else {
        _descLabel.text = (audioModel.jsonObject.status == 0 ? LLLLLL(@"Cancelled") : LLLLLL(@"Unanswered"));
        _descLabel.textColor = (audioModel.jsonObject.status == 0 ? RGBA(0x9D9D9D) : RGBA(0xEB0022));
    }
    
    _dateLabel.text = [UNString(@"%lld", audioModel.createdTime) timeIntervalDateFormat:@"MM-dd HH:mm"];
    
    NSString *arrowImg = @"";
    if (audioModel.jsonObject.call_out_in == 0) { // 0 呼出。 1 呼入
        arrowImg = (audioModel.jsonObject.status == 0 ? @"cseoaixgoTopGray" : @"cseoaixgoTopRed");
    }else {
        arrowImg = (audioModel.jsonObject.status == 0 ? @"cseoaixgoBottomGray" : @"cseoaixgoBottomRed");
    }
    _arrowView.image = [UIImage imageNamed:arrowImg];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView sd_cancelCurrentImageLoad];
    self.iconView.image = nil;
}


@end
