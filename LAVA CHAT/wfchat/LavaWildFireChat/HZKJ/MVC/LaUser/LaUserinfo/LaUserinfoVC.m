//
//  LaUserVC.m
//  WildFireChat
//
//  Created by Ruby on 11/14/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaUserinfoVC.h"

#import "LaNormalQrcodeVC.h"
#import "LaTextModifyVC.h"
#import "LaAvatarVC.h"
#import "LaUserInfoGenderView.h"
#import "LaUserInfoBirthdayView.h"

@interface LaUserinfoVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nicktzboeuNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@property (strong, nonatomic) UIImagePickerController *pickerController;

@property (nonatomic, strong) WFCCUserInfo *userInfo;


@property (weak, nonatomic) IBOutlet UILabel *iconV;
@property (weak, nonatomic) IBOutlet UILabel *nicknameL;
@property (weak, nonatomic) IBOutlet UILabel *accountL;
@property (weak, nonatomic) IBOutlet UILabel *signL;
@property (weak, nonatomic) IBOutlet UILabel *qrL;
@property (weak, nonatomic) IBOutlet UILabel *loginTimeLabel;

@end

@implementation LaUserinfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    if (_isChinese) {
        self.navigationItem.title = @"我的资料";
    }else {
        self.navigationItem.title = @"Thông tin của tôi";
        _iconV.text = @"Ảnh đại diện";
        _nicknameL.text = @"Biệt danh";
        _accountL.text = @"Giới tính";
        _qrL.text = @"Đăng nhập lần cuối";
    }
    _signL.text = LLLLLL(@"PersonalSignature");
    _iconView.layer.cornerRadius = 20.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userdataUpdated) name:@"kUserDataUpdated" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:savedUserId refresh:NO];
    
    [_iconView sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                          context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    _nicktzboeuNameLabel.text = _userInfo.displayName;
    _genderLabel.text = @[LLLLLL(@"Male"),LLLLLL(@"Female"),LLLLLL(@"Other")][_userInfo.gender];
    if ([UserExtraInfo mj_objectWithKeyValues:_userInfo.extra].birthday == 0) {
        _birthdayLabel.text = LLLLLL(@"Notperfect");
    } else {
        _birthdayLabel.text = [UNString(@"%lld", [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra].birthday) timeIntervalDateFormat:@"yyyy-MM-dd"];
    }
    NSString *logintime = [UNString(@"%lld", [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra].lastLoginTime) timeIntervalDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _loginTimeLabel.text = logintime;
    
//    _signLabel.text = [UserExtraInfo mj_objectWithKeyValues:_userInfo.extra].sign;
}

- (void)userdataUpdated {
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:savedUserId refresh:NO];
    [_iconView sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                          context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
}

- (IBAction)userinfoAct:(UIButton *)sender {
    if (sender.tag == 0) { // 头像
//        WS(weakself)
//        [CommonHelper.main showImagePikerWithimageBlock:^(UIImage * _Nonnull image) {
//            [weakself modityIconData:UIImageJPEGRepresentation(image, 0.01)];
//        }];
        LaAvatarVC *vc = LaAvatarVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 1) { // 昵称
        LaTextModifyVC *vc = LaTextModifyVC.new;
        vc.modifyType = Modify_DisplayName;
        vc.defaultValue = _nicktzboeuNameLabel.text;
        WS(weakself)
        [vc setOnModified:^(NSString * _Nonnull value) {
            weakself.nicktzboeuNameLabel.text = value;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 2) { // 账号
        
        LaUserInfoGenderView *genderV = [[LaUserInfoGenderView alloc] init];
        [genderV show:_userInfo.gender];
        [genderV setSelectB:^(NSInteger index) {
            [self update:Modify_Gender value:index];
        }];

        
//        [self.view makeToast:(_isChinese ? @"暂不提供更改" : @"Tạm thời không cung cấp thay đổi") duration:1.0 position:CSToastPositionCenter];
//        LaTextModifyVC *vc = LaTextModifyVC.new;
//        vc.modifyType = 100;
//        vc.defaultValue = _ocsaoxAccountLabel.text;
//        WS(weakself)
//        [vc setOnModified:^(NSString * _Nonnull value) {
//            weakself.ocsaoxAccountLabel.text = value;
//        }];
//        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 3) { // 二维码
//        LaNormalQrcodeVC *vc = LaNormalQrcodeVC.new;
//        vc.qrType = 0;
//        vc.target = _userInfo.userId;
//        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag ==4) { // 个性签名
        
        LaUserInfoBirthdayView *birV = [LaUserInfoBirthdayView new];
        [birV show];
        [birV setInitialDateWithTimestamp:[UserExtraInfo mj_objectWithKeyValues:_userInfo.extra].birthday];
        [birV setSelectD:^(NSTimeInterval time) {
            [self updateBirthday:time];
        }];

//        LaTextModifyVC *vc = LaTextModifyVC.new;
//        vc.modifyType = Modify_Sign;
//        vc.defaultValue = _signLabel.text;
//        WS(weakself)
//        [vc setOnModified:^(NSString * _Nonnull value) {
//            weakself.signLabel.text = value;
//        }];
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)update:(ModifyMyInfoType)modifyType value:(NSInteger)value {
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    WS(weakself)

    [[WFCCIMService sharedWFCIMService] modifyMyInfo:@{@(modifyType):[NSString stringWithFormat:@"%ld",(long)value]} success:^{
        [hud hideAnimated:YES];
        self->_userInfo.gender = value;
        weakself.genderLabel.text = @[LLLLLL(@"Male"),LLLLLL(@"Female"),LLLLLL(@"Other")][self->_userInfo.gender];
  
    } error:^(int error_code) { // WFCCErrorCode
        [hud hideAnimated:YES];
        
        hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = (error_code == ERROR_CODE_NOT_MODIFIED ? (self->_isChinese ? @"未修改成功！" : @"Not modified successfully") : (self->_isChinese ? @"更新失败！" : @"Update failed!"));
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:1.f];
    }];
}

- (void)updateBirthday:(long long)birthday {
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/user/set_option" params:@{@"birthday":UNString(@"%lld",(long long)birthday)} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        
        NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
        weakself.userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:savedUserId refresh:YES];
        weakself.birthdayLabel.text = [UNString(@"%lld", birthday) timeIntervalDateFormat:@"yyyy-MM-dd"];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        
        hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = (errCode == ERROR_CODE_NOT_MODIFIED ? (self->_isChinese ? @"未修改成功！" : @"Not modified successfully") : (self->_isChinese ? @"更新失败！" : @"Update failed!"));
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:1.f];
    }];

}

- (void)modityIconData:(NSData *)imgData {
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    
    WS(weakself)
      [[WFCCIMService sharedWFCIMService] uploadMedia:nil mediaData:imgData mediaType:Media_Type_PORTRAIT success:^(NSString *remoteUrl) {
          [[WFCCIMService sharedWFCIMService] modifyMyInfo:@{@(Modify_Portrait):remoteUrl} success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
              [weakself.iconView sd_setImageWithURL:URL(remoteUrl) placeholderImage:weakself.iconView.image];
                
                [hud hideAnimated:YES];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = LLLLLL(@"SuccessfulOperation");
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserDataUpdated" object:nil];
            });
          } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = LLLLLL(@"OperationFailure");
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
            });
          }];
          } progress:^(long uploaded, long total) {
        } error:^(int error_code) {
          dispatch_async(dispatch_get_main_queue(), ^{
              [hud hideAnimated:YES];
              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
              hud.mode = MBProgressHUDModeText;
              hud.label.text = LLLLLL(@"UploadFailure");
              hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
              [hud hideAnimated:YES afterDelay:1.f];
          });
    }];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
