//
//  LaNewsFriendInfoVC.h
//  LAVA
//
//  Created by Rubyuer on 10/22/23.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^AddFriendSuccessBlock)(void);

@interface LaNewsFriendInfoVC : LaMainVC

@property (nonatomic, strong) WFCCFriendRequest *request;

@property (nonatomic, copy) AddFriendSuccessBlock successBlock;

@end

NS_ASSUME_NONNULL_END
