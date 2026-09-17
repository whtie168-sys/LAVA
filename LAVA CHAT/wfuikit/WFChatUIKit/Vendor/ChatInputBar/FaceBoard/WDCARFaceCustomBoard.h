//
//  WDCARFaceCustomBoard.h
//  WFChatUIKit
//
//  Created by wtb on 2025/5/16.
//  Copyright © 2025 Tom Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WDCARFaceCustomBoardDelegate <NSObject>

@optional
- (void)didSelectedSticker:(NSString *)stickerPath;
- (void)didEmojSettingBtn;

@end

@interface WDCARFaceCustomBoard : UIView


@property (nonatomic, weak) id<WDCARFaceCustomBoardDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame type:(int)type;
@end

NS_ASSUME_NONNULL_END
