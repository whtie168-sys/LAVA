//
//  NewFriendTableViewCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSEDCBubbleTipView.h"

@interface FRSDANewFriendTVCell : UITableViewCell
@property (nonatomic, strong)UIImageView *trewqPortraitView;
@property (nonatomic, strong)UILabel *asoucNameLabel;
//@property (nonatomic, strong)WSEDCBubbleTipView *asoucBubbleView;
@property (nonatomic, strong) UILabel *asoucRedLabel;
- (void)refresh;

@property (nonatomic, strong) UIView *lineView; // 1204 新增
@property (nonatomic, assign) BOOL isHiddenLine;
@end
