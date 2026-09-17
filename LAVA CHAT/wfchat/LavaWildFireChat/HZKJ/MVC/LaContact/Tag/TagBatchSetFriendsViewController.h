//
//  TagBatchSetFriendsViewController.h
//  WildFireChat
//
//  Created by OpenAI on 2026/3/29.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface TagBatchSetFriendsViewController : LaMainVC

@property (nonatomic, strong) NSArray<WFCCUserInfo *> *friendInfos;
@property (nonatomic, assign) NSInteger totalCount;

@end

NS_ASSUME_NONNULL_END
