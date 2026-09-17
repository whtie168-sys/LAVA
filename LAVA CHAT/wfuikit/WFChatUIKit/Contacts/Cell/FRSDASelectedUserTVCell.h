//
//  FRSDASelectedUserTVCell.h
//  WFChatUIKit
//
//  Created by Zack Zhang on 2020/4/5.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSDASelectModel.h"
NS_ASSUME_NONNULL_BEGIN

@class ESZQSCOrganization;
@class FRSDASelectModel;
@protocol FRSDASelectedUserTVCellDelegate <NSObject>
- (void)didTapNextLevel:(FRSDASelectModel *)organization;
@end

@interface FRSDASelectedUserTVCell : UITableViewCell
@property (nonatomic, weak)id<FRSDASelectedUserTVCellDelegate> delegate;
@property (nonatomic, strong)FRSDASelectModel *selectedObject;
@property(nonatomic, strong)UIImageView *checkImageView;
@property(nonatomic, strong)UIImageView *trewqPortraitView;
@property(nonatomic, strong)UILabel *asoucNameLabel;
@property(nonatomic, strong)UIButton *nextLevel;

@end

NS_ASSUME_NONNULL_END
