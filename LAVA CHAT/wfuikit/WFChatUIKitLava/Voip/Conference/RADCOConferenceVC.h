//
//  ViewController.h
//  WFDemo
//
//  Created by heavyrain on 17/9/27.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#if WFCU_SUPPORT_VOIP
@class RADCOConferenceInfo;
@class WFAVCallSession;
@class WFCCConversation;
@class WFCCConferenceInviteMessageContent;
@interface RADCOConferenceVC : UIViewController
- (instancetype)initWithSession:(WFAVCallSession *)session conferenceInfo:(RADCOConferenceInfo *)conferenceInfo;

- (instancetype)initWithConferenceInfo:(RADCOConferenceInfo *)conferenceInfo muteAudio:(BOOL)muteAudio muteVideo:(BOOL)muteVideo;

- (instancetype)initWithCallId:(NSString *_Nullable)callId
                     audioOnly:(BOOL)audioOnly
                           pin:(NSString *_Nullable)pin
                          host:(NSString *_Nullable)host
                         title:(NSString *_Nullable)title
                          desc:(NSString *_Nullable)desc
                      audience:(BOOL)audience
                      advanced:(BOOL)advanced
                        record:(BOOL)record
                        moCall:(BOOL)moCall
               maxParticipants:(int)maxParticipants
                         extra:(NSString *)extra;
@end
#endif
