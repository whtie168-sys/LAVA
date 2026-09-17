//
//  SwitchTableViewCell.m
//  WildFireChat
//
//  Created by heavyrain lee on 27/12/2017.
//  Copyright © 2017 WildFireChat. All rights reserved.
//

#import "DSRACGeneralSwitchTVCell.h"
#import "MBProgressHUD.h"


@interface DSRACGeneralSwitchTVCell()
@end

@implementation DSRACGeneralSwitchTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.valueSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 69, (self.frame.size.height - 31)/2.0, 9, 31)];
        self.valueSwitch.onTintColor = RGBCOLOR(255.0, 174.0, 34.0);
        [self.contentView addSubview:self.valueSwitch];
        [self.valueSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 51.5, UIScreen.mainScreen.bounds.size.width - 40, 0.5)];
//        lineView.backgroundColor = RGBCOLOR(224, 224, 224);
//        [self.contentView addSubview:lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.valueSwitch.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 69, (self.frame.size.height - 31)/2.0, 9, 31);
}

- (void)onSwitch:(id)sender {
    BOOL value = _valueSwitch.on;
    __weak typeof(self)ws = self;
    if (self.onSwitch) {
        self.onSwitch(value, self.type, ^(BOOL success) {
            if (success) {
                [ws.valueSwitch setOn:value];
            } else {
                [ws.valueSwitch setOn:!value];
            }
        });
    }
}

- (void)setOn:(BOOL)on {
    _on = on;
    [self.valueSwitch setOn:on];
}
@end
