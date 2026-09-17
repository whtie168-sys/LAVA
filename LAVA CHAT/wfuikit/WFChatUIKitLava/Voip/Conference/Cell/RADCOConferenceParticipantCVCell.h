//
//  RADCOConferenceParticipantCVCell.h
//  WFChatUIKit
//
//  Created by dali on 2020/1/20.
//  Copyright © 2020 WildFireChat. All rights reserved.
//
#if WFCU_SUPPORT_VOIP
#import <UIKit/UIKit.h>
#import <LavaWFChatClient/WFCChatClient.h>
#import <Chat86AVEngineKit/Chat86AVEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RADCOConferenceParticipantCVCell : UICollectionViewCell
- (void)setUserInfo:(WFCCUserInfo *)userInfo callProfile:(WFAVParticipantProfile *)profile;

@property(nonatomic, strong, readonly)WFAVParticipantProfile *profile;
@end

NS_ASSUME_NONNULL_END
#endif
