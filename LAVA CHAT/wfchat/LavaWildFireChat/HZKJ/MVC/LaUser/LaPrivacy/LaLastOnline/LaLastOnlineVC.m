//
//  LaLastOnlineVC.m
//  WildFireChat
//
//  Created by Ruby on 12/4/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaLastOnlineVC.h"

@interface LaLastOnlineVC ()

@property (weak, nonatomic) IBOutlet UIImageView *statusAView;
@property (weak, nonatomic) IBOutlet UIImageView *statusBView;
@property (weak, nonatomic) IBOutlet UIImageView *statusCView;


@property (weak, nonatomic) IBOutlet UILabel *descL;
@property (weak, nonatomic) IBOutlet UILabel *allPersonL;
@property (weak, nonatomic) IBOutlet UILabel *contactL;
@property (weak, nonatomic) IBOutlet UILabel *notShowL;

@end

@implementation LaLastOnlineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"LastOnlineTime");
    
    if ([CommonHelper.main isChinese]) {
    }else {
        _descL.text = @"Ai có thể xem thời gian đăng nhập lần cuối của tôi?";
        _allPersonL.text = @"Tất cả";
        _contactL.text = @"Chỉ trên danh bạ";
        _notShowL.text = @"Không hiển thị thời gian online";
    }
    [self btnState];
}

- (IBAction)status:(UIButton *)sender {
    if (_showLastLoginTime == sender.tag) {
        return;
    }
    _showLastLoginTime = sender.tag;
    [self updateState];
}

- (void)updateState {
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/user/set_option" params:@{@"disableShowLastLoginTime":@(_showLastLoginTime)} success:^(NSDictionary * _Nonnull dict) {
        [weakself btnState];
    } error:^(int errCode, NSString * _Nonnull message) {
    }];
}

- (void)btnState {
    _statusAView.hidden = !(_showLastLoginTime == 0);
    _statusBView.hidden = !(_showLastLoginTime == 1);
    _statusCView.hidden = !(_showLastLoginTime == 2);
}


@end
