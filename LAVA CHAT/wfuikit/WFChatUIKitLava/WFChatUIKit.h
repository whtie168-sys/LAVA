//
//  WFChatUIKit.h
//  WFChatUIKit
//
//  Created by WF Chat on 2018/10/23.
//  Copyright © 2018 WF Chat. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for WFChatUIKit.
FOUNDATION_EXPORT double WFChatUIKitVersionNumber;

//! Project version string for WFChatUIKit.
FOUNDATION_EXPORT const unsigned char WFChatUIKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WFChatUIKitLava/PublicHeader.h>


#import <WFChatUIKitLava/Predefine.h>
#import <WFChatUIKitLava/ASECWConversationTableVC.h>
#import <WFChatUIKitLava/FRSDAContactListVC.h>
#import <WFChatUIKitLava/QWERMessageListVC.h>
#import <WFChatUIKitLava/RADCOVideoVC.h>
#import <WFChatUIKitLava/RADCOMultiVideoVC.h>
#import <WFChatUIKitLava/RADCOConferenceVC.h>
#import <WFChatUIKitLava/QWERTMyPortraitVC.h>
#import <WFChatUIKitLava/QWERTMyProfileTVC.h>
#import <WFChatUIKitLava/RWADCProfileTableVC.h>
#import <WFChatUIKitLava/DSRACGeneralSwitchTVCell.h>
#import <WFChatUIKitLava/RWADCBlackListVC.h>
#import <WFChatUIKitLava/TREWQGroupInfoVC.h>
#import <WFChatUIKitLava/QWASZForwardVC.h>
#import <WFChatUIKitLava/ASEDCFilesEntryVC.h>
#import <WFChatUIKitLava/ASEDCFilesVC.h>
#import <WFChatUIKitLava/RADCOConferenceInfo.h>

#import <WFChatUIKitLava/QrCodeHelper.h>
#import <WFChatUIKitLava/RWADCBrowserVC.h>

#import <WFChatUIKitLava/QWERMediaMessageDownloader.h>
#import <WFChatUIKitLava/QAZXSWEnum.h>
#import <WFChatUIKitLava/UIView+Toast.h>

#import <WFChatUIKitLava/KZVideoConfig.h>
#import <WFChatUIKitLava/KZVideoViewController.h>

#import <WFChatUIKitLava/VideoPlayerKit.h>
#import <WFChatUIKitLava/VideoPlayer.h>
#import <WFChatUIKitLava/VideoPlayerView.h>
#import <WFChatUIKitLava/AirplayActiveView.h>
#import <WFChatUIKitLava/MWPhotoBrowser.h>

#import <WFChatUIKitLava/QWERConfigManager.h>

#import <WFChatUIKitLava/QWERAppServiceProvider.h>
#import <WFChatUIKitLava/TREWQGroupAnnouncement.h>
#import <WFChatUIKitLava/QWERFavoriteItem.h>

#import <WFChatUIKitLava/WSEDCBubbleTipView.h>
#import <WFChatUIKitLava/UITabBar+badge.h>
#import <WFChatUIKitLava/QWERUtilities.h>

#import <WFChatUIKitLava/AUETAFavChannelTableVC.h>
#import <WFChatUIKitLava/RWADCGeneralModifyVC.h>
#import <WFChatUIKitLava/QWERCompositeMessageVC.h>
#import <WFChatUIKitLava/WDCARLocationViewController.h>
#import <WFChatUIKitLava/WDCARLocationPoint.h>

#import <WFChatUIKitLava/RADCOOrderConferenceVC.h>
#import <WFChatUIKitLava/RADCOHomeVC.h>
#import <WFChatUIKitLava/RADCOConferenceInfoVC.h>
#import <WFChatUIKitLava/RADCOStartConferenceVC.h>


#import <WFChatUIKitLava/CreateBarCodeViewController.h>
#import <WFChatUIKitLava/QQLBXScanViewController.h>
#import <WFChatUIKitLava/LBXScanVideoZoomView.h>

#import <WFChatUIKitLava/LBXPermission.h>
#import <WFChatUIKitLava/LBXPermissionSetting.h>
#import <WFChatUIKitLava/LBXAlertAction.h>

#import <WFChatUIKitLava/LBXScanViewStyle.h>
#import <WFChatUIKitLava/StyleDIY.h>
#import <WFChatUIKitLava/QWERImage.h>

#import <WFChatUIKitLava/ESZQSCOrganization.h>
#import <WFChatUIKitLava/ESZQSCEmployee.h>
#import <WFChatUIKitLava/ESZQSCEmployeeEx.h>
#import <WFChatUIKitLava/ESZQSCOrgRelationship.h>
#import <WFChatUIKitLava/ESZQSCOrganizationEx.h>
#import <WFChatUIKitLava/ESZQSCOrganizationCache.h>
#import <WFChatUIKitLava/ESZQSCOrgServiceProvider.h>


