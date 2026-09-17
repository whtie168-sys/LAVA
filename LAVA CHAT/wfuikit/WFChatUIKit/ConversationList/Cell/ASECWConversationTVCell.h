//
//  ConversationTableViewCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSEDCBubbleTipView.h"
#import <LavaWFChatClient/WFCChatClient.h>


@interface ASECWConversationTVCell : UITableViewCell
@property (strong, nonatomic) UIImageView *wsedcPotraitView;
@property (strong, nonatomic) UILabel *wsedcTargetLabel;
@property (strong, nonatomic) UILabel *wsedcDigestLabel;
@property (strong, nonatomic) UILabel *offcialView;
@property (strong, nonatomic) UIImageView *wsedcStatusView;
@property (strong, nonatomic) UILabel *wsedcTimeLabel;
@property (strong, nonatomic) UIImageView *wsedcSilentImgView;
@property (strong, nonatomic) UIImageView *secretChatView;
@property (nonatomic, strong)WSEDCBubbleTipView *asoucBubbleView;
@property (nonatomic, strong)WFCCConversationInfo *info;
@property (nonatomic, strong)WFCCConversationSearchInfo *searchInfo;
@property (nonatomic, assign, getter=isBig)BOOL big;

@end
