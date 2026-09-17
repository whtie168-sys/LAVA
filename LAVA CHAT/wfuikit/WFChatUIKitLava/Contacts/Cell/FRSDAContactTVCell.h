//
//  ContactTableViewCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSDAContactTVCell : UITableViewCell
- (void)setUserId:(NSString *)userId groupId:(NSString *)groupId;
@property (nonatomic, strong)UIImageView *trewqPortraitView;
@property (nonatomic, strong)UILabel *asoucNameLabel;

@property (nonatomic, strong)UIImageView *asoucOnlineView;

@property (nonatomic, assign, getter=isBig)BOOL big;

@property (nonatomic, strong) UIView *lineView; // 1204 新增
@property (nonatomic, assign) BOOL isHiddenLine;
@end
