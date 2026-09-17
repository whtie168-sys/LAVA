//
//  LavaWFChatClient.h
//  LavaWFChatClient
//
//  Created by heavyrain on 2017/11/5.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for LavaWFChatClient.
FOUNDATION_EXPORT double LavaWFChatClientVersionNumber;

//! Project version string for LavaWFChatClient.
FOUNDATION_EXPORT const unsigned char LavaWFChatClientVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LavaWFChatClient/PublicHeader.h>


#import <LavaWFChatClient/WFCCIMService.h>
#import <LavaWFChatClient/WFCCNetworkService.h>
#import <LavaWFChatClient/Common.h>
#import <LavaWFChatClient/WFCCProtocol.h>
#import <LavaWFChatClient/WFCCJsonSerializer.h>
#import <LavaWFChatClient/WFCCMessage.h>
#import <LavaWFChatClient/WFCCMessageContent.h>
#import <LavaWFChatClient/WFCCAddGroupeMemberNotificationContent.h>
#import <LavaWFChatClient/WFCCCreateGroupNotificationContent.h>
#import <LavaWFChatClient/WFCCDismissGroupNotificationContent.h>
#import <LavaWFChatClient/WFCCImageMessageContent.h>
#import <LavaWFChatClient/WFCCKickoffGroupMemberNotificationContent.h>
#import <LavaWFChatClient/WFCCMediaMessageContent.h>
#import <LavaWFChatClient/WFCCNotificationMessageContent.h>
#import <LavaWFChatClient/WFCCTipNotificationMessageContent.h>
#import <LavaWFChatClient/WFCCQuitGroupNotificationContent.h>
#import <LavaWFChatClient/WFCCSoundMessageContent.h>
#import <LavaWFChatClient/WFCCPTTSoundMessageContent.h>
#import <LavaWFChatClient/WFCCFileMessageContent.h>
#import <LavaWFChatClient/WFCCTextMessageContent.h>
#import <LavaWFChatClient/WFCCPTextMessageContent.h>
#import <LavaWFChatClient/WFCCUnknownMessageContent.h>
#import <LavaWFChatClient/WFCCChangeGroupNameNotificationContent.h>
#import <LavaWFChatClient/WFCCChangeGroupPortraitNotificationContent.h>
#import <LavaWFChatClient/WFCCModifyGroupAliasNotificationContent.h>
#import <LavaWFChatClient/WFCCTransferGroupOwnerNotificationContent.h>
#import <LavaWFChatClient/WFCCStickerMessageContent.h>
#import <LavaWFChatClient/WFCCLocationMessageContent.h>
#import <LavaWFChatClient/WFCCCallStartMessageContent.h>
#import <LavaWFChatClient/WFCCCallAddParticipantMessageContent.h>
#import <LavaWFChatClient/WFCCCallByeMessageContent.h>
#import <LavaWFChatClient/WFCCTypingMessageContent.h>
#import <LavaWFChatClient/WFCCRecallMessageContent.h>
#import <LavaWFChatClient/WFCCVideoMessageContent.h>
#import <LavaWFChatClient/WFCCFriendAddedMessageContent.h>
#import <LavaWFChatClient/WFCCFriendGreetingMessageContent.h>
#import <LavaWFChatClient/WFCCGroupPrivateChatNotificationContent.h>
#import <LavaWFChatClient/WFCCGroupJoinTypeNotificationContent.h>
#import <LavaWFChatClient/WFCCGroupSetManagerNotificationContent.h>
#import <LavaWFChatClient/WFCCGroupMemberMuteNotificationContent.h>
#import <LavaWFChatClient/WFCCGroupMemberAllowNotificationContent.h>
#import <LavaWFChatClient/WFCCDeleteMessageContent.h>
#import <LavaWFChatClient/WFCCGroupMuteNotificationContent.h>
#import <LavaWFChatClient/WFCCPCLoginRequestMessageContent.h>
#import <LavaWFChatClient/WFCCCardMessageContent.h>
#import <LavaWFChatClient/WFCCThingsDataContent.h>
#import <LavaWFChatClient/WFCCThingsLostEventContent.h>
#import <LavaWFChatClient/WFCCConferenceInviteMessageContent.h>
#import <LavaWFChatClient/WFCCCompositeMessageContent.h>
#import <LavaWFChatClient/WFCCLinkMessageContent.h>
#import <LavaWFChatClient/WFCCChannelMenu.h>
#import <LavaWFChatClient/WFCCKickoffGroupMemberVisibleNotificationContent.h>
#import <LavaWFChatClient/WFCCQuitGroupVisibleNotificationContent.h>
#import <LavaWFChatClient/WFCCModifyGroupMemberExtraNotificationContent.h>
#import <LavaWFChatClient/WFCCModifyGroupExtraNotificationContent.h>
#import <LavaWFChatClient/WFCCChannelMenuEventMessageContent.h>
#import <LavaWFChatClient/WFCCStartSecretChatMessageContent.h>
#import <LavaWFChatClient/WFCCEnterChannelChatMessageContent.h>
#import <LavaWFChatClient/WFCCLeaveChannelChatMessageContent.h>
#import <LavaWFChatClient/WFCCJoinCallRequestMessageContent.h>
#import <LavaWFChatClient/WFCCGroupSettingsNotificationContent.h>
#import <LavaWFChatClient/WFCCMultiCallOngoingMessageContent.h>
#import <LavaWFChatClient/WFCCRichNotificationMessageContent.h>
#import <LavaWFChatClient/WFCCArticlesMessageContent.h>
#import <LavaWFChatClient/WFCCRawMessageContent.h>
#import <LavaWFChatClient/WFCCConversation.h>
#import <LavaWFChatClient/WFCCConversationInfo.h>
#import <LavaWFChatClient/WFCCConversationSearchInfo.h>
#import <LavaWFChatClient/WFCCGroupSearchInfo.h>
#import <LavaWFChatClient/WFCCFriendRequest.h>
#import <LavaWFChatClient/WFCCFriend.h>
#import <LavaWFChatClient/WFCCUserTag.h>
#import <LavaWFChatClient/WFCCGroupInfo.h>
#import <LavaWFChatClient/WFCCGroupMember.h>
#import <LavaWFChatClient/WFCCUserInfo.h>
#import <LavaWFChatClient/WFCCChatroomInfo.h>
#import <LavaWFChatClient/WFCCUnreadCount.h>
#import <LavaWFChatClient/WFCCUtilities.h>
#import <LavaWFChatClient/WFCCPCOnlineInfo.h>
#import <LavaWFChatClient/WFCCDeliveryReport.h>
#import <LavaWFChatClient/WFCCReadReport.h>
#import <LavaWFChatClient/WFCCFileRecord.h>
#import <LavaWFChatClient/WFCCQuoteInfo.h>
#import <LavaWFChatClient/WFCCUserOnlineState.h>
#import <LavaWFChatClient/WFCCSecretChatInfo.h>
#import <LavaWFChatClient/WFCCEnums.h>
#import <LavaWFChatClient/WFCCCommunity.h>
#import <LavaWFChatClient/WFCCCommunityUser.h>
#import <LavaWFChatClient/WFCCSign.h>
#import <LavaWFChatClient/WFCCResign.h>
#import <LavaWFChatClient/WFCCSignTasks.h>
#import <LavaWFChatClient/WFCCSignHistory.h>
#import <LavaWFChatClient/WFCCPointsHistory.h>
