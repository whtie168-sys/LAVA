//
//  ForwardMessageCell.h
//  WildFireChat
//
//  Created by heavyrain lee on 2018/9/27.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LavaWFChatClient/WFCChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface QWASZForwardMessageCell : UITableViewCell
@property (strong, nonatomic) WFCCConversation *conversation;
@end

NS_ASSUME_NONNULL_END
