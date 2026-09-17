//
//  LaShareCardVC.h
//  WildFireChat
//
//  Created by Ruby on 2/4/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaShareCardVC : LaMainVC

@property (nonatomic, copy) NSString *targetId;

@end

@interface LaShareIconTVCell : UITableViewCell

@property (nonatomic, strong) WFCCConversationInfo *info;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

NS_ASSUME_NONNULL_END
