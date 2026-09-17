//
//  LaGroupSetupVC.h
//  WildFireChat
//
//  Created by Ruby on 12/11/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaGroupSetupVC : LaMainVC

@property (nonatomic, strong) WFCCConversation *conversation;

@property (nonatomic, strong) TREWQGroupAnnouncement *groupAnnouncement;

@end

NS_ASSUME_NONNULL_END
