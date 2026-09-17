//
//  MessageCellBase.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QWERTMessageModel.h"

@class ASDFGMessageCellBase;

@protocol ASDFGMessageCellDelegate <NSObject>
- (void)didTapMessageCell:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;
- (void)didTapMessagePortrait:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;
- (void)didLongPressMessageCell:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;
- (void)didLongPressMessagePortrait:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;
- (void)didTapResendBtn:(QWERTMessageModel *)model;

- (void)didSelectUrl:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model withUrl:(NSString *)urlString;
- (void)didSelectPhoneNumber:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model withPhoneNumber:(NSString *)phoneNumber;
- (void)reeditRecalledMessage:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;

@optional
- (void)didTapReceiptView:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;
- (void)didDoubleTapMessageCell:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;
- (void)didTapasoucQuoteLabel:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model;
- (void)didTapArticleCell:(ASDFGMessageCellBase *)cell withModel:(QWERTMessageModel *)model withArticle:(WFCCArticle *)article;
@end

@interface ASDFGMessageCellBase : UICollectionViewCell
@property (nonatomic, strong)UILabel *timeLabel;
@property (nonatomic, strong)UIView *lastReadContainerView;
@property (nonatomic, strong)QWERTMessageModel *model;
@property (nonatomic, weak)id<ASDFGMessageCellDelegate> delegate;
+ (CGSize)sizeForCell:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width;
+ (CGFloat)hightForHeaderArea:(QWERTMessageModel *)msgModel;

- (void)onTaped:(id)sender;
- (void)onLongPressed:(id)sender;
@end
