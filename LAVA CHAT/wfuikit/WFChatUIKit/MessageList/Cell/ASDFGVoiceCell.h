//
//  VoiceCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGMediaMessageCell.h"

#define kVoiceMessageStartPlaying @"kVoiceMessageStartPlaying"
#define kVoiceMessagePlayStoped @"kVoiceMessagePlayStoped"


@interface ASDFGVoiceCell : ASDFGMediaMessageCell
@property (nonatomic, strong)UIImageView *asouVoiceBtn;
@property (nonatomic, strong)UILabel *asouDurationLabel;
@property (nonatomic, strong)UIView *asouUnplayedView;
@end
