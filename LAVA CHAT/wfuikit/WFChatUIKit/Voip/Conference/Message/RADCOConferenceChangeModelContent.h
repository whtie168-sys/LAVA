//
//  RADCOConferenceChangeModelContent.h
//  WFChatUIKit
//
//  Created by Tom Lee on 2021/2/15.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LavaWFChatClient/WFCChatClient.h>

@interface RADCOConferenceChangeModelContent : WFCCMessageContent
@property (nonatomic, strong) NSString *conferenceId;
@property (nonatomic, assign) BOOL isAudience;
@end
