//
//  FriendRequestTableViewCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/23.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LavaWFChatClient/WFCChatClient.h>


@protocol GFDSAFriendRequestTVCellDelegate <NSObject>
- (void)onAcceptBtn:(NSString *)targetUserId;
@end


@interface GFDSAFriendRequestTVCell : UITableViewCell
@property (nonatomic, strong)WFCCFriendRequest *friendRequest;
@property (nonatomic, weak)id<GFDSAFriendRequestTVCellDelegate> delegate;
@end
