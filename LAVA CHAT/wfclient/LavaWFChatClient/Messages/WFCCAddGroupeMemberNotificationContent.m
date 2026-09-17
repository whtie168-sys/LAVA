//
//  WFCCAddGroupeMemberNotificationContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/9/20.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCAddGroupeMemberNotificationContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"


@implementation WFCCAddGroupeMemberNotificationContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.invitor) {
        [dataDict setObject:self.invitor forKey:@"o"];
    }
    
    if (self.invitees) {
        [dataDict setObject:self.invitees forKey:@"ms"];
    }
    
    if (self.groupId) {
        [dataDict setObject:self.groupId forKey:@"g"];
    }
    
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dataDict
                                                            options:kNilOptions
                                                              error:nil];
    
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.invitor = dictionary[@"o"];
        self.invitees = dictionary[@"ms"];
        self.groupId = dictionary[@"g"];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_ADD_GROUP_MEMBER;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST;
}



+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
    return [self formatNotification:message];
}

- (NSString *)formatNotification:(WFCCMessage *)message {
    BOOL isChinese = [WFCCIMService.main isChinese];
    NSString *formatMsg;
    if ([self.invitees count] == 1 && [[self.invitees objectAtIndex:0] isEqualToString:self.invitor]) {
        if ([[WFCCNetworkService sharedInstance].userId isEqualToString:self.invitor]) {
            formatMsg = (isChinese?@"你加入了群聊":@"Bạn tham gia vào nhóm chat");
        } else {
            WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.invitor inGroup:self.groupId refresh:NO];
            if (userInfo.friendAlias.length > 0) {
                formatMsg = [NSString stringWithFormat:@"%@%@", userInfo.friendAlias, (isChinese?@"加入了群聊":@" tham gia nhóm chat")];
            } else if(userInfo.groupAlias.length > 0) {
                formatMsg = [NSString stringWithFormat:@"%@%@", userInfo.groupAlias, (isChinese?@"加入了群聊":@" tham gia nhóm chat")];
            } else if (userInfo.displayName.length > 0) {
                formatMsg = [NSString stringWithFormat:@"%@%@", userInfo.displayName, (isChinese?@"加入了群聊":@" tham gia nhóm chat")];
            } else {
                formatMsg = [NSString stringWithFormat:@"%@%@", self.invitor, (isChinese?@"加入了群聊":@" tham gia nhóm chat")];
            }
        }
        return formatMsg;
    }
    
    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:self.invitor]) {
        formatMsg = (isChinese?@"你邀请":@"Bạn đã mời ");
    } else {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.invitor refresh:NO];
        if (userInfo.displayName.length > 0) {
            formatMsg = [NSString stringWithFormat:@"%@%@", userInfo.displayName, (isChinese?@"邀请":@" mời")];
        } else {
            formatMsg = [NSString stringWithFormat:@"%@%@", self.invitor, (isChinese?@"邀请":@" mời")];
        }
    }
    
    int count = 0;
    if([self.invitees containsObject:[WFCCNetworkService sharedInstance].userId]) {
        formatMsg = [formatMsg stringByAppendingString:(isChinese?@" 你":@" bạn")];
        count++;
    }

    for (NSString *member in self.invitees) {
        if ([member isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            continue;
        } else {
            WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:member refresh:NO];
            if (userInfo.displayName.length > 0) {
                formatMsg = [formatMsg stringByAppendingFormat:@" %@", userInfo.displayName];
            } else {
                formatMsg = [formatMsg stringByAppendingFormat:@" %@", member];
            }
            
            count++;
            if(count >= 4) {
                break;
            }
        }
    }
    
    if (self.invitees.count > count) {
        if (isChinese) {
            formatMsg = [formatMsg stringByAppendingFormat:@" 等%ld名成员", self.invitees.count];
        }else {
            formatMsg = [formatMsg stringByAppendingFormat:@" %ld thành viên", self.invitees.count];
        }
    }
    formatMsg = [formatMsg stringByAppendingString:(isChinese?@"加入了群聊":@" vào nhóm")];
    return formatMsg;
}
@end
