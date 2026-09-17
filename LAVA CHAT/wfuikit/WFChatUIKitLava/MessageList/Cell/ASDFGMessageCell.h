//
//  MessageCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASDFGMessageCellBase.h"

@interface ASDFGMessageCell : ASDFGMessageCellBase
+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width;
@property (nonatomic, strong)UIImageView *trewqPortraitView;
@property (nonatomic, strong)UIButton *asoucUnreadButton;
@property (nonatomic, strong)UILabel *asoucNameLabel;
@property (nonatomic, strong)UIImageView *asoucBubbleView;
@property (nonatomic, strong)UIView *asoucContentArea;
@property (nonatomic, strong)UIView *asoucQuoteContainer;
@property (nonatomic, strong)UILabel *asoucQuoteLabel;
- (void)setMaskImage:(UIImage *)maskImage;
@end
