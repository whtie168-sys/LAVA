//
//  LaWalletVC.m
//  WildFireChat
//
//  Created by wtb on 2025/3/30.
//  Copyright © 2025 WildFireChat. All rights reserved.
//

#import "LaWalletVC.h"

@interface LaWalletVC ()
@property (weak, nonatomic) IBOutlet UILabel *uziondStatusL;

@end

@implementation LaWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLLLLL(@"MyWallet");
    
    if ([CommonHelper.main isChinese]) {
        _uziondStatusL.text = @"该功能即将上线，敬请期待！";
    }else {
        _uziondStatusL.text = @"This feature is coming soon";
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
