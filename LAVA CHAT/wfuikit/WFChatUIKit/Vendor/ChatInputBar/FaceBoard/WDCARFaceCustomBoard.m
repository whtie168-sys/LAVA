//
//  WDCARFaceCustomBoard.m
//  WFChatUIKit
//
//  Created by wtb on 2025/5/16.
//  Copyright © 2025 Tom Lee. All rights reserved.
//

#import "WDCARFaceCustomBoard.h"
#import "WDCARStickerItem.h"
#import "YLGIFImage.h"
#import "WDCARFaceButton.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "WDCARFaceEmojCustomCell.h"
#import "UIColor+YH.h"

@interface WDCARFaceCustomBoard() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableDictionary<NSString *, WDCARStickerItem *> *stickers;
@property CGFloat numberOfItemsPerRow;

@property int type; //0:表情 1:添加 2:宠物 3:旗帜 4:足球
@property NSString *keyType;
@end

@implementation WDCARFaceCustomBoard

- (instancetype)initWithFrame:(CGRect)frame type:(int)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        NSString *key = @"宠物.png";
        if (self.type == 3) {
            key = @"旗帜.png";
        } else if (self.type == 4) {
            key = @"足球.png";
        }
        self.keyType = key;
        [self loadStickers];

        self.backgroundColor = [UIColor colorWithHexString:@"#FBFBFB"];
        [self addSubview:self.collectionView];
    }
    return self;
}


+ (NSString *)getStickerCachePath {
    NSArray * LibraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[LibraryPaths objectAtIndex:0] stringByAppendingFormat:@"/Caches/Patch/"];
}

+ (NSString *)getStickerBundleName {
    NSString * bundleName = @"Stickers.bundle";
    return bundleName;
}

+ (void)load {
    [WDCARFaceCustomBoard initStickers];
}

+ (void)initStickers {
    NSString * bundleName = [WDCARFaceCustomBoard getStickerBundleName];
    NSError * err = nil;
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    
    NSString * cacheBundleDir = [WDCARFaceCustomBoard getStickerCachePath];
    NSLog(@"缓存资源目录: %@", cacheBundleDir);
    
    if (![defaultManager fileExistsAtPath:cacheBundleDir]) {
        [defaultManager createDirectoryAtPath:cacheBundleDir withIntermediateDirectories:YES attributes:nil error: &err];
        
        if(err){
            NSLog(@"初始化目录出错:%@", err);
            return;
        }
    }
    NSString * defaultBundlePath = [[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent: bundleName];
    
    NSString * cacheBundlePath = [cacheBundleDir stringByAppendingPathComponent:bundleName];
    if (![defaultManager fileExistsAtPath:cacheBundlePath]) {
        [defaultManager copyItemAtPath: defaultBundlePath toPath:cacheBundlePath error: &err];
        if(err){
            NSLog(@"复制初始资源文件出错:%@", err);
        }
    }
}

- (void)loadStickers {
    self.stickers = [[NSMutableDictionary alloc] init];
    
    NSString *stickerPath = [[WDCARFaceCustomBoard getStickerCachePath] stringByAppendingPathComponent:[WDCARFaceCustomBoard getStickerBundleName]];
    
    NSError * err = nil;
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSArray *paths = [defaultManager contentsOfDirectoryAtPath:stickerPath error:&err];
    if (err != nil) {
        NSLog(@"error:%@", err);
        return;
    }
    
    for (NSString *file in paths) {
        BOOL isDir = false;
        NSString *absfile = [stickerPath stringByAppendingPathComponent:file];
        if ([defaultManager fileExistsAtPath:absfile isDirectory:&isDir]) {
            if (!isDir) {
                WDCARStickerItem *item = [[WDCARStickerItem alloc] init];
                item.key = file;
                item.tabIcon = absfile;
                item.stickerPaths = [[NSMutableArray alloc] init];
                NSString *name = [[file lastPathComponent] stringByDeletingPathExtension];
                NSString *stickerSubPath = [stickerPath stringByAppendingPathComponent:name];
                if ([defaultManager fileExistsAtPath:stickerSubPath isDirectory:&isDir]) {
                    if (isDir) {
                        NSArray *paths = [defaultManager contentsOfDirectoryAtPath:stickerSubPath error:&err];
                        if (err != nil) {
                            NSLog(@"error:%@", err);
                            return;
                        }
                        for (NSString *p in paths) {
                            NSString *stickerabsfile = [stickerSubPath stringByAppendingPathComponent:p];
                            if ([defaultManager fileExistsAtPath:stickerabsfile isDirectory:&isDir]) {
                                if (!isDir) {
                                    [item.stickerPaths addObject:stickerabsfile];
                                }
                            }
                        }
                    }
                }
                self.stickers[item.key] = item;
            } else {
                NSLog(@"is dir %@", absfile);
            }
        }
    }
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        CGFloat numberOfItemsPerRow = 8.0;
        if (self.type == 4) {
            numberOfItemsPerRow = 4;
        }
        self.numberOfItemsPerRow = numberOfItemsPerRow;
        CGFloat spacing = 4.0;
        CGFloat totalSpacing = spacing * (numberOfItemsPerRow - 1);

        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat itemWidth = (screenWidth - totalSpacing) / numberOfItemsPerRow;

        // 设置 item 大小（宽高一致，正方形）
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);

        // 设置间距
        layout.minimumInteritemSpacing = spacing;
        layout.minimumLineSpacing = spacing;
                
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[WDCARFaceEmojCustomCell class] forCellWithReuseIdentifier:@"WDCARFaceEmojCustomCell"];
    }
    return _collectionView;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stickers[self.keyType].stickerPaths.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WDCARFaceEmojCustomCell * cell = (WDCARFaceEmojCustomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WDCARFaceEmojCustomCell" forIndexPath:indexPath];

    NSArray *paths = self.stickers[self.keyType].stickerPaths;
    
    cell.emojBtn.buttonIndex = indexPath.row;
    cell.emojBtn.frame = cell.bounds;
    [cell.emojBtn addTarget:self
                   action:@selector(onTapSticker:)
         forControlEvents:UIControlEventTouchUpInside];
    
    if ([[paths[indexPath.row] pathExtension] isEqualToString:@"gif"]) {
        cell.emojBtn.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/7, 44);
        [cell.emojBtn setImage:[YLGIFImage imageWithContentsOfFile:paths[indexPath.row]] forState:UIControlStateNormal];
    } else {
        [cell.emojBtn setImage:[UIImage imageWithContentsOfFile:paths[indexPath.row]] forState:UIControlStateNormal];
    }
    return cell;
}

- (void)onTapSticker:(WDCARFaceButton *)sender {
    NSString *selectSticker = self.stickers[self.keyType].stickerPaths[sender.buttonIndex];
    if ([self.delegate respondsToSelector:@selector(didSelectedSticker:)]) {
        [self.delegate didSelectedSticker:selectSticker];
    }
}
@end
