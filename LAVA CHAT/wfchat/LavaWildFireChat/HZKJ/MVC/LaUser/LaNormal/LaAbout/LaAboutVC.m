//
//  LaAboutVC.m
//  WildFireChat
//
//  Created by Ruby on 11/24/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaAboutVC.h"

#import "LaWebviewVC.h"
#import "LaFeedbackVC.h"
#import "LaProtocolVC.h"

@interface LaAboutVC ()

@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoJCGXL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoYHFWXYL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoYSZCL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoFLSML;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoGWL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoSYBZL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoYJFKL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoSJQLL;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoWebsiteL;

@end

@implementation LaAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _logoView.layer.cornerRadius = 20.0;
    
    [self updateADFLanguage];
    
    _versionLabel.text = UNString(@"V%@", VersionNUM);

    
//    if (CommonHelper.main.iosVersion.length <= 0) {
//        WS(weakself)
//        [CommonHelper.main updateAppSuccess:^(BOOL isUpdate) {
//            NSString *iosVersion = CommonHelper.main.iosVersion;
//            if (iosVersion.length <= 0) {
//            }else {
//                weakself.versionLabel.text = UNString(@"V%@", CommonHelper.main.iosVersion);
//            }
//        }];
//    }else {
//        _versionLabel.text = UNString(@"V%@", CommonHelper.main.iosVersion);
//    }
}

- (void)updateADFLanguage {
    self.navigationItem.title = LLLLLL(@"About");
    _nameLabel.text = LLLLLL(@"CFBundleName");
    
    _ceoxsoYHFWXYL.text = LLLLLL(@"UserAgreement");
    _ceoxsoYSZCL.text = LLLLLL(@"PrivacyPolicy");
    
    _ceoxsoGWL.text = LLLLLL(@"OfficialWebsite");
    _ceoxsoSYBZL.text = LLLLLL(@"UseHelp");
    _ceoxsoYJFKL.text = LLLLLL(@"Feedback");
    _ceoxsoSJQLL.text = LLLLLL(@"ClearCache");
    
    if ([CommonHelper.main isChinese]) {
    }else {
        _ceoxsoJCGXL.text = @"Kiểm tra cập nhật";
        _ceoxsoFLSML.text = @"Tuyên bố pháp lý";
    }
    
    NSString *websiteUrl = [NSUserDefaults.standardUserDefaults objectForKey:([CommonHelper.main isChinese] ? kWebsiteUrlChinese : kWebsiteUrlEnglish)];
    if (websiteUrl.length > 0) {
        _ceoxsoWebsiteL.text = websiteUrl;
    }else {
        _ceoxsoWebsiteL.text = LLLLLL(@"OFFICIAL_WEBSITE");
    }
}

- (IBAction)version:(UIButton *)sender {
    WS(weakself)
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    [CommonHelper.main updateAppSuccess:^(BOOL isUpdate) {
        [hud hideAnimated:YES];
        if (!isUpdate) {
            [self.view makeToast:LLLLLL(@"NoNewVersionAvailable") duration:1 position:CSToastPositionCenter];
        }else {
            NSString *iosVersion = CommonHelper.main.iosVersion;
            if (iosVersion.length <= 0) {
            }else {
                weakself.versionLabel.text = UNString(@"V%@", CommonHelper.main.iosVersion);
            }
        }
    }];
}

// 0  LAVA官网    1 使用帮助  2 用户服务协议  3 隐私协议  4 法律申明
- (IBAction)ceoxsoServicePrivateFalvs:(UIButton *)sender {
    if (sender.tag == 0) { // 用户服务协议
//        LaProtocolVC *vc = LaProtocolVC.new;
//        vc.eogcsaioxType = 0;
//        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 1) { // 隐私政策
//        LaProtocolVC *vc = LaProtocolVC.new;
//        vc.eogcsaioxType = 1;
//        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 2) { // 法律申明
        
    }
    LaWebviewVC *vc = LaWebviewVC.new;
    vc.type = sender.tag + 2;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)ceoxsoGWUserFeedbackClears:(UIButton *)sender {
    if (sender.tag <= 1) {
        LaWebviewVC *vc = LaWebviewVC.new;
        vc.type = sender.tag;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 2) {
        LaFeedbackVC *vc = LaFeedbackVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 3) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:LLLLLL(@"ClearCache") message:([CommonHelper.main isChinese] ? @"该操作会将缓存数据全部清除，且无法恢复，是否继续？" : @"Tất cả dữ liệu tạm thời sẽ bị xóa và không thể khôi phục được") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        WS(weakself)
        UIAlertAction *actionClear = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
            hud.label.text = LLLLLL(@"OperationInProgress");
            [hud showAnimated:YES];
            WS(weakself)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [WFCCIMService.sharedWFCIMService clearAllMessages:YES];
                [hud hideAnimated:YES];
                [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];
            });
        }];
        [actionSheet addAction:actionCancel];
        [actionSheet addAction:actionClear];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}




- (IBAction)share:(UIButton *)sender {
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[_logoView.image, LLLLLL(@"CFBundleName")] applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
}

@end
