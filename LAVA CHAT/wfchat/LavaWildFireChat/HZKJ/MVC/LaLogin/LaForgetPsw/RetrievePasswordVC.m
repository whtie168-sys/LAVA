//
//  RetrievePasswordVC.m
//  WildFireChat
//
//  Created by Ruby on 12/26/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "RetrievePasswordVC.h"
#import "MobileEmailPasswordVC.h"

@interface RetrievePasswordVC ()

@property (weak, nonatomic) IBOutlet UILabel *phoneBackL;
@property (weak, nonatomic) IBOutlet UILabel *emailBackL;

@end

@implementation RetrievePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([CommonHelper.main isChinese]) {
        self.navigationItem.title = @"找回密码";
    }else {
        self.navigationItem.title = @"Lấy lại mật khẩu";
        _phoneBackL.text = @"Thông qua số điện thoại";
        _emailBackL.text = @"Thông qua email";
    }
}

- (IBAction)act:(UIButton *)sender {
    MobileEmailPasswordVC *vc = MobileEmailPasswordVC.new;
    vc.type = sender.tag;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
