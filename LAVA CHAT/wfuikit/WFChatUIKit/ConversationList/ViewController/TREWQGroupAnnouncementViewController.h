//
//  TREWQGroupAnnouncementViewController.h
//  WFChatUIKit
//
//  Created by Heavyrain Lee on 2019/10/22.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TREWQGroupAnnouncement.h"

NS_ASSUME_NONNULL_BEGIN

@interface TREWQGroupAnnouncementViewController : UIViewController
@property(nonatomic, strong)TREWQGroupAnnouncement *announcement;
@property(nonatomic, assign)BOOL isManager;
@end

NS_ASSUME_NONNULL_END
