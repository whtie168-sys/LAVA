//
//  RADCOConferencePortraitCVCell.h
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

@interface RADCOConferencePortraitCVCell : UICollectionViewCell
@property (nonatomic, strong)WFCCUserInfo *userInfo;
@property (nonatomic, strong)WFAVParticipantProfile *profile;

@property (nonatomic, assign)CGFloat itemSize;
@property (nonatomic, assign)CGFloat labelSize;
@end

NS_ASSUME_NONNULL_END
#endif
