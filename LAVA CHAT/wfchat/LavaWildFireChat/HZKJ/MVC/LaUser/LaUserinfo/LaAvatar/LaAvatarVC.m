//
//  LaAvatarVC.m
//  WildFireChat
//
//  Created by Rubyuer on 7/22/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaAvatarVC.h"

#import "LaAvatarRecordVC.h"

@interface LaAvatarVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL _isChinese;
    BOOL _isCanUpdateAvatar; // 也就是ceoxsoAvatarV 是否是下面列表的头像之一
    
    NSString *_ceoxsoRemoteUrl; // 用于保存《自定义》下的头像更改url的值
}
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoAvatarV;

@property (weak, nonatomic) IBOutlet UIView *ceoxsoTypeV;
// (20, 5)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ceoxsoLineLeft;

@property (nonatomic, assign) NSInteger ceoxsoType;
@property (weak, nonatomic) IBOutlet UICollectionView *ceoxsoCV;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *ceoxsoLayout;
@property (nonatomic, strong) NSMutableArray<NSString *> *ceoxsoAvatars; // 自定义的网络头像

@property (weak, nonatomic) IBOutlet UIButton *ceoxsoCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoSaveBtn;

@property (nonatomic, strong) WFCCUserInfo *userInfo;

@end

@implementation LaAvatarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self itemImage:@"ceoxsoRecord" action:@selector(ceoxsoRecord)]];
    
    _isChinese = [CommonHelper.main isChinese];
    [_ceoxsoCancelBtn setTitle:LLLLLL(@"Cancel") forState:UIControlStateNormal];
    if (_isChinese) {
        self.navigationItem.title = @"更换头像";
    }else {
        self.navigationItem.title = @"Sửa đổi Ảnh đại diện";
        [_ceoxsoSaveBtn setTitle:LLLLLL(@"Save") forState:UIControlStateNormal];
        NSArray *ceoxsoTypeTitles = @[@"Tùy chỉnh", @"Nhân vật hoạt hình", @"Dòng IP", @"3D"];
        for (UIView *ceoxsoV in _ceoxsoTypeV.subviews) {
            if (ceoxsoV.tag >= 10) {
                continue;
            }
            UIButton *ceoxsoBtn = (UIButton *)ceoxsoV;
            ceoxsoBtn.titleLabel.numberOfLines = 2;
            [ceoxsoBtn setTitle:ceoxsoTypeTitles[ceoxsoBtn.tag] forState:UIControlStateNormal];
        }
    }
    _userInfo = [WFCCIMService.sharedWFCIMService getUserInfo:WFCCNetworkService.sharedInstance.userId refresh:NO];
    [_ceoxsoAvatarV sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
    
    _isCanUpdateAvatar = NO;
    self.ceoxsoType = 0;
    _ceoxsoRemoteUrl = @"";
    _ceoxsoAvatarV.layer.cornerRadius = 75.0;
    _ceoxsoCancelBtn.layer.cornerRadius = 12.0;
    _ceoxsoSaveBtn.layer.cornerRadius = 12.0;
    _ceoxsoLineLeft.constant = (WIDTH - 30.0) / 8.0 * (2.0 * _ceoxsoType + 1) - 10.0;
    
    [self requestCustomAvatar];
    _ceoxsoLayout.sectionInset = UIEdgeInsetsMake(15.0, 25.0, 22.0, 25.0);
    _ceoxsoLayout.itemSize = CGSizeMake(70.0, 70.0);
    _ceoxsoLayout.minimumInteritemSpacing = 0.0;
    _ceoxsoLayout.minimumLineSpacing = 22.0;
    _ceoxsoCV.delegate = self;
    _ceoxsoCV.dataSource = self;
    [_ceoxsoCV registerNib:[UINib nibWithNibName:@"LaAvatarCVCell" bundle:nil] forCellWithReuseIdentifier:@"LaAvatarCVCell"];
}
- (void)requestCustomAvatar {
    [self.ceoxsoAvatars removeAllObjects];
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    
    WS(weakself) // type  0 自定义的头像  OR  1 更改头像的历史记录
    [AppService.sharedAppService requestUrl:@"/headers" params:@{@"type":@"0"} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        NSArray *results = dict[@"result"];
        if (results.count <= 0) {
            return;
        }
        for (NSDictionary *resultDic in results) {
            NSString *portrait = resultDic[@"portrait"];
            if (portrait.length <= 0) {
                continue;
            }
            [weakself.ceoxsoAvatars addObject:portrait];
        }
        [weakself.ceoxsoCV reloadData];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}

- (IBAction)ceoxsoTypes:(UIButton *)sender {
    if (_ceoxsoType == sender.tag) {
        return;
    }
    WS(weakself)
    _ceoxsoLineLeft.constant = (WIDTH - 30.0) / 8.0 * (2.0 * sender.tag + 1) - 10.0;
    [UIView animateWithDuration:0.5 animations:^{
        [weakself.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        weakself.ceoxsoType = sender.tag;
        for (UIView *ceoxsoV in weakself.ceoxsoTypeV.subviews) {
            if (ceoxsoV.tag >= 10) {
                continue;
            }
            UIButton *ceoxsoBtn = (UIButton *)ceoxsoV;
            ceoxsoBtn.selected = (ceoxsoBtn.tag == sender.tag);
        }
    }];
}
- (void)setCeoxsoType:(NSInteger)ceoxsoType {
    _ceoxsoType = ceoxsoType;

    [_ceoxsoCV reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_ceoxsoType == 0) {
        return (1 + self.ceoxsoAvatars.count);
    }
    return 10;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LaAvatarCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LaAvatarCVCell" forIndexPath:indexPath];
    if (_ceoxsoType == 0) {
//        if (_ceoxsoAvatars.count == 0) {
//            cell.ceoxsoIconV.image = IMAGENAME(@"ceoxsoAddAvatar");
//        }else {
//            if (_ceoxsoAvatars.count > 0 && indexPath.row == 0) {
//                [cell.ceoxsoIconV sd_setImageWithURL:URL((_ceoxsoAvatars[indexPath.row]))];
//            }else {
//                cell.ceoxsoIconV.image = IMAGENAME(@"ceoxsoAddAvatar");
//            }
//        }
        
        
        if (_ceoxsoAvatars.count > 0 && indexPath.row < _ceoxsoAvatars.count) {
            [cell.ceoxsoIconV sd_setImageWithURL:URL((_ceoxsoAvatars[indexPath.row])) placeholderImage:nil options:SDWebImageScaleDownLargeImages
                                         context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        }else {
            cell.ceoxsoIconV.image = IMAGENAME(@"ceoxsoAddAvatar");
        }
    }else {
        cell.ceoxsoIconV.image = IMAGENAME(([NSString stringWithFormat:@"ceoxsoAvatar%ld_%ld",_ceoxsoType, indexPath.row]));
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_ceoxsoType == 0) { // 自定义
        if (_ceoxsoAvatars.count > 0 && indexPath.row < _ceoxsoAvatars.count) {
            _isCanUpdateAvatar = YES;
            _ceoxsoRemoteUrl = _ceoxsoAvatars[indexPath.row];
            [_ceoxsoAvatarV sd_setImageWithURL:URL(_ceoxsoRemoteUrl) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        }else { // 上传头像按钮
            [self ceoxsoAddAvatar];
        }
    }else {
        _isCanUpdateAvatar = YES;
        _ceoxsoRemoteUrl = @"";
        _ceoxsoAvatarV.image = IMAGENAME(([NSString stringWithFormat:@"ceoxsoAvatar%ld_%ld",_ceoxsoType, indexPath.row]));
    }
}

- (void)ceoxsoAddAvatar {
    WS(weakself)
    [CommonHelper.main showImagePikerWithimageBlock:^(UIImage * _Nonnull image) {
        [weakself uploadImage:image];
    }];
}

- (void)uploadImage:(UIImage *)targetImg {
    WS(weakself)
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Uploading");
    [hud showAnimated:YES];
    [AppService.sharedAppService uploadFile:@"/media/upload/avatar" images:@[targetImg] progress:^(int sentcount, int total) {
    } success:^(NSString * _Nonnull url) {
        [hud hideAnimated:YES];
        if (url.length > 0) {
            [weakself.ceoxsoAvatars addObject:url];
            [weakself.ceoxsoCV reloadData];
        }
    } error:^(NSString * _Nonnull errorMsg) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:errorMsg duration:1.0 position:CSToastPositionCenter];
    }];
}



#pragma mark - 头像更改的历史列表

- (void)ceoxsoRecord {
    LaAvatarRecordVC *vc = LaAvatarRecordVC.new;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 更改头像 至 IM服务器

- (IBAction)ceoxsoCancel:(UIButton *)sender {
    if (_isCanUpdateAvatar) {
        [_ceoxsoAvatarV sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                   context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        _isCanUpdateAvatar = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ceoxsoSave:(UIButton *)sender {
    if (!_isCanUpdateAvatar) {
        [self.view makeToast:(_isChinese ? @"请选择头像..." : @"Hãy chọn avatar ...") duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (_ceoxsoType == 0) { // 自定义的头像，本地保存的本身就是url格式，更改时就不用上传至服务器，直接通过IM进行更改头像
        [self modityAvatarWithIM:_ceoxsoRemoteUrl];
    }else {
        [self uploadServiceImg:UIImageJPEGRepresentation(_ceoxsoAvatarV.image, 0.1)];
    }
}

- (void)uploadServiceImg:(NSData *)imgData { // 这一步是更改本地的头像  必须上传至服务器，再通过IM进行更改
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    WS(weakself)
      [[WFCCIMService sharedWFCIMService] uploadMedia:nil mediaData:imgData mediaType:Media_Type_PORTRAIT success:^(NSString *remoteUrl) {
          dispatch_async(dispatch_get_main_queue(), ^{
              [hud hideAnimated:YES];
              [weakself modityAvatarWithIM:remoteUrl];
          });
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

- (void)modityAvatarWithIM:(NSString *)remoteUrl {
//    [[WFCCIMService sharedWFCIMService] modifyMyInfo:@{@(Modify_Portrait):remoteUrl} success:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self->_isCanUpdateAvatar = NO;
//
//            [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserDataUpdated" object:nil];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakself.navigationController popViewControllerAnimated:YES];
//            });
//      });
//    } error:^(int error_code) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakself.view makeToast:LLLLLL(@"OperationFailure") duration:1.0 position:CSToastPositionCenter];
//        });
//    }];
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/update/avatar" params:@{@"portrait":remoteUrl} success:^(NSDictionary * _Nonnull dict) {
        self->_isCanUpdateAvatar = NO;

        [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];

        if (weakself.isRegister) {
            if (self.setBlock) {
                self.setBlock(remoteUrl);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserDataUpdated" object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [weakself.navigationController popViewControllerAnimated:YES];
                [weakself.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } error:^(int errCode, NSString * _Nonnull message) {
        [weakself.view makeToast:LLLLLL(@"OperationFailure") duration:1.0 position:CSToastPositionCenter];
    }];
}

- (NSMutableArray *)ceoxsoAvatars {
    if (!_ceoxsoAvatars) {
        _ceoxsoAvatars = NSMutableArray.new;
    }return _ceoxsoAvatars;
}

@end
/**
 获取用户历史头像  自定义的头像0 and 更改头像的历史记录
 http://ec2-54-254-43-61.ap-southeast-1.compute.amazonaws.com:8888/swagger-ui/index.html#/app-controller/headers

 删除历史头像
 http://ec2-54-254-43-61.ap-southeast-1.compute.amazonaws.com:8888/swagger-ui/index.html#/app-controller/deleteAvatar
 上传头像(上传后会返回访问URL)
 http://ec2-54-254-43-61.ap-southeast-1.compute.amazonaws.com:8888/swagger-ui/index.html#/app-controller/uploadAvatar
 */


@interface LaAvatarCVCell ()


@end

@implementation LaAvatarCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _ceoxsoIconV.layer.cornerRadius = 35.0;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.ceoxsoIconV sd_cancelCurrentImageLoad];
    self.ceoxsoIconV.image = nil;
}

@end
