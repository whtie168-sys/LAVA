//
//  AllTopMessagePopupView.m
//  WildFireChat
//
//  Created by Rubyuer on 4/26/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "AllTopMessagePopupView.h"
#import "LaGroupAnnouncementVC.h"


@interface AllTopMessagePopupView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *coaeoxAView;

@property (weak, nonatomic) IBOutlet UICollectionView *coaeoxCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *coaeoxLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coaeoxCollectionHeight;

@property (weak, nonatomic) IBOutlet UIButton *coaeoxCloseBtn;

@property (nonatomic, strong) NSMutableArray<MessageTopList *> *results;
@end

@implementation AllTopMessagePopupView

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [NSBundle.mainBundle loadNibNamed:@"AllTopMessagePopupView" owner:self options:nil].lastObject;
        self.frame = CGRectMake(0.0, 0.0, WIDTH, HEIGHT);
        
        _coaeoxAView.layer.cornerRadius = 12.0;
        _coaeoxCloseBtn.layer.cornerRadius = 6.0;
        
        _coaeoxLayout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        _coaeoxLayout.itemSize = CGSizeMake(WIDTH, 50.0);
        _coaeoxLayout.minimumLineSpacing = 0.0;
        _coaeoxLayout.minimumInteritemSpacing = 0.0;
        _coaeoxCollectionView.delegate = self;
        _coaeoxCollectionView.dataSource = self;
        [_coaeoxCollectionView registerNib:[UINib nibWithNibName:@"AllTopMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AllTopMessageCollectionViewCell"];
    }
    return self;
}

