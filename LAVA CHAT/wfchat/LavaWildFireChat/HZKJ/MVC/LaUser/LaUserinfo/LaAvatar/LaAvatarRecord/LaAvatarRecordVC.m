//
//  LaAvatarRecordVC.m
//  WildFireChat
//
//  Created by Rubyuer on 7/29/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaAvatarRecordVC.h"
#import "LaAvatarVC.h"

@interface LaAvatarRecordVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UICollectionView *ceoxsoCV;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *ceoxsoLayout;
@property (nonatomic, strong) NSMutableArray<NSArray<AvatarHistoryList *> *> *ceoxsoAvatars;
@property (nonatomic, strong) NSMutableArray<NSString *> *ceoxsoHeads;

@end

@implementation LaAvatarRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    if (_isChinese) {
        self.navigationItem.title = @"头像更改历史";
    }else {
        self.navigationItem.title = @"Thay đổi avatar lịch sử";
    }
    UIButton *ceoxsoClearBtn = [self itemTitle:(_isChinese?@"清除":@"Xóa") action:@selector(ceoxsoClearAvatarRecord)];
    [ceoxsoClearBtn setTitleColor:MAINCOLOR forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ceoxsoClearBtn];
    
    [self requestAvatarHistroy];
    _ceoxsoLayout.sectionInset = UIEdgeInsetsMake(15.0, 25.0, 15.0, 25.0);
    _ceoxsoLayout.itemSize = CGSizeMake(70.0, 70.0);
    _ceoxsoLayout.minimumInteritemSpacing = 0.0;
    _ceoxsoLayout.minimumLineSpacing = 22.0;
    _ceoxsoCV.delegate = self;
    _ceoxsoCV.dataSource = self;
    [_ceoxsoCV registerNib:[UINib nibWithNibName:@"LaAvatarCVCell" bundle:nil] forCellWithReuseIdentifier:@"LaAvatarCVCell"];
    [_ceoxsoCV registerNib:[UINib nibWithNibName:@"LaAvatarRecordCRView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"LaAvatarRecordCRView"];
}


- (void)requestAvatarHistroy {
    [self.ceoxsoAvatars removeAllObjects];
    [self.ceoxsoHeads removeAllObjects];
    WS(weakself)
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    [AppService.sharedAppService requestUrl:@"/headers" params:@{@"type":@"1"} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        NSArray *results = dict[@"result"];
        if (results.count <= 0) {
            return;
        }
        NSArray *ceoxsoDatas = [[AvatarHistoryList mj_objectArrayWithKeyValuesArray:results] sortedArrayUsingComparator:^NSComparisonResult(AvatarHistoryList  * obj1, AvatarHistoryList  * obj2) {
//            return [obj1.createTime compare:obj2.createTime] == NSOrderedAscending;
            return obj1.id <= obj2.id;
        }];
        for (AvatarHistoryList *avatarHistory in ceoxsoDatas) {
            NSString *ceoxsoTimesStr = [weakself.ceoxsoHeads componentsJoinedByString:@""];
            if ([ceoxsoTimesStr containsString:avatarHistory.createTime]) {
                continue;
            }
            [weakself.ceoxsoHeads addObject:avatarHistory.createTime];
        }
        for (NSString *ceoxsoTime in weakself.ceoxsoHeads) {
            NSMutableArray<AvatarHistoryList *> *ceoxsoResults = NSMutableArray.new;
            for (AvatarHistoryList *avatarHistory in ceoxsoDatas) {
                if ([avatarHistory.createTime isEqualToString:ceoxsoTime]) {
                    [ceoxsoResults addObject:avatarHistory];
                }
            }
            [weakself.ceoxsoAvatars addObject:ceoxsoResults];
        }
        [weakself.ceoxsoCV reloadData];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
    }];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.ceoxsoAvatars.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.ceoxsoAvatars.count == 0) {
        return 0;
    }
    return self.ceoxsoAvatars[section].count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LaAvatarCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LaAvatarCVCell" forIndexPath:indexPath];
    AvatarHistoryList *avatarHistory = _ceoxsoAvatars[indexPath.section][indexPath.row];
    [cell.ceoxsoIconV sd_setImageWithURL:URL(avatarHistory.portrait) placeholderImage:nil options:SDWebImageScaleDownLargeImages
                                 context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.ceoxsoAvatars.count == 0) {
        return CGSizeZero;
    }
    return CGSizeMake(WIDTH, 44.0);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    LaAvatarRecordCRView *ceoxsoHeadView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"LaAvatarRecordCRView" forIndexPath:indexPath];
    ceoxsoHeadView.ceoxsoDateL.text = _ceoxsoHeads[indexPath.section];
    return ceoxsoHeadView;
}



- (void)ceoxsoClearAvatarRecord {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(_isChinese ? @"您确定要清空吗？" : @"Bạn có chắc bạn muốn xoá?") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WS(weakself)
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLLLLL(@"ConfirmDelete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [AppService.sharedAppService requestUrl:@"/delete/avatars" params:@[] success:^(NSDictionary * _Nonnull dict) {
            [weakself.view makeToast:LLLLLL(@"SuccessfulOperation") duration:1.0 position:CSToastPositionCenter];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.navigationController popViewControllerAnimated:YES];
            });
        } error:^(int errCode, NSString * _Nonnull message) {
            [weakself.view makeToast:message duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (NSMutableArray<NSArray<AvatarHistoryList *> *> *)ceoxsoAvatars {
    if (!_ceoxsoAvatars) {
        _ceoxsoAvatars = NSMutableArray.new;
    }return _ceoxsoAvatars;
}

- (NSMutableArray<NSString *> *)ceoxsoHeads {
    if (!_ceoxsoHeads) {
        _ceoxsoHeads = NSMutableArray.new;
    }return _ceoxsoHeads;
}

@end


@implementation LaAvatarRecordCRView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

@end
