//
//  RADCOConferenceHistory.m
//  WFChatUIKit
//
//  Created by Rain on 2022/9/16.
//  Copyright © 2022 Wildfirechat. All rights reserved.
//

#import "RADCOConferenceHistory.h"
#import "RADCOConferenceInfo.h"
@implementation RADCOConferenceHistory
+ (instancetype)fromDictionary:(NSDictionary *)dictionary {
    RADCOConferenceHistory *history = [[RADCOConferenceHistory alloc] init];
    history.timestamp = [dictionary[@"timestamp"] longLongValue];
    history.duration = [dictionary[@"duration"] intValue];
    history.conferenceInfo = [RADCOConferenceInfo fromDictionary:dictionary[@"info"]];
    return history;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"info"] = [self.conferenceInfo toDictionary];
    dict[@"timestamp"] = @(self.timestamp);
    dict[@"duration"] = @(self.duration);
    return dict;
}
@end
