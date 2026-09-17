//
//  LaGroupAnnouncementVC.h
//  WildFireChat
//
//  Created by Ruby on 11/29/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaGroupAnnouncementVC : LaMainVC

@property(nonatomic, strong) TREWQGroupAnnouncement *announcement; // 该值有可能为空

@property(nonatomic, strong) NSString *groupId; //群id
/**
 发布者的身份信息
 */
@property(nonatomic, assign) WFCCGroupMemberType type;

@property (nonatomic, assign) BOOL isCanPost;

@property(nonatomic, copy) void (^deleteAnnouncementBlock)(void);

@end








@interface LaEditAnnouncementVC : LaMainVC

@property(nonatomic, copy)void (^editAnnouncementBlock)(TREWQGroupAnnouncement *announcement);

@property(nonatomic, strong) NSString *announcementText; // 最新的一条群公告消息 没有的话为""
@property(nonatomic, strong) NSString *groupId; //群id

@end

NS_ASSUME_NONNULL_END
