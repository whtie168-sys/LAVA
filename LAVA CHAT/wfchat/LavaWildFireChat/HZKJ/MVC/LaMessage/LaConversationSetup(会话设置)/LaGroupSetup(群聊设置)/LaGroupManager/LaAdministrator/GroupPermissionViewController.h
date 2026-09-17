//
//  GroupPermissionViewController.h
//  WildFireChat
//
//  Created by wtb on 2025/7/6.
//  Copyright © 2025 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupPermissionViewController : LaMainVC
@property (nonatomic, strong)WFCCGroupInfo *groupInfo;
@property (nonatomic, strong)NSString *userId;

@end

NS_ASSUME_NONNULL_END
