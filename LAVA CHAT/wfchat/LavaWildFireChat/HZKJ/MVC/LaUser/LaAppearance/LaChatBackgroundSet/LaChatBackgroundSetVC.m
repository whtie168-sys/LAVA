//
//  LaChatBackgroundSetVC.m
//  WildFireChat
//
//  Created by Rubyuer on 8/12/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaChatBackgroundSetVC.h"

@interface LaChatBackgroundSetVC ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoPreviewFL;

@property (weak, nonatomic) IBOutlet UIView *ceoxsoChatBgV;
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoBgImgV;
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoBubbleColorImgV;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoTextAL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoTextBL;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoAlphaFL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoMinFL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoMaxFL;
@property (weak, nonatomic) IBOutlet UISlider *ceoxsoAlphaSlider;

@property (nonatomic, assign) NSInteger ceoxsoChatBgColorIndex;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoBgColorFL;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoColorABtn;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoColorBBtn;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoColorCBtn;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoColorDBtn;

@end

@implementation LaChatBackgroundSetVC

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_chatBackgroundSet) {
        _chatBackgroundSet(_ceoxsoAlphaSlider.value, _ceoxsoChatBgColorIndex);
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    self.navigationItem.title = (_isChinese?@"聊天背景":@"Trò chuyện nền tảng");
    
    _ceoxsoChatBgV.layer.cornerRadius = 15.0;
    _ceoxsoChatBgV.layer.borderWidth = 0.67;
    _ceoxsoChatBgV.layer.borderColor = RGBA(0xF6F6F6).CGColor;
    
    _ceoxsoBgImgV.image = IMAGENAME((UNString(@"erovaeChatBgImg%ld", _ceoxsoChatBgImgIndex)));
    _ceoxsoBubbleColorImgV.image = IMAGENAME((UNString(@"sent_msg_background%ld", _ceoxsoBubbleColorIndex)));
    
    _ceoxsoAlphaSlider.value = _ceoxsoAlpha;
    self.ceoxsoChatBgColorIndex = _ceoxsoBgColorIndex;
    
    if (_isChinese) {
    }else {
        _ceoxsoPreviewFL.text = @"Hiệu ứng ô xem thử";
        _ceoxsoTextAL.text = @"Phong cách chat";
        _ceoxsoTextBL.text = @"Trò chuyện phong cách";
        _ceoxsoAlphaFL.text = @"Sự minh bạch thiết kế";
        _ceoxsoMinFL.text = @"Nhỏ";
        _ceoxsoMaxFL.text = @"To";
        _ceoxsoBgColorFL.text = @"Màu sắc nền";
    }
}


// 图案透明度
- (IBAction)ceoxsoAlphaSet:(UISlider *)sender {
    _ceoxsoBgImgV.backgroundColor = [ChatBgImgColors[_ceoxsoChatBgColorIndex] alpha:_ceoxsoAlphaSlider.value];
}

// 背景颜色
- (IBAction)ceoxsoColors:(UIButton *)sender {
    if (sender.tag == _ceoxsoChatBgColorIndex) {
        return;
    }
    self.ceoxsoChatBgColorIndex = sender.tag;
}

- (void)setCeoxsoChatBgColorIndex:(NSInteger)ceoxsoChatBgColorIndex {
    _ceoxsoChatBgColorIndex = ceoxsoChatBgColorIndex;
    
    for (UIButton *ceoxsoColorBtn in @[_ceoxsoColorABtn, _ceoxsoColorBBtn, _ceoxsoColorCBtn, _ceoxsoColorDBtn]) {
        if (ceoxsoColorBtn.tag == _ceoxsoChatBgColorIndex) {
            ViewBorderRadius(ceoxsoColorBtn, 15.0, 2.0, MAINCOLOR);
        }else {
            ViewBorderRadius(ceoxsoColorBtn, 15.0, 0.0, UIColor.clearColor);
        }
    }
    _ceoxsoBgImgV.backgroundColor = [ChatBgImgColors[_ceoxsoChatBgColorIndex] alpha:_ceoxsoAlphaSlider.value];
}

@end
