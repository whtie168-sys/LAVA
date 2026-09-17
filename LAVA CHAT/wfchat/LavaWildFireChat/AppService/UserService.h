//
//  UserService.h
//  WildFireChat
//

#import <Foundation/Foundation.h>
#import <LavaWFChatClient/WFCChatClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserService : NSObject

+ (UserService *)shared;

- (void)loadAllFriend;

- (void)getMyFriendList:(BOOL)refresh
                success:(void(^)(NSArray<WFCCUserInfo *> *users, BOOL isCache))successBlock
                  error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)getUserInfo:(NSString *)userId
            refresh:(BOOL)refresh
            success:(void(^)(WFCCUserInfo *userInfo))successBlock
              error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)getUserInfo:(NSString *)userId
            success:(void(^)(WFCCUserInfo *userInfo))successBlock
              error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)getUserInfo:(NSString *)userId
            inGroup:(nullable NSString *)groupId
            refresh:(BOOL)refresh
            success:(void(^)(WFCCUserInfo *userInfo))successBlock
              error:(void(^)(int errorCode, NSString *message))errorBlock;

- (void)getUserInfos:(NSArray<NSString *> *)userIds
             inGroup:(nullable NSString *)groupId
             refresh:(BOOL)refresh
             success:(void(^)(NSArray<WFCCUserInfo *> *users))successBlock
               error:(void(^)(int errorCode, NSString *message))errorBlock;

@end

NS_ASSUME_NONNULL_END
