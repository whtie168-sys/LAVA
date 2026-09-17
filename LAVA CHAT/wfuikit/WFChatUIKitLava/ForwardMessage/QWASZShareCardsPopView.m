//
//  SendBusinessCardsPopView.m
//  LAVA
//
//  Created by Rubyuer on 10/18/23.
//

#import "QWASZShareCardsPopView.h"
#import <SDWebImage/SDWebImage.h>
#import "QWERImage.h"



@interface QWASZShareCardsPopView ()

@property (weak, nonatomic) IBOutlet UIView *oxaicsgoeBgView;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeCommandLabel;

@property (weak, nonatomic) IBOutlet UIImageView *oxaicsgoeImgAView;
@property (weak, nonatomic) IBOutlet UIImageView *oxaicsgoeImgBView;

@property (weak, nonatomic) IBOutlet UIButton *oxaicsgoeCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *oxaicsgoeOkButton;

@end

@implementation QWASZShareCardsPopView

- (instancetype)init {
    self = [super init];
    if (self) {
//        self = [[[NSBundle mainBundle] loadNibNamed:@"QWASZShareCardsPopView" owner:self options:nil] lastObject];
        self = [[NSBundle bundleForClass:[QWASZShareCardsPopView class]] loadNibNamed:@"QWASZShareCardsPopView" owner:self options:nil].firstObject;
        
        self.frame = ([UIApplication sharedApplication].delegate).window.frame;
        
        _oxaicsgoeBgView.layer.cornerRadius = 20.0;
        _oxaicsgoeImgAView.layer.cornerRadius = 40.0;
        _oxaicsgoeImgBView.layer.cornerRadius = 40.0;
        _oxaicsgoeCancelButton.layer.cornerRadius = 12.0;
        _oxaicsgoeOkButton.layer.cornerRadius = 12.0;
    }
    return self;
}

- (void)showCommand:(NSString *)command imgA:(NSString *)imgA imB:(NSString *)imgB {
    [self exChangeOutDur:_oxaicsgoeBgView];
    [([UIApplication sharedApplication].delegate).window addSubview:self];
    
    _oxaicsgoeCommandLabel.text = command;
    [_oxaicsgoeImgAView sd_setImageWithURL:[NSURL URLWithString:[imgA stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    [_oxaicsgoeImgBView sd_setImageWithURL:[NSURL URLWithString:[imgB stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
}


- (IBAction)act:(UIButton *)sender {
    if (sender.tag == 1) { // 确定
        if (self.cardsBlock) {
            self.cardsBlock();
        }
    }
    [self removeFromSuperview];
}



- (void)exChangeOutDur:(UIView *)bgView {
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = 0.35;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    
    [bgView.layer addAnimation:animation forKey:nil];
}

@end
