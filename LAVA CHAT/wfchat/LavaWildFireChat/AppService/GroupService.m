//
//  GroupService.m
//  WildFireChat
//

#import "GroupService.h"

static GroupService *sharedGroupService = nil;

@implementation GroupService

+ (GroupService *)shared {
    if (!sharedGroupService) {
        @synchronized (self) {
            if (!sharedGroupService) {
                sharedGroupService = [[GroupService alloc] init];
            }
        }
    }
    return sharedGroupService;
}

- (void)getGroupMembers:(NSString *)groupId
            forceUpdate:(BOOL)forceUpdate
                success:(void(^)(NSArray<WFCCGroupMember *> *members))successBlock
                  error:(void(^)(int errorCode, NSString *message))errorBlock {
    NSArray<WFCCGroupMember *> *members = [[WFCCIMService sharedWFCIMService] getGroupMembers:groupId forceUpdate:forceUpdate];
    if (successBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(members ?: @[]);
        });
    }
}

@end