- (void)showWithResult:(NSArray<MessageTopList *> *)results {
    [ShareAppDelegate.window addSubview:self];
    
    self.results = results.mutableCopy;
    _coaeoxCollectionHeight.constant = 50.0 * self.results.count;
//    [UIView animateWithDuration:0.35 animations:^{
//        [self layoutIfNeeded];
//    }];
    [_coaeoxCollectionView reloadData];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.results.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AllTopMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AllTopMessageCollectionViewCell" forIndexPath:indexPath];
    cell.topList = self.results[indexPath.row];
    cell.coaeoxRemoveBtn.tag = indexPath.row;
    [cell.coaeoxRemoveBtn addTarget:self action:@selector(coaeoxRemove:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AllTopMessageCollectionViewCell *cell = (AllTopMessageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.coaeoxRemoveBtn.selected) {
        cell.coaeoxRemoveBtn.selected = NO;
        cell.coaeoxRemoveBtn.backgroundColor = UIColor.clearColor;
        return;
    }
    
    MessageTopList *topList = self.results[indexPath.row];
    if (topList.content.type == 2000) { // 群公告消息更新的一个弹窗
        if (self.clickBlock) {
            self.clickBlock(2000);
        }
        [self removeFromSuperview];
    }else if (topList.content.type == 1001) { // 公告消息
        if (self.clickBlock) {
            self.clickBlock(indexPath.row);
        }
        [self removeFromSuperview];
    }else {
        if (self.clickBlock) {
            self.clickBlock(indexPath.row);
        }
        [self removeFromSuperview];
//        WS(weakself)
//        _coaeoxCollectionHeight.constant = 50.0;
//        [UIView animateWithDuration:0.35 animations:^{
//            [self layoutIfNeeded];
//        } completion:^(BOOL finished) {
//            if (weakself.clickBlock) {
//                weakself.clickBlock(indexPath.row);
//            }
//            [self removeFromSuperview];
//        }];
    }
}

- (void)coaeoxRemove:(UIButton *)sender {
    MessageTopList *topList = self.results[sender.tag];
    
    //公告删除
    if (topList.content.type == 2000) {
        if (self.gonggaoDelBlock) {
            self.gonggaoDelBlock(sender.tag);
            [self removeFromSuperview];
            return;
        }
    }

    if (sender.selected) {
        WS(weakself)
        [AppService.sharedAppService requestUrl:@"/group/message/top/delete" params:@{@"id":@(topList.id)} success:^(NSDictionary * _Nonnull dict) {
            [NSNotificationCenter.defaultCenter postNotificationName:kCancel_Group_Announcement_Top object:nil];
            [weakself.results removeObject:topList];
            
            if (weakself.results.count <= 0) {
                [weakself removeFromSuperview];
            }else {
                weakself.coaeoxCollectionHeight.constant = 50.0 * weakself.results.count;
                [weakself.coaeoxCollectionView reloadData];
            }
        }error:^(int errCode, NSString * _Nonnull message) {
            [weakself makeToast:message duration:0.5 position:CSToastPositionCenter];
        }];
        
        return;
    }
    sender.selected = YES;
    sender.backgroundColor = UIColor.whiteColor;
    sender.layer.cornerRadius = 6.0;
}


- (IBAction)coaeoxClose:(UIButton *)sender {
    _coaeoxCollectionHeight.constant = 50.0;
    [UIView animateWithDuration:0.35 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)cornerView:(UIView *)view round:(CGFloat)round rectCorners:(UIRectCorner)rectCorners {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:rectCorners cornerRadii:CGSizeMake(round, round)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = [maskPath CGPath];
    view.layer.mask = maskLayer;
}

- (NSMutableArray<MessageTopList *> *)results {
    if (!_results) {
        _results = NSMutableArray.new;
    }return _results;
}

@end


@interface AllTopMessageCollectionViewCell ()
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIView *coaeoxAView;

@property (weak, nonatomic) IBOutlet UIImageView *coaeoxImgView;
@property (weak, nonatomic) IBOutlet UILabel *coaeoxTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *coaeoxArrowView;

@end

@implementation AllTopMessageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _coaeoxAView.layer.cornerRadius = 10.0;
    _isChinese = [CommonHelper.main isChinese];
    [_coaeoxRemoveBtn setTitle:@"" forState:UIControlStateNormal];
}

- (void)setTopList:(MessageTopList *)topList {
    _topList = topList;

    if (topList.content.type == 2000) {
//        _coaeoxRemoveBtn.hidden = YES;
        _coaeoxArrowView.hidden = YES;
        
        _coaeoxImgView.image = IMAGENAME(@"coaeoxGG");
        _coaeoxTitleLabel.text = topList.content.searchableContent;
        
        _coaeoxRemoveBtn.selected = YES;
        [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"Remove")) forState:UIControlStateNormal];
        [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"Remove")) forState:UIControlStateSelected];
        return;
    }
    
    WFCCUserInfo *sender = [WFCCIMService.sharedWFCIMService getUserInfo:topList.fromUser refresh:NO];
    if (topList.content.type == 1) { // 文本消息
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: %@",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), topList.content.searchableContent];
    }else if (topList.content.type == 1001) { // 公告消息
        _coaeoxImgView.image = IMAGENAME(@"coaeoxGG");
        _coaeoxTitleLabel.text = topList.content.searchableContent;
    }else if (topList.content.type == 5) { // 文件消息
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: [%@] %@",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), (_isChinese ? @"文件" : @"tài liệu"), topList.content.searchableContent];
    } else if (topList.content.type == 3) { // 图片
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: [%@] %@",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), (_isChinese ? @"图片" : @"hình ảnh"),topList.content.searchableContent];
    } else if (topList.content.type == 6) { // 视频
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: [%@]",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), (_isChinese ? @"视频" : @"băng hình")];
    }
    _coaeoxRemoveBtn.hidden = NO;
    _coaeoxArrowView.hidden = YES;
    _coaeoxRemoveBtn.selected = NO;
    [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"Remove")) forState:UIControlStateNormal];
    [_coaeoxRemoveBtn setTitle:UNString(@"  %@  ", LLLLLL(@"Unpinned")) forState:UIControlStateSelected];
}

@end
