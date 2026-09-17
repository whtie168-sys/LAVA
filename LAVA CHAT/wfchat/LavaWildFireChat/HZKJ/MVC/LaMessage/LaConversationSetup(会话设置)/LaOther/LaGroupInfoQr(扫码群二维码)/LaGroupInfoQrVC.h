//
//  LaGroupInfoQrVC.h
//  WildFireChat
//
//  Created by Ruby on 12/27/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaGroupInfoQrVC : LaMainVC

@property(nonatomic, strong)NSString *groupId;

@property (nonatomic, assign) WFCUGroupMemberSourceType sourceType;

@end

NS_ASSUME_NONNULL_END
