//
//  RADCOConferenceHistory.h
//  WFChatUIKit
//
//  Created by Rain on 2022/9/16.
//  Copyright © 2022 Wildfirechat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RADCOConferenceInfo;
@interface RADCOConferenceHistory : NSObject
@property(nonatomic, strong)RADCOConferenceInfo *conferenceInfo;
@property(nonatomic, assign)int64_t timestamp;
@property(nonatomic, assign)int duration;

+ (instancetype)fromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;
@end

NS_ASSUME_NONNULL_END
