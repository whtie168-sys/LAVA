//
//  DiscoverTableViewCell.h
//  WildFireChat
//
//  Created by Tom Lee on 2020/3/10.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFChatUIKitLava/WFChatUIKit.h>
#ifdef WFC_MOMENTS
#import <WFMomentClient/WFMomentClient.h>
#endif
NS_ASSUME_NONNULL_BEGIN

@interface DiscoverMomentsTableViewCell : UITableViewCell
@property (nonatomic, strong)WSEDCBubbleTipView *asoucBubbleView;
#ifdef WFC_MOMENTS
@property (nonatomic, strong)WFMFeed *lastFeed;
#endif
@end

NS_ASSUME_NONNULL_END
