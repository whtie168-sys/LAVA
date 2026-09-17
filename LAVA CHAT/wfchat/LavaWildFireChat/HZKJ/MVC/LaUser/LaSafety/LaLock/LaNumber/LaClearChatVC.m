//
//  LaClearChatVC.m
//  WildFireChat
//
//  Created by Ruby on 12/7/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaClearChatVC.h"

@interface LaClearChatVC ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UILabel *forgotL;
@property (weak, nonatomic) IBOutlet UILabel *forgotDescL;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end

@implementation LaClearChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _clearButton.layer.cornerRadius = 25.0;
    
    _isChinese = [CommonHelper.main isChinese];
    [self updateADFLanguage];
}
- (void)updateADFLanguage {
    if (_isChinese) {
        self.navigationItem.title = @"忘记数字密码";
    }else {
        self.navigationItem.title = @"Quên mật khẩu số";
        _forgotL.text = @"Quên mật khẩu số?";
        _forgotDescL.text = @"Nếu quên mật khẩu khóa bảo mật, bạn cần xóa dữ liệu trò chuyện của tài khoản hiện tại và đăng nhập lại tài khoản của mình";
        
        [_clearButton setTitle:@"Xóa dữ liệu" forState:UIControlStateNormal];
    }
}

- (IBAction)clear:(UIButton *)sender {
    WS(weakself)
    NSString *title = @"再次确定后将会清除当前账户的所有聊天数据";
    if (_isChinese) {
    }else {
        title = @"Xác định một lần nữa sẽ xóa tất cả dữ liệu chat trong tài khoản hiện tại";
    }
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAct = [UIAlertAction actionWithTitle:LLLLLL(@"OK") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [NSUserDefaults.standardUserDefaults setInteger:100 forKey:UNString(@"isEnableClear%@", [NSUserDefaults.standardUserDefaults stringForKey:@"savedUserId"])]; // 记录是否可以清除聊天数据  在登录的地方  会话链接成功后进行清除、
        [NSUserDefaults.standardUserDefaults synchronize];
        
        [LockStatusManager.main reWriteLockInfo:@(0) ForKey:@"status"];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = LLLLLL(@"OperationInProgress");
        [hud showAnimated:YES];

        [AppService.sharedAppService requestUrl:@"/device_lock/set_status" params:@{@"status":@(0)} success:^(NSDictionary * _Nonnull dict) {
            [hud hideAnimated:YES];
            [LockStatusManager.main reWriteLockInfo:@(0) ForKey:@"status"];
            if (weakself.type == 4) {
                if (weakself.clearBlock) {
                    weakself.clearBlock();
                }
            }else if (weakself.type == 5) {
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:NSClassFromString(@"LaLoginVC")]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                }
            }else if (weakself.type == 6) {
                if (weakself.clearBlock) {
                    weakself.clearBlock();
                }
            }
        } error:^(int errCode, NSString * _Nonnull message) {
            [hud hideAnimated:YES];
            [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    [actionSheet addAction:cancelAct];
    [actionSheet addAction:okAct];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
