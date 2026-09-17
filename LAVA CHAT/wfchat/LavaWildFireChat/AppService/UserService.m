//
//  UserService.m
//  WildFireChat
//

#import "UserService.h"

static UserService *sharedUserService = nil;

@implementation UserService

+ (UserService *)shared {
    if (!sharedUserService) {
        @synchronized (self) {
            if (!sharedUserService) {
                sharedUserService = [[UserService alloc] init];
            }
        }
    }
    return sharedUserService;
}

- (void)loadAllFriend {
    [[WFCCIMService sharedWFCIMService] getMyFriendList:YES];
}

- (void)getMyFriendList:(BOOL)refresh
                success:(void(^)(NSArray<WFCCUserInfo *> *users, BOOL isCache))successBlock
                  error:(void(^)(int errorCode, NSString *message))errorBlock {
    NSArray<NSString *> *userIds = [[WFCCIMService sharedWFCIMService] getMyFriendList:refresh];
    NSMutableArray<WFCCUserInfo *> *users = [NSMutableArray array];
    for (NSString *userId in userIds) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
        if (!userInfo) {
            continue;
        }
        if ([userInfo.name isEqualToString:@"FireRobot"] ||
            [userInfo.userId isEqualToString:@"FireRobot"] ||
            [userInfo.name isEqualToString:@"wfc_file_transfer"] ||
            [userInfo.name isEqualToString:@"group_message"]) {
            continue;
        }
        [users addObject:userInfo];
    }
    if (successBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(users, !refresh);
        });
    }
}

- (void)getUserInfo:(NSString *)userId
            refresh:(BOOL)refresh
            success:(void(^)(WFCCUserInfo *userInfo))successBlock
              error:(void(^)(int errorCode, NSString *message))errorBlock {
    if (!userId.length) {
        if (errorBlock) errorBlock(-1, @"userId is empty");
        return;
    }
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:refresh];
    if (successBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(userInfo);
        });
    }
}

- (void)getUserInfo:(NSString *)userId
            success:(void(^)(WFCCUserInfo *userInfo))successBlock
              error:(void(^)(int errorCode, NSString *message))errorBlock {
    [self getUserInfo:userId refresh:YES success:successBlock error:errorBlock];
}

- (void)getUserInfo:(NSString *)userId
            inGroup:(NSString *)groupId
            refresh:(BOOL)refresh
            success:(void(^)(WFCCUserInfo *userInfo))successBlock
              error:(void(^)(int errorCode, NSString *message))errorBlock {
    if (!userId.length) {
        if (errorBlock) errorBlock(-1, @"userId is empty");
        return;
    }
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId inGroup:groupId refresh:refresh];
    if (successBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(userInfo);
        });
    }
}

- (void)getUserInfos:(NSArray<NSString *> *)userIds
             inGroup:(NSString *)groupId
             refresh:(BOOL)refresh
             success:(void(^)(NSArray<WFCCUserInfo *> *users))successBlock
               error:(void(^)(int errorCode, NSString *message))errorBlock {
    NSMutableArray<WFCCUserInfo *> *users = [NSMutableArray array];
    for (NSString *userId in userIds) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId inGroup:groupId refresh:refresh];
        if (userInfo) {
            [users addObject:userInfo];
        }
    }
    if (successBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(users);
        });
    }
}

@end
