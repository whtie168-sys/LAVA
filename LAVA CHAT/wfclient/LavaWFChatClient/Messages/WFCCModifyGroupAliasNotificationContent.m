//
//  WFCCModifyGroupAliasNotificationContent.m
//  WFChatClient
//
//  Created by heavyrain on 2017/9/20.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCModifyGroupAliasNotificationContent.h"
#import "WFCCIMService.h"
#import "WFCCNetworkService.h"
#import "Common.h"

@implementation WFCCModifyGroupAliasNotificationContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.operateUser) {
        [dataDict setObject:self.operateUser forKey:@"o"];
    }
    if (self.alias) {
        [dataDict setObject:self.alias forKey:@"n"];
    }
    
    if (self.groupId) {
        [dataDict setObject:self.groupId forKey:@"g"];
    }
    
    if (self.memberId) {
        [dataDict setObject:self.memberId forKey:@"m"];
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
        self.operateUser = dictionary[@"o"];
        self.alias = dictionary[@"n"];
        self.groupId = dictionary[@"g"];
        self.memberId = dictionary[@"m"];
    }
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_MODIFY_GROUP_ALIAS;
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
    if ([[WFCCNetworkService sharedInstance].userId isEqualToString:self.operateUser]) {
        formatMsg = (isChinese?@"你修改":@"Bạn sửa đổi ");
    } else {
        WFCCUserInfo *userInfo;
        if([self.operateUser isEqualToString:self.memberId]) {
            userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.operateUser refresh:NO];
        } else {
            userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.operateUser inGroup:self.groupId refresh:NO];
        }
        
        if (self.memberId.length && userInfo.groupAlias.length) {
            formatMsg = [NSString stringWithFormat:@"%@%@", userInfo.groupAlias, (isChinese?@"修改":@" tự đổi")];
        } else if (userInfo.friendAlias.length > 0) {
            formatMsg = [NSString stringWithFormat:@"%@%@", userInfo.friendAlias, (isChinese?@"修改":@" tự đổi")];
        } else if (userInfo.displayName.length > 0) {
            formatMsg = [NSString stringWithFormat:@"%@%@", userInfo.displayName, (isChinese?@"修改":@" tự đổi")];
        } else {
            formatMsg = [NSString stringWithFormat:@"%@%@", self.operateUser, (isChinese?@"修改":@" tự đổi")];
        }
    }
    
    if (self.memberId.length && ![self.memberId isEqualToString:self.operateUser]) {
        if ([[WFCCNetworkService sharedInstance].userId isEqualToString:self.memberId]) {
            formatMsg = [formatMsg stringByAppendingFormat:@"%@", (isChinese?@"你的":@" của anh ")];
        } else {
            WFCCUserInfo *member = [[WFCCIMService sharedWFCIMService] getUserInfo:self.memberId refresh:NO];
            if (member.friendAlias.length > 0) {
                formatMsg = [formatMsg stringByAppendingFormat:@"%@%@", member.friendAlias, (isChinese?@"的":@"")];
            } else if (member.displayName.length > 0) {
                formatMsg = [formatMsg stringByAppendingFormat:@"%@%@", member.displayName, (isChinese?@"的":@"")];
            } else {
                formatMsg = [formatMsg stringByAppendingFormat:@"%@%@", self.memberId, (isChinese?@"的":@"")];
            }
        }
    }
    
    formatMsg = [formatMsg stringByAppendingFormat:@"%@%@",(isChinese?@"群昵称为: ":@" biệt danh thành "), self.alias];
    return formatMsg;
}
@end
