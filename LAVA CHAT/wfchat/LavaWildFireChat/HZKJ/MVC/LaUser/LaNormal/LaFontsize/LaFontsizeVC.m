//
//  LaFontsizeVC.m
//  WildFireChat
//
//  Created by Rubyuer on 4/24/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaFontsizeVC.h"

@interface LaFontsizeVC ()
{
    NSInteger _fontSize;
}
@property (weak, nonatomic) IBOutlet UIView *haecgAView;
@property (weak, nonatomic) IBOutlet UIView *haecgBView;
@property (weak, nonatomic) IBOutlet UIView *haecgCView;
@property (weak, nonatomic) IBOutlet UILabel *haecgTitleALabel;
@property (weak, nonatomic) IBOutlet UILabel *haecgTitleBLabel;
@property (weak, nonatomic) IBOutlet UILabel *haecgTitleCLabel;


@property (weak, nonatomic) IBOutlet UILabel *haecgSmallLabel;
@property (weak, nonatomic) IBOutlet UILabel *haecgStandardLabel;
@property (weak, nonatomic) IBOutlet UILabel *haecgBigLabel;

@property (weak, nonatomic) IBOutlet UISlider *haecgSlider;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *haecgBottom;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoYulanL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoQJZTDXL;

@end

@implementation LaFontsizeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"FontSize");
    UIButton *rightItem = [self itemTitle:LLLLLL(@"OK") action:@selector(haecgDone)];
    [rightItem setTitleColor:MAINCOLOR forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItem];
    
    _haecgAView.layer.cornerRadius = 8.0;
    _haecgBView.layer.cornerRadius = 8.0;
    _haecgCView.layer.cornerRadius = 8.0;
    
    _haecgBottom.constant = 100.0 + TabBarHeight;
    if ([CommonHelper.main isChinese]) {
    }else {
        _haecgTitleALabel.text = @"Kéo thanh trượt bên dưới để cài đặt cỡ chữ cho giao diện trò chuyện";
        _haecgTitleBLabel.text = @"Ô xem thử kích cỡ phông chữ";
        _haecgTitleCLabel.text = @"Thiết lập chỉ thay đổi kích cỡ phông chữ trong giao diện chat";
        
        _haecgSmallLabel.text = @"Nhỏ";
        _haecgStandardLabel.text = @"Tiêu chuẩn";
        _haecgBigLabel.text = @"To";
        
        _ceoxsoYulanL.text = @"Hiệu ứng ô xem thử";
        _ceoxsoQJZTDXL.text = @"Cỡ phông chữ toàn cầu";
    }
    _fontSize = [NSUserDefaults.standardUserDefaults integerForKey:@"kFontSize"];
    _haecgSlider.value = _fontSize;
    [self haecoFontSize];
}

- (void)haecgDone {
    [NSUserDefaults.standardUserDefaults setInteger:_fontSize forKey:@"kFontSize"];
    [NSUserDefaults.standardUserDefaults synchronize];
    WS(weakself)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (IBAction)haecoSlider:(UISlider *)sender {
    // 取整数值
    _fontSize = roundf(sender.value);
    sender.value = _fontSize;
    [self haecoFontSize];
}

- (void)haecoFontSize {
    _haecgTitleALabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:_fontSize];
    _haecgTitleBLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:_fontSize];
    _haecgTitleCLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:_fontSize];
}


//override func viewDidLoad() {
//    super.viewDidLoad()
//
//    // 设置slider的属性
//    slider.minimumValue = 1
//    slider.maximumValue = 5
////        slider.
//    slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
//
//    slider.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//        slider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//        slider.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
//    ])
//}
//
//@objc func sliderValueChanged(_ sender: UISlider) {
//    // 取整数值
//    let currentValue = Int(sender.value.rounded())
//    sender.value = Float(currentValue)
//    print("Slider value: \(currentValue)")
//}

@end
