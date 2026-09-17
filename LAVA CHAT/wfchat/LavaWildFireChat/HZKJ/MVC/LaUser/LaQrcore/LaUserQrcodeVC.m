//
//  LaUserQrcodeVC.m
//  WildFireChat
//
//  Created by Rubyuer on 7/22/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaUserQrcodeVC.h"

@interface LaUserQrcodeVC ()
{
    NSString *_qrStr;
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIView *ceoxsoBgV;

@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoIconV;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoNameL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoIdL;

@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoQrImgV;
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoQrIconV;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoAddFirendL;
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoLogoV;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoExpirationL;

@property (weak, nonatomic) IBOutlet UIButton *ceoxsoRefreshBtn;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoSkanL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoShareL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoDownloadL;

@property (nonatomic, strong) WFCCUserInfo *userInfo;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation LaUserQrcodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    self.navigationItem.title = _isChinese ? @"二维码" : @"Mã QR của tôi";
 
    _ceoxsoIconV.layer.cornerRadius = 30.0;
    _ceoxsoQrIconV.hidden = YES;
    _ceoxsoQrIconV.layer.cornerRadius = 26.0;
    _ceoxsoLogoV.layer.cornerRadius = 10.0;
    if (_isChinese) {
    }else {
        _ceoxsoAddFirendL.text = @"Quét mã\nThêm tôi như một người bạn";
        [_ceoxsoRefreshBtn setTitle:@"Làm mới" forState:UIControlStateNormal];
        
        _ceoxsoSkanL.text = @"Quét mã";
        _ceoxsoShareL.text = @"Chia sẻ";
        _ceoxsoDownloadL.text = @"Lưu hình ảnh";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:YES];
    
    [self ceoxsoRefreshTime];
}

- (void)ceoxsoRefreshTime {
    NSDateFormatter *ceoxsoFormatter = NSDateFormatter.new;
    ceoxsoFormatter.dateFormat = @"dd-MM-yyyy HH:mm";
    
    NSString *ceoxsoExpiration = @"";
    NSDate *ceoxsoDate = [NSDate.date dateByAddingTimeInterval:7*24*60*60];
    if (_isChinese) {
        ceoxsoExpiration = UNString(@"有效期至%@", [ceoxsoFormatter stringFromDate:ceoxsoDate]);
    }else {
        ceoxsoExpiration = UNString(@"Hợp lệ cho đến khi %@", [ceoxsoFormatter stringFromDate:ceoxsoDate]);
    }
    if ([ceoxsoExpiration isEqualToString:_ceoxsoExpirationL.text]) {
        return;
    }
    _ceoxsoExpirationL.text = ceoxsoExpiration;
    
    NSInteger ceoxsoTimeInterval = (NSInteger)[ceoxsoDate timeIntervalSince1970];
    
    _qrStr = [NSString stringWithFormat:@"wildfirechat://user/%@####%ld", WFCCNetworkService.sharedInstance.userId, ceoxsoTimeInterval];
    WS(weakself)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImage *ceoxsoQrImg = [LBXScanNative logolOrQRImage:self->_qrStr logolImage:weakself.ceoxsoIconV.image];
            weakself.ceoxsoQrIconV.hidden = NO;
            UIImage *ceoxsoQrImg = [LBXScanNative logolOrQRImage:self->_qrStr logolImage:nil];
            weakself.ceoxsoQrImgV.image = ceoxsoQrImg;
        });
    });
}

- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    [_ceoxsoIconV sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
    _ceoxsoQrIconV.image = _ceoxsoIconV.image;
    _ceoxsoNameL.text = _userInfo.displayName;
    _ceoxsoIdL.text = _userInfo.name;
}

- (IBAction)ceoxsoScanShareDownloads:(UIButton *)sender {
    if (sender.tag == 0) {
        if (gQrCodeDelegate) { // 走的delegate方法
            [gQrCodeDelegate scanQrCode:self.navigationController];
        }
    }else {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicator.center = self.view.center;
        _indicatorView = indicator;
        [[UIApplication sharedApplication].keyWindow addSubview:indicator];
        [indicator startAnimating];
        
        UIImage *image = [self shotShareImageFromView:self.ceoxsoBgV];
        if (sender.tag == 1) {
            [_indicatorView removeFromSuperview];
            UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
            [self presentViewController:avc animated:YES completion:nil];
        }else {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
}



- (IBAction)ceoxsoCopy:(UIButton *)sender {
    if (_ceoxsoIdL.text.length <= 0) {
        return;
    }
    UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;
    pasteboard.string = _ceoxsoIdL.text;
    [SVProgressHUD showSuccessWithStatus:LLLLLL(@"CopySuccessfully")];
    [SVProgressHUD dismissWithDelay:1.0];
}

- (IBAction)ceoxsoRefresh:(UIButton *)sender {
    [self ceoxsoRefreshTime];
}





- (void)onUserInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    for (WFCCUserInfo *userInfo in userInfoList) {
        if ([WFCCNetworkService.sharedInstance.userId isEqualToString:userInfo.userId]) {
            self.userInfo = userInfo;
            break;
        }
    }
}

/** 1、截取屏幕上指定view的内容 */
- (UIImage *)shotShareImageFromView:(UIView *)view {
    //高清方法
    //第一个参数表示区域大小 第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    CGSize size = CGSizeMake(view.layer.bounds.size.width, view.layer.bounds.size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, ([UIScreen mainScreen].scale));
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_indicatorView removeFromSuperview];

    if (error) {
        [SVProgressHUD showErrorWithStatus:LLLLLL(@"SaveFailure")];
        [SVProgressHUD dismissWithDelay:1.0];
    } else {
        [SVProgressHUD showSuccessWithStatus:LLLLLL(@"SaveSuccessfully")];
        [SVProgressHUD dismissWithDelay:1.0];
    }
}


@end