#import <WFChatUIKitLava/FRSDASeletedUserVC.h>
#import <WFChatUIKitLava/KxMenu.h>
#import <WFChatUIKitLava/UIImage+ERCategory.h>
#import <WFChatUIKitLava/QOEUAPinyinUtility.h>
#import <WFChatUIKitLava/FRSDAContactTVCell.h>
#import <WFChatUIKitLava/UIImage+ERCategory.h>
#import <WFChatUIKitLava/UIColor+YH.h>
#import <WFChatUIKitLava/QWERImage.h>
#import <WFChatUIKitLava/GFDSAFriendRequestVC.h>
#import <WFChatUIKitLava/AUETASearchChannelVC.h>
#import <WFChatUIKitLava/ASECWSearchGroupTVCell.h>
#import <WFChatUIKitLava/ASECWConversationTVCell.h>
#import <WFChatUIKitLava/ASECWConversationSearchTableVC.h>

#import <WFChatUIKitLava/ATERWAddFriendVC.h>
#import <WFChatUIKitLava/FRSDANewFriendTVCell.h>
#import <WFChatUIKitLava/FRSDAContactSelectTVCell.h>
#import <WFChatUIKitLava/TREWQFavGroupTableVC.h>
@interface ESZQSCOrganizationViewController : UIViewController
@property (nonatomic, strong) NSArray<NSNumber *> *organizationIds;
@property (nonatomic, assign) BOOL selectContact;
@property (nonatomic, assign) BOOL multiSelect;
@property (nonatomic, assign) int maxSelectCount;
@property (nonatomic, assign) BOOL isPushed;
@property (nonatomic, strong) NSArray *disableUsers;
@property (nonatomic, assign) BOOL disableUsersSelected;
@property (nonatomic, strong) void (^selectResult)(NSArray<NSString *> *contacts);
@property (nonatomic, strong) void (^cancelSelect)(void);
@end
#import <WFChatUIKitLava/pinyin.h>
#import <WFChatUIKitLava/LBXScanNative.h>
#import <WFChatUIKitLava/LBXScanTypes.h>

#import <WFChatUIKitLava/WDCARChatInputBar.h>
#import <WFChatUIKitLava/QWERTMessageModel.h>
#import <WFChatUIKitLava/QWERTMultiCallOngoingExpendedCell.h>
#import <WFChatUIKitLava/ASDFGMessageCellBase.h>

#import <WFChatUIKitLava/ASDFGMessageCell.h>
#import <WFChatUIKitLava/ASDFGMediaMessageCell.h>
#import <WFChatUIKitLava/ASDFGArticlesCell.h>

#import <WFChatUIKitLava/ASDFGImageCell.h>
#import <WFChatUIKitLava/ASDFGTextCell.h>
#import <WFChatUIKitLava/ASDFGVoiceCell.h>
#import <WFChatUIKitLava/ASDFGLocationCell.h>
#import <WFChatUIKitLava/ASDFGFileCell.h>
#import <WFChatUIKitLava/ASDFGInformationCell.h>
#import <WFChatUIKitLava/ASDFGCallSummaryCell.h>
#import <WFChatUIKitLava/ASDFGStickerCell.h>
#import <WFChatUIKitLava/ASDFGVideoCell.h>
#import <WFChatUIKitLava/ASDFGRecallCell.h>
#import <WFChatUIKitLava/ASDFGConferenceInviteCell.h>
#import <WFChatUIKitLava/ASDFGCardCell.h>
#import <WFChatUIKitLava/ASDFGCompositeCell.h>
#import <WFChatUIKitLava/ASDFGLinkCell.h>
#import <WFChatUIKitLava/ASDFGRichNotificationCell.h>

#import <WFChatUIKitLava/RWADCBrowserVC.h>
#import <WFChatUIKitLava/RWADCProfileTableVC.h>
#import <WFChatUIKitLava/RADCOMultiVideoVC.h>
#import <WFChatUIKitLava/WDCARChatInputBar.h>
#import <WFChatUIKitLava/QWERImagePreviewViewController.h>
#import <WFChatUIKitLava/AUETAChannelProfileVC.h>
#import <WFChatUIKitLava/ASECWReceiptVC.h>
#import <WFChatUIKitLava/QWERTMultiCallOngoingCell.h>

#import <WFChatUIKitLava/WSEDCAttributedLabel.h>

#import <WFChatUIKitLava/ASECWConversationSearchTVCell.h>

#import <WFChatUIKitLava/QWERTSelectNoDisturbingTimeVC.h>
#import <WFChatUIKitLava/QWASZShareMessageView.h>
#import <WFChatUIKitLava/UIView+TYAlertView.h>
#import <WFChatUIKitLava/TYAlertController.h>
#import <WFChatUIKitLava/TYAlertView.h>
#import <WFChatUIKitLava/TYShowAlertView.h>
