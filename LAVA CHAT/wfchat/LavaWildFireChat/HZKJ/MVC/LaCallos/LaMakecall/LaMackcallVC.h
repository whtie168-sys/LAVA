//
//  LaMackcallVC.h
//  WildFireChat
//
//  Created by Ruby on 12/1/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"
#if WFCU_SUPPORT_VOIP
#import <Chat86AVEngineKit/Chat86AVEngineKit.h>
#endif
NS_ASSUME_NONNULL_BEGIN

@interface LaMackcallVC : LaMainVC

@property (nonatomic, copy) NSString *targetId; // 目标ID 用于过滤

@end

@interface LaMackcallTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (nonatomic, strong) WFCCUserInfo *userInfo;

@end

NS_ASSUME_NONNULL_END
