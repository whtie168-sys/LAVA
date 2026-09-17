//
//  SendBusinessCardsPopView.m
//  LAVA
//
//  Created by Rubyuer on 10/18/23.
//

#import "SendBusinessCardsPopView.h"


@interface SendBusinessCardsPopView ()

@property (weak, nonatomic) IBOutlet UIView *oxaicsgoeBgView;
@property (weak, nonatomic) IBOutlet UILabel *oxaicsgoeCommandLabel;

@property (weak, nonatomic) IBOutlet UIImageView *oxaicsgoeImgAView;
@property (weak, nonatomic) IBOutlet UIImageView *oxaicsgoeImgBView;

@property (weak, nonatomic) IBOutlet UIButton *oxaicsgoeCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *oxaicsgoeOkButton;

@property (weak, nonatomic) IBOutlet UILabel *sendCardL;


@end

@implementation SendBusinessCardsPopView

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"SendBusinessCardsPopView" owner:self options:nil] lastObject];
        self.frame = ShareAppDelegate.window.frame;
        
        ViewRadius(_oxaicsgoeBgView, 20.0)
        ViewRadius(_oxaicsgoeImgAView, 40.0)
        ViewRadius(_oxaicsgoeImgBView, 40.0)
        ViewRadius(_oxaicsgoeCancelButton, 12.0)
        ViewRadius(_oxaicsgoeOkButton, 12.0)
        
        _sendCardL.text = LLLLLL(@"SendBusinessCard");
        [_oxaicsgoeCancelButton setTitle:LLLLLL(@"Cancel") forState:UIControlStateNormal];
        [_oxaicsgoeOkButton setTitle:LLLLLL(@"AlertButton") forState:UIControlStateNormal];
    }
    return self;
}

- (void)showCommand:(NSString *)command imgA:(NSString *)imgA imB:(NSString *)imgB {
    [_oxaicsgoeBgView exChangeOutDur];
    [ShareAppDelegate.window addSubview:self];
    
    _oxaicsgoeCommandLabel.text = command;
    NSString *placeholderImage = (_conversationType == Group_Type ? @"groupIcon" : @"PersonalChat");
    [_oxaicsgoeImgAView sd_setImageWithURL:URL(imgA) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    [_oxaicsgoeImgBView sd_setImageWithURL:URL(imgB) placeholderImage:[QWERImage imageNamed:placeholderImage]];
}


- (IBAction)act:(UIButton *)sender {
    if (sender.tag == 1) { // 确定
        if (self.cardsBlock) {
            self.cardsBlock();
        }
    }
    [self removeFromSuperview];
}


@end
