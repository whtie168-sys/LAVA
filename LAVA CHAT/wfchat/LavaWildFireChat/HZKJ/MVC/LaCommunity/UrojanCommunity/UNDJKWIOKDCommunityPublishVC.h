//
//  UNDJKWIOKDCommunityPublishVC.h
//  WUHOIBDK
//

#import "LaMainVC.h"
@class WFCCCommunity;

NS_ASSUME_NONNULL_BEGIN

@interface UNDJKWIOKDCommunityPublishVC : LaMainVC

@property (nonatomic, copy, nullable) void(^publishSuccessBlock)(void);
@property (nonatomic, strong, nullable) WFCCCommunity *articleToEdit;

@end

NS_ASSUME_NONNULL_END
