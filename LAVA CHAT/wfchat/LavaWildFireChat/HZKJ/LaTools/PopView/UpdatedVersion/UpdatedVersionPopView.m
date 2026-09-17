//
//  UpdatedVersionPopView.m
//  WildFireChat
//
//  Created by Ruby on 1/5/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "UpdatedVersionPopView.h"


@interface UpdatedVersionPopView ()
{
    NSString *_downloadUrl;
}
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *bgAView;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateContentLabel;

@property (weak, nonatomic) IBOutlet UIButton *aButton;

@property (weak, nonatomic) IBOutlet UIView *btnBgView;
@property (weak, nonatomic) IBOutlet UIButton *bButton;
@property (weak, nonatomic) IBOutlet UIButton *cButton;

@property (weak, nonatomic) IBOutlet UILabel *newsVersionL;

@end


@implementation UpdatedVersionPopView

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [NSBundle.mainBundle loadNibNamed:@"UpdatedVersionPopView" owner:self options:nil].lastObject;
        self.frame = ShareAppDelegate.window.frame;
        
        _downloadUrl = @"";
        _bgAView.layer.cornerRadius = 40.0;
        _versionLabel.layer.cornerRadius = 13.0;
        _versionLabel.layer.masksToBounds = YES;
        
        _aButton.layer.cornerRadius = 20.0;
        _cButton.layer.cornerRadius = 20.0;
        
        _bButton.layer.borderWidth = 1.0;
        _bButton.layer.borderColor = MAINCOLOR.CGColor;
        _bButton.layer.cornerRadius = 20.0;
        
        if ([CommonHelper.main isChinese]) {
            
        }else {
            _newsVersionL.text = @"Có phiên bản mới";
        }
        [_aButton setTitle:LLLLLL(@"UpdateNow") forState:UIControlStateNormal];
        [_bButton setTitle:LLLLLL(@"Cancel") forState:UIControlStateNormal];
        [_cButton setTitle:LLLLLL(@"UpdateNow") forState:UIControlStateNormal];
    }
    return self;
}
- (void)setIsForce:(BOOL)isForce {
    _isForce = isForce;
    if (_isForce) {
        _btnBgView.hidden = YES;
        _aButton.hidden = NO;
    }else {
        _btnBgView.hidden = NO;
        _aButton.hidden = YES;
    }
}
- (void)showVersion:(NSString *)version info:(NSString *)info download:(NSString *)download {
    [_bgView exChangeOutDur];
    [ShareAppDelegate.window addSubview:self];
    
    _versionLabel.text = UNString(@"V%@", version);
    _updateContentLabel.text = info;
    _downloadUrl = download;
}

- (IBAction)action:(UIButton *)sender {
    if (sender.tag == 0) {
        [self removeFromSuperview];
        return;
    }
    if (_downloadUrl != nil && _downloadUrl.length > 0) {
        WS(weakself)
        [[UIApplication sharedApplication] openURL:URL(_downloadUrl) options:@{} completionHandler:^(BOOL success) {
            [weakself exit];
            [weakself removeFromSuperview];
        }];
    }else {
        [self removeFromSuperview];
    }
}

- (void)exit {
    UIWindow *window = ShareAppDelegate.window;
    [UIView animateWithDuration:0.35 animations:^{
        window.alpha = 0.0;
        window.frame = CGRectMake(CGRectGetWidth(window.frame)/2, CGRectGetHeight(window.frame)/2,1,1);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

@end
