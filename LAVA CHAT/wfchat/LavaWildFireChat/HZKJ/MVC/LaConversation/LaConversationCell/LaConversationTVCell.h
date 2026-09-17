//
//  LaConversationTVCell.h
//  WildFireChat
//
//  Created by Ruby on 1/31/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaConversationTVCell : UITableViewCell

@property (nonatomic, strong) WFCCConversationInfo *info;

@property (nonatomic, assign, getter=isBig) BOOL big;


@property (weak, nonatomic) IBOutlet UIButton *stateButton;
// 默认 0   编辑 29
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeft;

@end

NS_ASSUME_NONNULL_END
