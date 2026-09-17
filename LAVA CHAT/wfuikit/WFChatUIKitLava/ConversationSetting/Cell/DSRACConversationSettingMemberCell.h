//
//  ConversationSettingMemberCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/11/3.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LavaWFChatClient/WFCChatClient.h>

@interface DSRACConversationSettingMemberCell : UICollectionViewCell
@property(nonatomic, strong) UIImageView *headerImageView;
@property(nonatomic, strong) UILabel *asoucNameLabel;
- (void)setModel:(NSObject *)model withType:(WFCCConversationType)type;
@end
