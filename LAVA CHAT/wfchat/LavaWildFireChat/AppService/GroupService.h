//
//  GroupService.h
//  WildFireChat
//

#import <Foundation/Foundation.h>
#import <LavaWFChatClient/WFCChatClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupService : NSObject

+ (GroupService *)shared;

- (void)getGroupMembers:(NSString *)groupId
            forceUpdate:(BOOL)forceUpdate
                success:(void(^)(NSArray<WFCCGroupMember *> *members))successBlock
                  error:(void(^)(int errorCode, NSString *message))errorBlock;

@end

NS_ASSUME_NONNULL_END
