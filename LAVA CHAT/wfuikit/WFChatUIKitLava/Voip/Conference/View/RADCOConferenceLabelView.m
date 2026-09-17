//
//  ConferenceLabelView.m
//  WFZoom
//
//  Created by Tom Lee on 2021/9/22.
//

#import "RADCOConferenceLabelView.h"
#import "QWERUtilities.h"
#import "QWERImage.h"

@interface RADCOConferenceLabelView ()
@property(nonatomic, strong)UIImageView *audioView;
@property(nonatomic, strong)UILabel *asoucNameLabel;
@end

@implementation RADCOConferenceLabelView

//size 100*28
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setIsMuteAudio:(BOOL)isMuteAudio {
    _isMuteAudio = isMuteAudio;
    if(isMuteAudio) {
        self.audioView.image = [QWERImage imageNamed:@"mic_mute"];
    } else {
        self.volume = _volume;
    }
}

- (void)setVolume:(NSInteger)volume {
    _volume = volume;
    if(self.isMuteAudio)
        return;
    
    int v = (int)(volume/1000);
    if(v < 0) {
        v = 0;
    }
    if(v > 10) {
        v = 10;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.audioView.image = [QWERImage imageNamed:[NSString stringWithFormat:@"mic_%d", v]];
    }];
}

- (void)setName:(NSString *)name {
    _name = name;
    self.asoucNameLabel.text = name;
    CGSize size = [QWERUtilities getTextDrawingSize:name font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(1000, 20)];
    CGRect frame = self.asoucNameLabel.frame;
    frame.size.width = size.width;
    self.asoucNameLabel.frame = frame;
    frame = self.frame;
    frame.size.width = 28 + size.width + 4;
    self.frame = frame;
}

- (UIImageView *)audioView {
    if (!_audioView) {
        _audioView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 20, 20)];
        [self addSubview:_audioView];
    }
    return _audioView;
}

- (UILabel *)asoucNameLabel {
    if(!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 4, 48, 20)];
        _asoucNameLabel.font = [UIFont systemFontOfSize:14];
        _asoucNameLabel.textColor = [UIColor grayColor];
        [self addSubview:_asoucNameLabel];
    }
    return _asoucNameLabel;
}
+ (CGSize)sizeOffView {
    return CGSizeMake(100, 28);
}
@end
